//
//  Bpi.swift
//  BitCoinDesk
//
//  Created by Mac on 15/04/22.
//

import Foundation

// MARK: - Bpi
struct Bpi: Codable {
    var usd: Currency? = nil
    var gbp: Currency? = nil
    var eur: Currency? = nil

    enum CodingKeys: String, CodingKey {
        case usd = "USD"
        case gbp = "GBP"
        case eur = "EUR"
    }
}
