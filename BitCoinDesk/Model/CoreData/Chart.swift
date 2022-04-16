//
//  Data.swift
//  BitCoinDesk
//
//  Created by Mac on 15/04/22.
//

import Foundation
import CoreData

@objc(Chart)
class Chart: NSManagedObject {
    static func create(_ temp: CurrentPriceModel, _ location: Location, _ gbp: Price, _ usd: Price, _ eur: Price, _ context: NSManagedObjectContext) -> Chart {
        let chart = Chart(context: context)
        chart.createdAt = Date().timeIntervalSince1970
        chart.name = temp.chartName
        chart.location = location
        chart.gbp = gbp
        chart.usd = usd
        chart.eur = eur
        return chart
    }
}
