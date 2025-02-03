//
//  TabBarController.swift
//  NaviTag
//
//  Created by Begüm Arıcı on 31.01.2025.
//

import UIKit

class TabBarController: UITabBarController {

    private let floatingTabBarView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.backgroundCustom
        view.layer.cornerRadius = 35
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFloatingTabBar()
    }

    private func setupFloatingTabBar() {
        guard let tabBar = self.tabBar as? UITabBar else { return }

        let screenWidth = UIScreen.main.bounds.width
        let tabBarWidth: CGFloat = screenWidth * 0.85
        let tabBarHeight: CGFloat = 70
        let tabBarY: CGFloat = UIScreen.main.bounds.height - 100
        
        floatingTabBarView.frame = CGRect(
            x: (screenWidth - tabBarWidth) / 2,
            y: tabBarY,
            width: tabBarWidth,
            height: tabBarHeight
        )
        
        view.addSubview(floatingTabBarView)

        tabBar.frame = floatingTabBarView.frame
        tabBar.layer.cornerRadius = 35
        tabBar.layer.masksToBounds = true
        tabBar.isTranslucent = true

        for item in tabBar.items ?? [] {
            item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
            item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 2)
        }

        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()

        view.bringSubviewToFront(tabBar)

        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.clear
            
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
