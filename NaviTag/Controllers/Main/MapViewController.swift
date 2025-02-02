//
//  MapViewController.swift
//  NaviTag
//
//  Created by Begüm Arıcı on 31.01.2025.
//

import UIKit
import MapKit



class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!

    var locationManager = CLLocationManager()
    var searchController: UISearchController!
    var selectedAnnotation: MKPointAnnotation?
    var selectedPlace: MKMapItem?
    var selectedCategory: String?
    var categoryTextField: UITextField?
    var pickerView = UIPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        setupLocationManager()
        setupNavigationBar()
        
        // InfoView Design
        infoView.layer.cornerRadius = 16
        infoView.layer.shadowColor = UIColor.black.cgColor
        infoView.layer.shadowOpacity = 0.2
        infoView.layer.shadowRadius = 10
        infoView.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        infoView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        
        placeNameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        placeNameLabel.textColor = .label

        distanceLabel.font = UIFont.systemFont(ofSize: 14)
        distanceLabel.textColor = .secondaryLabel
        
        closeButton.setTitle("", for: .normal)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .systemGray

        locationButton.layer.cornerRadius = locationButton.frame.height / 2
        locationButton.layer.masksToBounds = true
        
        saveButton.addTarget(self, action: #selector(savePlaceTapped), for: .touchUpInside)
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        infoView.isHidden = true
        infoView.alpha = 1
        
        
    }
    
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
        navigationItem.rightBarButtonItem = searchButton
    }
    
    @objc func openSearch() {
        searchController = UISearchController(searchResultsController: SearchResultsViewController())
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
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
        
        let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
}

// MARK: - Save Place
extension MapViewController {
    @objc func savePlaceTapped() {
        guard let place = selectedPlace else { return }

        let alert = UIAlertController(title: "Save Place", message: "Enter place name and category", preferredStyle: .alert)
        
        // place name field
        alert.addTextField { textField in
            textField.text = place.name
            textField.placeholder = "Enter place name"
        }

        //  select category field
        alert.addTextField { textField in
            textField.placeholder = "Select a category or enter new"
            textField.inputView = self.pickerView
            textField.addTarget(self, action: #selector(self.categoryTextFieldEdited(_:)), for: .editingChanged)
            self.categoryTextField = textField
        }

        let addAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let placeName = alert.textFields?.first?.text, !placeName.isEmpty else { return }

            // get the category the user has added
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

        let region = MKCoordinateRegion(center: mapItem.placemark.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)

        placeNameLabel.text = mapItem.name
        if let userLocation = locationManager.location {
            let distance = userLocation.distance(from: CLLocation(latitude: mapItem.placemark.coordinate.latitude,
                                                                   longitude: mapItem.placemark.coordinate.longitude))
            distanceLabel.text = String(format: "%.1f km away", distance / 1000)
        } else {
            distanceLabel.text = "Distance could not be calculated"
        }
        infoView.isHidden = false
    }
}


// MARK: - UIPickerViewDelegate and UIPickerViewDataSource
extension MapViewController {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return loadCategories().count + 1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let categoryNames = loadCategories().map { $0.name } + ["+ New Category"]
        return categoryNames[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let categoryNames = loadCategories().map { $0.name } + ["+ New Category"]
        let selected = categoryNames[row]

        DispatchQueue.main.async {
            if selected == "+ New Category" {
                self.categoryTextField?.text = ""
                self.categoryTextField?.inputView = nil

                self.categoryTextField?.keyboardType = .default
                self.categoryTextField?.reloadInputViews()
                self.categoryTextField?.becomeFirstResponder()
            } else {
                self.categoryTextField?.text = selected
                self.categoryTextField?.resignFirstResponder()
            }
        }
    }

    @objc func categoryTextFieldTapped(_ textField: UITextField) {
        if textField.inputView == nil {
            textField.inputView = pickerView
            textField.reloadInputViews()
        }
    }
    
    func showSelectedPlace(place: Place) {
        let coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)

        if let annotation = selectedAnnotation {
            mapView.removeAnnotation(annotation)
        }
        
        let annotation = MKPointAnnotation()
        annotation.title = place.name
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        selectedAnnotation = annotation

        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)

        placeNameLabel.text = place.name

        if let userLocation = locationManager.location {
            let placeLocation = CLLocation(latitude: place.latitude, longitude: place.longitude)
            let distanceInMeters = userLocation.distance(from: placeLocation)
            let distanceInKm = distanceInMeters / 1000.0
            
            distanceLabel.text = String(format: "%.1f km away", distanceInKm)
        } else {
            distanceLabel.text = "Distance could not be calculated"
        }

        if infoView.isHidden {
            infoView.alpha = 0
            infoView.isHidden = false  
            UIView.animate(withDuration: 0.3) {
                self.infoView.alpha = 1
            }
        }
    }







}
