//
//  Date+Formatter.swift
//  BitCoinDesk
//
//  Created by Mac on 15/04/22.
//

import Foundation

extension Date {

    func toString(format: String = "HH:mm") -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
