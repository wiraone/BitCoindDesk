//
//  CurrentPriceModel.swift
//  BitCoinDesk
//
//  Created by Mac on 14/04/22.
//

import Foundation
import UIKit

// MARK: - CurrentPriceModel
struct CurrentPriceModel: Codable {
    var time: Time? = nil
    var disclaimer: String? = nil
    var chartName: String? = nil
    var bpi: Bpi? = nil
    var errorMessage: String? = nil
}
