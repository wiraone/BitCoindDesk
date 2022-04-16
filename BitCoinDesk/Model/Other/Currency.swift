//
//  Currency.swift
//  BitCoinDesk
//
//  Created by Mac on 15/04/22.
//

import Foundation

// MARK: - Currency
struct Currency: Codable {
    var code: String? = nil
    var symbol: String? = nil
    var rate: String? = nil
    var currencyDescription: String? = nil
    var rateFloat: Float? = nil

    enum CodingKeys: String, CodingKey {
        case code, symbol, rate
        case currencyDescription = "description"
        case rateFloat = "rate_float"
    }
}
