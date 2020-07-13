//
//  AppSettings.swift
//  docWind
//
//  Created by Sarvad shetty on 7/1/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import Foundation

class AppSettings: Codable, SettingsManageable {
    
    // shared instance
    static var shared = AppSettings()
    
    private enum CodingKeys: String, CodingKey {
        case firstLoginDone, notification, bougthNonConsumable, unlimitedFeature, filesCreated, phoneSec
    }
    
    // MARK: - Properties representation settings
    var firstLoginDone: Bool
    var notification: Bool
    var bougthNonConsumable: Bool
    var unlimitedFeature: Bool
    var phoneSec: Bool
    
    // MARK: - Initialization
    init(firstLoginDone: Bool = false, notification: Bool = false, bougthNonConsumable: Bool = false, unlimitedFeature: Bool = false, phoneSec: Bool = false) {
        self.firstLoginDone = firstLoginDone
        self.notification = notification
        self.bougthNonConsumable = bougthNonConsumable
        self.unlimitedFeature = unlimitedFeature
        self.phoneSec = phoneSec
    }
    
    required init(from decoder: Decoder) throws {
       let container = try decoder.container(keyedBy: CodingKeys.self)
       firstLoginDone = try container.decode(Bool.self, forKey: .firstLoginDone)
       notification = try container.decode(Bool.self, forKey: .notification)
        bougthNonConsumable = try container.decode(Bool.self, forKey: .bougthNonConsumable)
        unlimitedFeature = try container.decode(Bool.self, forKey: .unlimitedFeature)
        phoneSec = try container.decode(Bool.self, forKey: .phoneSec)
    }
       
    public func encode(to encoder: Encoder) throws {
       var container = encoder.container(keyedBy: CodingKeys.self)
       try container.encode(firstLoginDone, forKey: .firstLoginDone)
       try container.encode(notification, forKey: .notification)
        try container.encode(bougthNonConsumable, forKey: .bougthNonConsumable)
        try container.encode(unlimitedFeature, forKey: .unlimitedFeature)
        try container.encode(phoneSec, forKey: .phoneSec)
   }
}
