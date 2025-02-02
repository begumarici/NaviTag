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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SearchResultCell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath)
        let item = searchResults[indexPath.row]
        cell.textLabel?.text = item.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = searchResults[indexPath.row]
        delegate?.didSelectLocation(selectedItem)
    }
}
