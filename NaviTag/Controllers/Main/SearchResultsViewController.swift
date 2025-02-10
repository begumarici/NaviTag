//
//  SearchResultsViewController.swift
//  NaviTag
//
//  Created by Begüm Arıcı on 31.01.2025.
//

import UIKit
import MapKit

protocol SearchResultsDelegate: AnyObject {
    func didSelectLocation(_ mapItem: MKMapItem)
}

class SearchResultsViewController: UITableViewController {
    
    var searchResults: [MKMapItem] = []
    weak var delegate: SearchResultsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SearchResultCell")

                self.view.backgroundColor = UIColor.backgroundCustom
                self.tableView.backgroundColor = UIColor.backgroundCustom
                self.tableView.separatorColor = UIColor.secondary.withAlphaComponent(0.5)
            }
        }
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath)
        let item = searchResults[indexPath.row]
        
        cell.textLabel?.text = item.name
        cell.backgroundColor = UIColor.backgroundCustom
        cell.textLabel?.textColor = UIColor.primary
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = searchResults[indexPath.row]
        delegate?.didSelectLocation(selectedItem)
    }
}
