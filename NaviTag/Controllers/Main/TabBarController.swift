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
        

        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
  
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.backgroundCustom
            
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor.accent
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor.accent,
                .font: UIFont(name: "AvenirNext-DemiBold", size: 12)!
            ]
            
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.secondary
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.secondary,
                .font: UIFont(name: "AvenirNext-Regular", size: 12)!
            ]
            
            tabBar.standardAppearance = appearance
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = appearance
            }
        }
    }
}
