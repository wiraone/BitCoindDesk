//
//  Price.swift
//  BitCoinDesk
//
//  Created by Mac on 15/04/22.
//

import Foundation
import CoreData

@objc(Price)
class Price: NSManagedObject {
    static func create(_ temp: Currency, _ context: NSManagedObjectContext) -> Price {
        let price = Price(context: context)
        price.code = temp.code
        price.symbol = temp.symbol
        price.rate = temp.rate
        price.rateFloat = temp.rateFloat ?? 0
        price.priceDescription = temp.currencyDescription
        return price
    }
}
