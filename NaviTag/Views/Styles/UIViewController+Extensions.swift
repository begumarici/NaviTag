//
//  UIViewController+Extensions.swift
//  NaviTag
//
//  Created by Begüm Arıcı on 5.02.2025.
//

import UIKit

extension UIViewController {
    func setupNavigationBar(title: String) {
        if let navBar = navigationController?.navigationBar, #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.primary
            appearance.titleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: UIFont(name: "AvenirNext-DemiBold", size: 18)!
            ]
            navBar.standardAppearance = appearance
            navBar.scrollEdgeAppearance = appearance
        } else {
            navigationController?.navigationBar.barTintColor = UIColor.primary
            navigationController?.navigationBar.tintColor = UIColor.white
            navigationController?.navigationBar.titleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: UIFont(name: "AvenirNext-DemiBold", size: 18)!
            ]
        }
        navigationItem.title = title
    }
}
