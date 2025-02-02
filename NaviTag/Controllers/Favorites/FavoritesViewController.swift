//
//  FavoritesViewController.swift
//  NaviTag
//
//  Created by Begüm Arıcı on 31.01.2025.
//

import UIKit


class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var favoriteCategories: [FavoriteCategory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        setupNavigationBar()
        
        loadFavoriteCategories()

        NotificationCenter.default.addObserver(self, selector: #selector(loadFavoriteCategories), name: NSNotification.Name("FavoritesUpdated"), object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    
    func setupNavigationBar() {
        navigationItem.title = "Favorites"
        let addCategoryButton = UIBarButtonItem(title: "+ New List", style: .plain, target: self, action: #selector(addCategoryTapped))
        navigationItem.rightBarButtonItem = addCategoryButton
    }
    
    @objc func addCategoryTapped() {
        let alert = UIAlertController(title: "New List", message: "Enter list name", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "List name"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            if let categoryName = alert.textFields?.first?.text, !categoryName.isEmpty {
                let newCategory = FavoriteCategory(name: categoryName, icon: "folder.fill", places: [])
                self.favoriteCategories.append(newCategory)
                self.tableView.reloadData()
                self.saveFavoriteCategories()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    // MARK: - TableView Data Source Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if favoriteCategories.isEmpty {
            let noDataLabel = UILabel()
            noDataLabel.text = "No categories yet. Create one!"
            noDataLabel.textAlignment = .center
            noDataLabel.textColor = .gray
            tableView.backgroundView = noDataLabel
            return 0
        } else {
            tableView.backgroundView = nil
            return favoriteCategories.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        let category = favoriteCategories[indexPath.row]
        cell.categoryLabel.text = category.name
        return cell
    }
    
    // MARK: - Category Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = favoriteCategories[indexPath.row]
        
        if let placesVC = storyboard?.instantiateViewController(identifier: "PlacesViewController") as? PlacesViewController {
            placesVC.categoryName = category.name
            navigationController?.pushViewController(placesVC, animated: true)
        }
    }

    // MARK: - TableView Editing (Delete & Edit)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            self.favoriteCategories.remove(at: indexPath.row)
            self.saveFavoriteCategories()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, completionHandler) in
            let category = self.favoriteCategories[indexPath.row]
            let alert = UIAlertController(title: "Edit List", message: "Enter new list name", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.text = category.name
            }
            let updateAction = UIAlertAction(title: "Update", style: .default) { _ in
                if let newName = alert.textFields?.first?.text, !newName.isEmpty {
                    self.favoriteCategories[indexPath.row].name = newName
                    self.saveFavoriteCategories()
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
    
    // MARK: - Persistence Methods
    func saveFavoriteCategories() {
        if let encoded = try? JSONEncoder().encode(favoriteCategories) {
            UserDefaults.standard.set(encoded, forKey: "favoriteCategories")
        }
    }
    
    @objc func loadFavoriteCategories() {
        if let savedData = UserDefaults.standard.data(forKey: "favoriteCategories"),
           let savedCategories = try? JSONDecoder().decode([FavoriteCategory].self, from: savedData) {
            favoriteCategories = savedCategories
        }
        tableView.reloadData()
    }
}

