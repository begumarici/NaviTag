//
//  FavoritesViewController.swift
//  NaviTag
//
//  Created by Begüm Arıcı on 31.01.2025.
//

import UIKit

class FavoritesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var favoriteCategories: [FavoriteCategory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.backgroundCustom
        
        setupNavigationBar()
        styleUIElements()
        
        loadFavoriteCategories()

        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: "CategoryCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadFavoriteCategories), name: NSNotification.Name("FavoritesUpdated"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup Navigation Bar
    func setupNavigationBar() {
        navigationItem.title = "Favorites"
        let addCategoryButton = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(addCategoryTapped))
        navigationItem.rightBarButtonItem = addCategoryButton
    }
    
    // MARK: - UI Styling Functions
    func styleUIElements() {
        view.backgroundColor = UIColor.backgroundCustom
        collectionView.backgroundColor = UIColor.backgroundCustom
    }
    
    // MARK: - Add Category Action
    @objc func addCategoryTapped() {
        let alert = UIAlertController(title: "New List", message: "Enter list name", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "List name"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            if let categoryName = alert.textFields?.first?.text, !categoryName.isEmpty {
                let newCategory = FavoriteCategory(name: categoryName, icon: "folder.fill", places: [])
                self.favoriteCategories.append(newCategory)
                self.collectionView.reloadData()
                self.saveFavoriteCategories()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    // MARK: - CollectionView Data Source Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if favoriteCategories.isEmpty {
            let noDataLabel = UILabel()
            noDataLabel.text = "No categories yet. Create one!"
            noDataLabel.textAlignment = .center
            noDataLabel.textColor = .gray
            noDataLabel.frame = collectionView.bounds
            collectionView.backgroundView = noDataLabel
            return 0
        } else {
            collectionView.backgroundView = nil
            return favoriteCategories.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        let category = favoriteCategories[indexPath.item]
        cell.configure(with: category)
        return cell
    }
    
    // MARK: - Context Menu for Swipe Actions
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
            return self.makeContextMenu(for: indexPath)
        }
    }
    
    private func makeContextMenu(for indexPath: IndexPath) -> UIMenu {
        let editAction = UIAction(title: "Edit", image: UIImage(systemName: "pencil"), identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off) { _ in
            self.editCategory(at: indexPath)
        }
        
        let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), identifier: nil, discoverabilityTitle: nil, attributes: .destructive, state: .off) { _ in
            self.favoriteCategories.remove(at: indexPath.item)
            self.saveFavoriteCategories()
            self.collectionView.deleteItems(at: [indexPath])
        }
        
        return UIMenu(title: "", children: [editAction, deleteAction])
    }
    
    // MARK: - Edit Category
    func editCategory(at indexPath: IndexPath) {
        let category = favoriteCategories[indexPath.item]
        
        let alert = UIAlertController(title: "Edit Category", message: "Enter a new name", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = category.name
        }
        
        let updateAction = UIAlertAction(title: "Update", style: .default) { _ in
            if let newName = alert.textFields?.first?.text, !newName.isEmpty {
                self.favoriteCategories[indexPath.item].name = newName
                self.saveFavoriteCategories()
                self.collectionView.reloadItems(at: [indexPath])
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(updateAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    // MARK: - CollectionView Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 40
        return CGSize(width: width, height: 80)
    }

    
    // MARK: - Category Selection
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = favoriteCategories[indexPath.item]
        if let placesVC = storyboard?.instantiateViewController(identifier: "PlacesViewController") as? PlacesViewController {
            placesVC.categoryName = category.name
            navigationController?.pushViewController(placesVC, animated: true)
        }
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
        collectionView.reloadData()
    }
}
