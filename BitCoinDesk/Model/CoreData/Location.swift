//
//  Location.swift
//  BitCoinDesk
//
//  Created by Mac on 15/04/22.
//

import Foundation
import CoreData

@objc(Location)
class Location: NSManagedObject {
    static func create(_ temp: UserLocation, _ context: NSManagedObjectContext) -> Location {
        let location = Location(context: context)
        location.latitude = temp.latitude ?? 0
        location.longitude = temp.longitude ?? 0
        return location
    }
}
