//
//  MapViewController.swift
//  NaviTag
//
//  Created by Begüm Arıcı on 31.01.2025.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var directionsButton: UIButton!
    
    // MARK: - Variables
    var locationManager = CLLocationManager()
    var searchController: UISearchController!
    var selectedAnnotation: MKPointAnnotation?
    var selectedPlace: MKMapItem?
    var selectedCategory: String?
    var categoryTextField: UITextField?
    var pickerView = UIPickerView()
    var pickerViewHelper = PickerViewHelper()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        infoView.isHidden = true
        
        setupLocationManager()
        setupNavigationBar()
        setupPickerView()
        setupSearchBar()
        
        setupUIElements(
            infoView: infoView,
            locationButton: locationButton,
            saveButton: saveButton,
            directionsButton: directionsButton,
            closeButton: closeButton,
            placeNameLabel: placeNameLabel,
            distanceLabel: distanceLabel,
            navigationBar: navigationController?.navigationBar
        )
    }
    
    // MARK: - Setup Functions
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
    }
    
    func setupNavigationBar() {
        navigationItem.title = "NaviTag"
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(openSearch))
        searchButton.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = searchButton
    }
    
    func setupPickerView() {
        pickerView.delegate = pickerViewHelper
        pickerView.dataSource = pickerViewHelper
        pickerViewHelper.categories = loadCategories()
        pickerViewHelper.onCategorySelected = { selected in
            self.categoryTextField?.text = selected
            self.categoryTextField?.resignFirstResponder()
        }
    }
    
    func setupSearchBar() {
        searchController = UISearchController(searchResultsController: SearchResultsViewController())
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
    }
    
   
    
    @IBAction func closeInfoView(_ sender: UIButton) {
        if let annotation = selectedAnnotation {
            mapView.removeAnnotation(annotation)
            selectedAnnotation = nil
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.infoView.alpha = 0
        }) { _ in
            self.infoView.isHidden = true
        }
    }
    
    @IBAction func goToCurrentLocation(_ sender: UIButton) {
        guard let userLocation = locationManager.location else {
            print("Unable to retrieve location information")
            return
        }
        let region = MKCoordinateRegion(center: userLocation.coordinate,
                                        latitudinalMeters: 1000,
                                        longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func getDirectionsTapped(_ sender: UIButton) {
        guard let place = selectedPlace else { return }
        showDirectionsOptions()
    }
    
    
    func showDirectionsOptions() {
        guard let place = selectedPlace else { return }
        
        let latitude = place.placemark.coordinate.latitude
        let longitude = place.placemark.coordinate.longitude

        let alert = UIAlertController(title: "Open in Maps", message: "Choose navigation app", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Google Maps", style: .default) { _ in
            NavigationHelper.openGoogleMaps(latitude: latitude, longitude: longitude)
        })
        
        alert.addAction(UIAlertAction(title: "Apple Maps", style: .default) { _ in
            NavigationHelper.openAppleMaps(latitude: latitude, longitude: longitude)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
}

// MARK: - SearchBar
extension MapViewController: UISearchBarDelegate {
@objc func openSearch() {
    DispatchQueue.main.async {
        self.searchController = UISearchController(searchResultsController: SearchResultsViewController())
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.delegate = self

        self.searchController.searchBar.tintColor = UIColor.white
        self.searchController.searchBar.barTintColor = UIColor.primary

        if #available(iOS 13.0, *) {
            let searchTextField = self.searchController.searchBar.searchTextField
            searchTextField.textColor = .black
            searchTextField.backgroundColor = UIColor.backgroundCustom.withAlphaComponent(0.9)
            searchTextField.attributedPlaceholder = NSAttributedString(
                string: "Search",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
            )
        }

        self.present(self.searchController, animated: true, completion: nil)
    }

}
}

// MARK: - Location MAnager
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let userLocation = locations.last {
            let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}


// MARK: - Save Place
extension MapViewController {
    @objc func savePlaceTapped() {
        guard let place = selectedPlace else { return }
        
        let alert = UIAlertController(title: "Save Place", message: "Enter place name and category", preferredStyle: .alert)

        alert.addTextField { textField in
            textField.text = place.name
            textField.placeholder = "Enter place name"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Select a category or enter new"
            textField.inputView = self.pickerView
            textField.addTarget(self, action: #selector(self.categoryTextFieldEdited(_:)), for: .editingChanged)
            self.categoryTextField = textField
        }
        
        let addAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let placeName = alert.textFields?.first?.text, !placeName.isEmpty else { return }
            let selectedCategoryName = self.categoryTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let categoryName = selectedCategoryName?.isEmpty == false ? selectedCategoryName! : "Favorites"
            self.savePlace(name: placeName, category: categoryName, latitude: place.placemark.coordinate.latitude, longitude: place.placemark.coordinate.longitude)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    @objc func categoryTextFieldEdited(_ textField: UITextField) {
        selectedCategory = textField.text
    }
    
    func savePlace(name: String, category: String, latitude: Double, longitude: Double) {
        var categories = loadCategories()
        if let index = categories.firstIndex(where: { $0.name.lowercased() == category.lowercased() }) {
            if !categories[index].places.contains(where: { $0.name.lowercased() == name.lowercased() }) {
                categories[index].places.append(Place(name: name, latitude: latitude, longitude: longitude))
            }
        } else {
            let newCategory = FavoriteCategory(name: category, icon: "folder.fill", places: [Place(name: name, latitude: latitude, longitude: longitude)])
            categories.append(newCategory)
        }
        if let encoded = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encoded, forKey: "favoriteCategories")
        }
        NotificationCenter.default.post(name: NSNotification.Name("FavoritesUpdated"), object: nil)
    }
    
    func loadCategories() -> [FavoriteCategory] {
        if let savedData = UserDefaults.standard.data(forKey: "favoriteCategories"),
           let savedCategories = try? JSONDecoder().decode([FavoriteCategory].self, from: savedData) {
            return savedCategories
        }
        return []
    }
}

// MARK: - UISearchResultsUpdating
extension MapViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, !query.isEmpty else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else { return }
            if let resultsController = searchController.searchResultsController as? SearchResultsViewController {
                resultsController.searchResults = response.mapItems
                resultsController.tableView.reloadData()
                resultsController.delegate = self
            }
        }
    }
}

// MARK: - SearchResultsDelegate
extension MapViewController: SearchResultsDelegate {
    func didSelectLocation(_ mapItem: MKMapItem) {
        searchController.dismiss(animated: true, completion: nil)
        
        if let annotation = selectedAnnotation {
            mapView.removeAnnotation(annotation)
        }
        
        let annotation = MKPointAnnotation()
        annotation.title = mapItem.name
        annotation.coordinate = mapItem.placemark.coordinate
        mapView.addAnnotation(annotation)
        selectedAnnotation = annotation
        selectedPlace = mapItem
        
        let region = MKCoordinateRegion(center: mapItem.placemark.coordinate,
                                        latitudinalMeters: 1000,
                                        longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        
        placeNameLabel.text = mapItem.name
        if let userLocation = locationManager.location {
            let distance = userLocation.distance(from: CLLocation(latitude: mapItem.placemark.coordinate.latitude,
                                                                   longitude: mapItem.placemark.coordinate.longitude))
            distanceLabel.text = String(format: "%.1f km away", distance / 1000)
        } else {
            distanceLabel.text = "Distance could not be calculated"
        }
        saveButton.isHidden = false
        
        placeNameLabel.textColor = UIColor.black
        distanceLabel.textColor = UIColor.black
        infoView.alpha = 0
        infoView.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.infoView.alpha = 1
        }
    }
}
