//
//  SettingsManagable.swift
//  docWind
//
//  Created by Sarvad shetty on 7/1/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import Foundation

//MARK: - Main protocol
protocol SettingsManageable {
    func settingsURL() -> URL
    func update() -> Bool
    mutating func load() -> Bool
    mutating func loadUsingSettingsFile() -> Bool
    func delete() -> Bool
    mutating func reset() -> Bool
    func toDictionary() -> [String: Any?]?
    func toPlist() -> Bool
}

//MARK: - Extension
extension SettingsManageable where Self: Codable {
    
    func settingsURL() -> URL {
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return cacheDirectory.appendingPathComponent("\(Self.self).plist")
    }
    
    func update() -> Bool {
        do {
            let encoded = try PropertyListEncoder().encode(self)
            try encoded.write(to: settingsURL())
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    mutating func load() -> Bool {
        if FileManager.default.fileExists(atPath: settingsURL().path) {
            do {
                let fileContents = try Data(contentsOf: settingsURL())
                self = try PropertyListDecoder().decode(Self.self, from: fileContents)
                return true
            } catch {
                print(error.localizedDescription)
                return false
            }
        } else {
            if update() {
                backupSettingsFile()
                return true
            } else {
                return false
            }
        }
    }
    
    mutating func loadUsingSettingsFile() -> Bool {
        guard let originalSettingsURL = Bundle.main.url(forResource: "\(Self.self)", withExtension: "plist") else { return false }
        
        do {
            if !FileManager.default.fileExists(atPath: settingsURL().path) {
                try FileManager.default.copyItem(at: originalSettingsURL, to: settingsURL())
            }
            
            let fileContents = try Data(contentsOf: settingsURL())
            self = try PropertyListDecoder().decode(Self.self, from: fileContents)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func delete() -> Bool {
        do {
            try FileManager.default.removeItem(at: settingsURL())
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    //private file dont need to be declared in the protocol
    private func backupSettingsFile() {
        do {
            try FileManager.default.copyItem(at: settingsURL(), to: settingsURL().appendingPathComponent("init"))
        } catch {
            
        }
    }
    
    private func restoreSettingsFile() -> Bool{
        do {
            try FileManager.default.copyItem(at: settingsURL().appendingPathComponent("init"), to: settingsURL())
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    mutating func reset() -> Bool {
        if delete() {
            if !loadUsingSettingsFile() {
                if restoreSettingsFile() {
                    return load()
                }
            } else {
                return true
            }
        }
        return false
    }
    
    func toDictionary() -> [String: Any?]? {
        do {
            if FileManager.default.fileExists(atPath: settingsURL().path) {
                let fileContents = try Data(contentsOf: settingsURL())
                let dictionary = try PropertyListSerialization.propertyList(from: fileContents, options: .mutableContainersAndLeaves, format: nil) as? [String: Any?]
                return dictionary
            }
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    func toPlist() -> Bool {
        do {
            if let dict = toDictionary() {
                let _ = try PropertyListSerialization.data(fromPropertyList: dict, format: .xml, options: .max)
//                PropertyListEncoder.encode(<#T##self: PropertyListEncoder##PropertyListEncoder#>)
//                try FileManager.default.copyItem(at: plist, to: settingsURL())
                return true
            } else {
                return false
            }

        } catch {
            print(error.localizedDescription)
            return false
        }
    }
}
