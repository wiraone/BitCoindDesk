//
//  TimeConfiguration.swift
//  BitCoinDesk
//
//  Created by Mac on 15/04/22.
//

import Foundation

struct Configuration {
    
    struct Time {
        // Used for time interval to automaticaly refresh data on background or foreground in seconds
        static let refreshTime = 3600.0
    }
    
    struct BaseURL {
        static let url = "https://api.coindesk.com/v1/bpi/currentprice.json"
    }
    
    struct TableView {
        static let numberOfSections = 2
        static let chartNumberOfRow = 1
        static let chartRowHeight = 300.0
        static let contentRowHeight = 200.0
    }
}
