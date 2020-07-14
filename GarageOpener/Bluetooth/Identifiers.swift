//
//  BLE.swift
//  ForcePedalGuiv2
//
//  Created by Henrik Maurenbrecher on 29.08.19.
//  Copyright © 2019 Henrik Maurenbrecher. All rights reserved.
//

import Foundation
import CoreBluetooth

// BLE IDENTIFIERS
struct BLE_Identifiers {
    
    static let OpenerServiceCBUUID = CBUUID(string: "eec0c3ac-169c-11ea-8d71-362b9e155667")
    static let OpenerRxCharacteristicCBUUID = CBUUID(string: "eec0c762-169c-11ea-8d71-362b9e155667") // SENDS DATA TO ERGOLINE
    static let OpenerTxCharacteristicCBUUID = CBUUID(string: "eec0ca96-169c-11ea-8d71-362b9e155667") // RECEIVES DATA FROM ERGOLINE
    
    static let CBUUID_Collection = [OpenerServiceCBUUID, OpenerRxCharacteristicCBUUID, OpenerTxCharacteristicCBUUID]
}
