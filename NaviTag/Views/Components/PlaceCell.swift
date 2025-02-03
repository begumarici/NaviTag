//
//  PlaceCell.swift
//  NaviTag
//
//  Created by Begüm Arıcı on 3.02.2025.
//

import UIKit

class PlaceCell: UICollectionViewCell {
    
    let placeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.primary
        label.font = UIFont(name: "AvenirNext-DemiBold", size: 16)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = UIColor.white
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 5
        
        addSubview(placeLabel)
        placeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            placeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16)
        ])
    }
    
    func configure(with place: Place) {
        placeLabel.text = place.name
    }
}
