//
//  PlacesViewController.swift
//  NaviTag
//
//  Created by Begüm Arıcı on 31.01.2025.
//

import UIKit

class PlacesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var categoryName: String?
    var places: [Place] = []

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = categoryName
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPlacesForCategory()
    }
    
    // MARK: - Load places for category
    func loadPlacesForCategory() {
        guard let categoryName = categoryName else { return }
        
        if let savedData = UserDefaults.standard.data(forKey: "favoriteCategories"),
           let savedCategories = try? JSONDecoder().decode([FavoriteCategory].self, from: savedData),
           let selectedCategory = savedCategories.first(where: { $0.name == categoryName }) {
            
            places = selectedCategory.places
            tableView.reloadData()
        }
    }
    
    // MARK: - save places
    func savePlacesForCategory() {
        guard let categoryName = categoryName else { return }
        
        if let savedData = UserDefaults.standard.data(forKey: "favoriteCategories"),
           var savedCategories = try? JSONDecoder().decode([FavoriteCategory].self, from: savedData),
           let index = savedCategories.firstIndex(where: { $0.name == categoryName }) {
            
            savedCategories[index].places = places
            
            if let encoded = try? JSONEncoder().encode(savedCategories) {
                UserDefaults.standard.set(encoded, forKey: "favoriteCategories")
            }
        }
    }
    
    // MARK: - TableView Data Source Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath)
        let place = places[indexPath.row]
        cell.textLabel?.text = place.name
        return cell
    }
    
    // MARK: - TableView Edit
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
            self.places.remove(at: indexPath.row)
            self.savePlacesForCategory()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (_, _, completionHandler) in
            let alert = UIAlertController(title: "Edit Place", message: "Enter new place name", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.text = self.places[indexPath.row].name
            }
            
            let updateAction = UIAlertAction(title: "Update", style: .default) { _ in
                if let newName = alert.textFields?.first?.text, !newName.isEmpty {
                    self.places[indexPath.row].name = newName
                    self.savePlacesForCategory()
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
                completionHandler(true)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completionHandler(false)
            }
            
            alert.addAction(updateAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
        }
        editAction.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlace = places[indexPath.row]

        if let tabBarController = self.tabBarController,
           let viewControllers = tabBarController.viewControllers,
           let mapNavController = viewControllers.first as? UINavigationController,
           let mapViewController = mapNavController.topViewController as? MapViewController {

            mapViewController.showSelectedPlace(place: selectedPlace)

            tabBarController.selectedIndex = 0
        }
    }

}
