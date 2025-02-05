//
//  PlacesViewController.swift
//  NaviTag
//
//  Created by Begüm Arıcı on 31.01.2025.
//

import UIKit

class PlacesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var categoryName: String?
    var places: [Place] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = categoryName
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.backgroundCustom
        
        styleUIElements()
        setupNavigationBar(title: categoryName ?? "Places")
        
        loadPlacesForCategory()
        
        collectionView.register(PlaceCell.self, forCellWithReuseIdentifier: "PlaceCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPlacesForCategory()
    }
    
    // MARK: - UI Styling Functions
    func styleUIElements() {
        view.backgroundColor = UIColor.backgroundCustom
        collectionView.backgroundColor = UIColor.backgroundCustom
    }
    
    // MARK: - Load Places for Category
    func loadPlacesForCategory() {
        guard let categoryName = categoryName else { return }
        
        if let savedData = UserDefaults.standard.data(forKey: "favoriteCategories"),
           let savedCategories = try? JSONDecoder().decode([FavoriteCategory].self, from: savedData),
           let selectedCategory = savedCategories.first(where: { $0.name == categoryName }) {
            
            places = selectedCategory.places
            collectionView.reloadData()
        }
    }
    
    // MARK: - Save Places
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
    
    // MARK: - CollectionView Data Source Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if places.isEmpty {
            let noDataLabel = UILabel()
            noDataLabel.text = "No places added yet!"
            noDataLabel.textAlignment = .center
            noDataLabel.textColor = .gray
            collectionView.backgroundView = noDataLabel
            return 0
        } else {
            collectionView.backgroundView = nil
            return places.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaceCell", for: indexPath) as! PlaceCell
        let place = places[indexPath.item]
        cell.configure(with: place)
        return cell
    }
    
    // MARK: - Context Menu for Swipe Actions (Edit/Delete)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
            return self.makeContextMenu(for: indexPath)
        }
    }
    
    private func makeContextMenu(for indexPath: IndexPath) -> UIMenu {
        let editAction = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { _ in
            self.editPlace(at: indexPath)
        }
        
        let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
            self.places.remove(at: indexPath.item)
            self.savePlacesForCategory()
            self.collectionView.deleteItems(at: [indexPath])
        }
        
        return UIMenu(title: "", children: [editAction, deleteAction])
    }
    
    // MARK: - Edit Place
    func editPlace(at indexPath: IndexPath) {
        let place = places[indexPath.item]
        
        let alert = UIAlertController(title: "Edit Place", message: "Enter a new name", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = place.name
        }
        
        let updateAction = UIAlertAction(title: "Update", style: .default) { _ in
            if let newName = alert.textFields?.first?.text, !newName.isEmpty {
                self.places[indexPath.item].name = newName
                self.savePlacesForCategory()
                self.collectionView.reloadItems(at: [indexPath])
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(updateAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    // MARK: - CollectionView Layout (Spacing & Sizing)
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

    
    // MARK: - Selecting a Place
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedPlace = places[indexPath.item]
        
        if let tabBarController = self.tabBarController,
           let viewControllers = tabBarController.viewControllers,
           let mapNavController = viewControllers.first as? UINavigationController,
           let mapViewController = mapNavController.topViewController as? MapViewController {
            
            mapViewController.showSelectedPlace(place: selectedPlace)
            tabBarController.selectedIndex = 0
        }
    }
}
