//
//  Notifications.swift
//  GarageOpener
//
//  Created by Alexis Müller on 14.07.20.
//  Copyright © 2020 Alexis Müller. All rights reserved.
//

import Foundation

extension Notification.Name {
 
 static let opener_ConnectionNotification = Notification.Name(rawValue: "openerConnectivityUpdate")
    
 static let signalReceived_Notification = Notification.Name(rawValue: "signalReceivedUpdate")

 static let Opener_PowerNotification = Notification.Name(rawValue: "ergolinePowerUpdated")
 
}

