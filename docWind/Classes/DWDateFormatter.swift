//
//  DWDateFormatter.swift
//  docWind
//
//  Created by Sarvad shetty on 7/6/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import Foundation

class DWDateFormatter {
    
    // MARK: - Singleton declaration
    static var shared = DWDateFormatter()
    
    // MARK: - Properties
    var mainDateFormatter = DateFormatter()

    init(dateFormatter: DateFormatter = DateFormatter()) {
        self.mainDateFormatter = dateFormatter
        self.setup()
    }
    
    // MARK: - Methods
    private func setup() {
        mainDateFormatter.dateFormat = "d/M/yyyy"
        mainDateFormatter.timeZone = .autoupdatingCurrent
    }
    
    func currentDate() -> Date {
        return Date()
    }
    
    func currentDateString() -> String {
        let date = mainDateFormatter.string(from: Date())
        return date
    }
    func getStringFromDate(date: Date) -> String {
        return mainDateFormatter.string(from: date)
    }
}
