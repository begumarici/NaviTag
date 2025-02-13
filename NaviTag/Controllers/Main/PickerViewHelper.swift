//
//  PickerViewHelper.swift
//  NaviTag
//
//  Created by Begüm Arıcı on 13.02.2025.
//

import UIKit

class PickerViewHelper: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    var categories: [FavoriteCategory] = []
    var onCategorySelected: ((String) -> Void)?

    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let categoryNames = categories.map { $0.name } + ["+ New Category"]
        return categoryNames[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let categoryNames = categories.map { $0.name } + ["+ New Category"]
        let selected = categoryNames[row]
        onCategorySelected?(selected)
    }
}
