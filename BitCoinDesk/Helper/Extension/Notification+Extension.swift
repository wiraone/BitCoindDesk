//
//  Notification+Extension.swift
//  BitCoinDesk
//
//  Created by Wirawan on 17/04/22.
//

import Foundation

extension Notification.Name {
    static let fetchCurrentPrice = Notification.Name(Configuration.Identifier.refreshNotificationIdentifier)
    static let turnOffForegroundTimer = Notification.Name(Configuration.Identifier.foregroundTimerOffNotificationIdentifier)
    static let turnOnForegroundTimer = Notification.Name(Configuration.Identifier.foregroundTimerOnNotificationIdentifier)
}
