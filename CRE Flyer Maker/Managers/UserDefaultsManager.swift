//
//  UserDefaultsManager.swift
//  CRE Flyer Maker
//
//  Created by mustafa ergisi on 9/22/25.
//

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let userDefaults = UserDefaults.standard
    
    // Keys
    private let brokerInfoKey = "savedBrokerInfo"
    private let propertiesKey = "savedProperties"
    
    private init() {}
    
    // MARK: - Broker Info
    func saveBrokerInfo(_ brokerInfo: BrokerInfo) {
        if let encoded = try? JSONEncoder().encode(brokerInfo) {
            userDefaults.set(encoded, forKey: brokerInfoKey)
        }
    }
    
    func loadBrokerInfo() -> BrokerInfo? {
        guard let data = userDefaults.data(forKey: brokerInfoKey),
              let brokerInfo = try? JSONDecoder().decode(BrokerInfo.self, from: data) else {
            return nil
        }
        return brokerInfo
    }
    
    func clearBrokerInfo() {
        userDefaults.removeObject(forKey: brokerInfoKey)
    }
    
    // MARK: - Properties
    func saveProperty(_ property: Property) {
        var properties = loadProperties()
        properties.append(property)
        saveProperties(properties)
    }
    
    func saveProperties(_ properties: [Property]) {
        if let encoded = try? JSONEncoder().encode(properties) {
            userDefaults.set(encoded, forKey: propertiesKey)
        }
    }
    
    func loadProperties() -> [Property] {
        guard let data = userDefaults.data(forKey: propertiesKey),
              let properties = try? JSONDecoder().decode([Property].self, from: data) else {
            return []
        }
        return properties
    }
    
    func deleteProperty(withId id: UUID) {
        var properties = loadProperties()
        properties.removeAll { $0.id == id }
        saveProperties(properties)
    }
    
    func updateProperty(_ property: Property) {
        var properties = loadProperties()
        if let index = properties.firstIndex(where: { $0.id == property.id }) {
            properties[index] = property
            saveProperties(properties)
        }
    }
    
    func clearAllProperties() {
        userDefaults.removeObject(forKey: propertiesKey)
    }
}
