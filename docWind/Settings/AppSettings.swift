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
        case firstLoginDone, notification
    }
    
    // MARK: - Properties representation settings
    var firstLoginDone: Bool
    var notification: Bool
    
    // MARK: - Initialization
    init(firstLoginDone: Bool = false, notification: Bool = false) {
        self.firstLoginDone = firstLoginDone
        self.notification = notification
    }
    
    required init(from decoder: Decoder) throws {
       let container = try decoder.container(keyedBy: CodingKeys.self)
       firstLoginDone = try container.decode(Bool.self, forKey: .firstLoginDone)
       notification = try container.decode(Bool.self, forKey: .notification)
    }
       
    public func encode(to encoder: Encoder) throws {
       var container = encoder.container(keyedBy: CodingKeys.self)
       try container.encode(firstLoginDone, forKey: .firstLoginDone)
       try container.encode(notification, forKey: .notification)
   }
}
