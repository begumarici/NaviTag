//
//  TabBarController.swift
//  NaviTag
//
//  Created by Begüm Arıcı on 31.01.2025.
//

import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = .systemBlue
        tabBar.barTintColor = .white
        tabBar.isTranslucent = false
    }
}
