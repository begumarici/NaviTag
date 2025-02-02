//
//  DataManager.swift
//  NaviTag
//
//  Created by Begüm Arıcı on 31.01.2025.
//

import Foundation

struct LocationModel: Codable {
    let latitude: Double
    let longitude: Double
    let title: String
}

class DataManager {
    static let shared = DataManager()
    
    func saveLocation(_ location: LocationModel) {
        var locations = loadLocations()
        locations.append(location)
        
        if let encoded = try? JSONEncoder().encode(locations) {
            UserDefaults.standard.set(encoded, forKey: "savedLocations")
        }
    }
    
    func loadLocations() -> [LocationModel] {
        if let savedData = UserDefaults.standard.data(forKey: "savedLocations"),
           let decoded = try? JSONDecoder().decode([LocationModel].self, from: savedData) {
            return decoded
        }
        return []
    }
}
