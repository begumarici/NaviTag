//
//  UIStyles.swift
//  NaviTag
//
//  Created by Begüm Arıcı on 12.02.2025.
//

import UIKit

// MARK: - UIView
extension UIView {
    func applyCornerRadius(_ radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    func applyShadow(opacity: Float = 0.3, radius: CGFloat = 4, offset: CGSize = CGSize(width: 0, height: 2)) {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
    }
    
    func applyInfoViewStyle() {
        self.applyCornerRadius(16)
        self.applyShadow(opacity: 0.2, radius: 10, offset: CGSize(width: 0, height: 4))
        self.backgroundColor = UIColor.backgroundCustom.withAlphaComponent(0.95)
    }
}

// MARK: - UIButton
extension UIButton {
    func applyPrimaryStyle(title: String, iconName: String? = nil) {
        self.backgroundColor = UIColor.primary
        self.applyCornerRadius(16)
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        self.applyShadow()
        
        if let iconName = iconName {
            let image = UIImage(systemName: iconName)?.withTintColor(.white, renderingMode: .alwaysOriginal)
            self.setImage(image, for: .normal)
            self.imageView?.contentMode = .scaleAspectFit
            self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 5)
        }
        
        self.setTitle(title, for: .normal)
    }
    
    func applyLocationButtonStyle() {
        self.backgroundColor = UIColor.primary
        self.applyCornerRadius(16)
        self.setTitleColor(.white, for: .normal)
        self.applyShadow()
    }
    
    func applyCloseButtonStyle() {
        self.setTitle("", for: .normal)
        self.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        self.tintColor = UIColor.secondary
    }
}

// MARK: - UILabel
extension UILabel {
    func applyTitleStyle() {
        self.font = UIFont.boldSystemFont(ofSize: 18)
        self.textColor = .label
    }
    
    func applySubtitleStyle() {
        self.font = UIFont.systemFont(ofSize: 14)
        self.textColor = .secondaryLabel
    }
}

// MARK: - UINavigationBar
extension UINavigationBar {
    func applyCustomStyle() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.primary
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "AvenirNext-DemiBold", size: 18)!
        ]
        self.standardAppearance = appearance
        self.scrollEdgeAppearance = appearance
    }
}

// MARK: - UI Setup
extension UIViewController {
    func setupUIElements(infoView: UIView, locationButton: UIButton, saveButton: UIButton, directionsButton: UIButton, closeButton: UIButton, placeNameLabel: UILabel, distanceLabel: UILabel, navigationBar: UINavigationBar?) {
        infoView.applyInfoViewStyle()
        locationButton.applyLocationButtonStyle()
        saveButton.applyPrimaryStyle(title: "Save Place", iconName: "bookmark.fill")
        directionsButton.applyPrimaryStyle(title: "Get Directions", iconName: "arrow.triangle.turn.up.right.circle.fill")
        closeButton.applyCloseButtonStyle()
        placeNameLabel.applyTitleStyle()
        distanceLabel.applySubtitleStyle()
        navigationBar?.applyCustomStyle()
    }
}
