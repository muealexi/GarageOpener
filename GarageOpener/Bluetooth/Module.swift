//
//  Module.swift
//  GarageOpener
//
//  Created by Alexis Müller on 14.07.20.
//  Copyright © 2020 Alexis Müller. All rights reserved.
//

import UIKit
import Foundation
import CoreBluetooth

class BLE: NSObject {
    
    // BLE shared instance
    static let sharedInstance = BLE()
    
    // Properties
    //CoreBluetooth properties
    var centralManager: CBCentralManager!
    var garageOpener: CBPeripheral?

    var receiveErgoCharacteristic: CBCharacteristic?
    var sendErgoCharacteristic: CBCharacteristic?

    var connectedToOpener = false

    //UIAlert properties currently not used
    public var deviceAlert: UIAlertController?
    public var deviceSheet: UIAlertController?
    
    //Device UUID properties
    struct  myOpener {
        static var ServiceUUID: CBUUID?
        static var RxCharacteristicUUID: CBUUID?
        static var TxCharacteristicUUID: CBUUID?
    }
    
    //ble measurement storage variable
    
    var openerData = OpenerData()
    
    // BLE Battery Level variable
    
    var batteryLevel_Left: Int?
    var batteryLevel_Right: Int?
    
    private override init() { }
}

// CBCentralManagerDelegte extension
extension BLE: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("central.state is .poweredOn")
            // calls didDiscover if it successfully discovers a peripheral
            self.startScanningForDevicesWith(serviceUUID: BLE_Identifiers.OpenerServiceCBUUID, characteristicUUID: BLE_Identifiers.OpenerRxCharacteristicCBUUID)
        case .poweredOff:
            print("central.state is .poweredOff")
            print("clearDevices()")
            self.clearDevices()
            opener_ConnectionNotification()
        case .resetting:
            print("disconnect()")
            self.disconnect()
        case .unauthorized: break
        case .unsupported: break
        case .unknown:   break
        @unknown default:
            fatalError("not known case")
        }
    }
    
    // currently not used
    public func startScanningForDevicesWith(serviceUUID: CBUUID, characteristicUUID: CBUUID) {
        self.disconnect()

        myOpener.ServiceUUID = BLE_Identifiers.OpenerServiceCBUUID//CBUUID(string: serviceUUID)
        myOpener.TxCharacteristicUUID = BLE_Identifiers.OpenerTxCharacteristicCBUUID//CBUUID(string: characteristicUUID)
        myOpener.RxCharacteristicUUID = BLE_Identifiers.OpenerRxCharacteristicCBUUID
        self.createDeviceSheet()
        centralManager.scanForPeripherals(withServices: [myOpener.ServiceUUID!], options: nil)
        print("central is scaning for peripherals")
    }
    
    // called by scan for peripherals method
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var title = "Unknown Device"
        if (peripheral.name != nil) { title = peripheral.name!}
        print("central didDiscover peripheral")
        print(title)
    
        print("central - trying to connect")
        if (title == "OPENER" ){
            //            print("connected to STYX_DEMO_RX")
            self.garageOpener = peripheral //
            self.garageOpener?.delegate = self //
            self.centralManager.connect(peripheral,
                                        options: nil)
        }
        
        //        })
    }
    
    // called by .connect() function which is called within didDiscover
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        let peripheralErgo = central.retrieveConnectedPeripherals(withServices: [BLE_Identifiers.OpenerServiceCBUUID] )
        if (peripheralErgo.count >= 1) {
            centralManager.stopScan()
            print("stop scanning")
        }
        //        postBLEConnectionStateNotification(.connecting)
        //        activeDevice = peripheral
        //        activeDevice?.delegate = self
        if(peripheral == garageOpener){
            garageOpener?.discoverServices([myOpener.ServiceUUID!])
            connectedToOpener = true
            opener_ConnectionNotification()
            print("connected to Opener")
        }
    }
    
    // called by .connect() function which is called within didDiscover
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        //        self.createErrorAlert()
        print("failed to connect")
        centralManager.scanForPeripherals(withServices: [myOpener.ServiceUUID!, myOpener.ServiceUUID!], options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        if( error != nil){
            print("error in didDisconnectPeripheral - \(error!)")
        }
        if peripheral == garageOpener {
            //            postBLEConnectionStateNotification(.disconnected)
            print("central.state is .disconnected from ergoline")
            garageOpener?.setNotifyValue(false, for: receiveErgoCharacteristic!)
            centralManager.cancelPeripheralConnection(garageOpener!)
            self.garageOpener = nil;
            connectedToOpener = false
            opener_ConnectionNotification()
        }
        else{
            print("disconnected from unknown device")
        }
        centralManager.scanForPeripherals(withServices: [myOpener.ServiceUUID!], options: nil)
    }
}



// CBPeripheralDelegate extension
extension BLE: CBPeripheralDelegate {
    
    // called by .discoverServices() function within didConnect function
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            print("something went wrong while didDiscoverServices - error != 0")
            return
        }
        guard let services = peripheral.services else { return}
        for thisService in services {
            if thisService.uuid == myOpener.ServiceUUID {
                garageOpener?.discoverCharacteristics(nil, for: thisService)
            }
        }
    }
    
    // called by discoverCharacteristics() method inside didDiscoverServices Delegate
    // SETS UP SUBSCRIBER TO BLUETOOTH SERVICES AND NOTIFIER FOR APP TO LISTEN TO CHANGES
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            //            self.createErrorAlert()
            print("something went wrong in didDiscoverCharacteristicFor - error != nil")
            // post notification
            return
        }
        guard let characteristics = service.characteristics else { return }
        //        postBLEConnectionStateNotification(.connected)
        print("peripheral is .connected")
        for thisCharacteristic in characteristics {
            if (thisCharacteristic.uuid == myOpener.TxCharacteristicUUID) {
                receiveErgoCharacteristic = thisCharacteristic
                peripheral.setNotifyValue(true, for: receiveErgoCharacteristic!)
            }
            if (thisCharacteristic.uuid == myOpener.RxCharacteristicUUID) {
                sendErgoCharacteristic = thisCharacteristic
            }
        }
    }
    
    //  called every time the value is updated if setNotifyValue() is set to true in didDiscoverCharacteristicsFor delegate method
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
   
        if error != nil {
            print("something went wrong while didUpdateValueFor - error != nil")
            return
        }
        
        if( peripheral == garageOpener){
            if characteristic.uuid == myOpener.TxCharacteristicUUID {
                self.openerData = self.ErgolineConversion(from: characteristic)
//                print("ergoData: \(ergoData)")
//                ergoline_DataNotification()
                signalReceived_Notification()
            }
        
        }
        else{ print("updated for unknown device") }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("Error discovering services: error")
          return
        }
    }
}

// Helper methods
extension BLE {
    
    // return private variable Measurement Data left foot
    func getErgoData() -> OpenerData{
        
        return self.openerData
    }
    
    // use this to start up the shared instantce in AppDelegate
    func startCentralManager() {
        // dispatch it from the main thread queue to make the app run more smoothly
        let centralManagerQueue = DispatchQueue(label: "BLE queue", attributes: .concurrent)
        centralManager = CBCentralManager(delegate: self, queue: centralManagerQueue)
    }
    
    func resetCentralManger() {
        self.disconnect()
        let centralManagerQueue = DispatchQueue(label: "BLE queue", attributes: .concurrent)
        centralManager = CBCentralManager(delegate: self, queue: centralManagerQueue)
    }
    
    func disconnect() {
        if let receiveErgoChar = receiveErgoCharacteristic {
            garageOpener?.setNotifyValue(false, for: receiveErgoChar)
        }
        if(garageOpener != nil){
            centralManager.cancelPeripheralConnection(garageOpener!)
            opener_ConnectionNotification()
        }
    }
    
    // SEND DATA TO ERGOLINE
    func writeErgolineValue(withValue value: String) {
        
        let valueString = (value as NSString).data(using: String.Encoding.utf8.rawValue)
        if let blePeripheral = garageOpener {
            if let sendCharacteristic = sendErgoCharacteristic {
                blePeripheral.writeValue(valueString!, for: sendCharacteristic, type: CBCharacteristicWriteType.withResponse)
            }
        }
    }
    
    fileprivate func clearDevices() {
        garageOpener = nil
        connectedToOpener = false
        receiveErgoCharacteristic = nil
        sendErgoCharacteristic = nil
        myOpener.ServiceUUID = nil
        myOpener.TxCharacteristicUUID = nil
    }
    
    // UIActionSheet Methods
    // not used at the moment, needs some more implementation in view controller
    fileprivate func createDeviceSheet() {
        print("creating device sheet")
        deviceSheet = UIAlertController(title: "Please choose a device.",
                                        message: "Connect to:", preferredStyle: .actionSheet)
        deviceSheet!.addAction(UIAlertAction(title: "Cancel", style: .cancel,
                                             handler: { action -> Void in self.centralManager.stopScan() }))
    }
    
    fileprivate func createErrorAlert() {
        deviceAlert = UIAlertController(title: "Error: failed to connect.",
                                        message: "Please try again.", preferredStyle: .alert)
        print("UIAlertController")
    }
    
    fileprivate func opener_ConnectionNotification() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "openerConnectivityUpdate"), object: self, userInfo: nil)
    }
    
    fileprivate func signalReceived_Notification() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "signalReceivedUpdate"), object: self, userInfo: nil)
    }
    
    fileprivate func ergoline_DataNotification() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "ergolinePowerUpdated"), object: self, userInfo: nil)
    }
    
    // CONVERTS RECEIVED BATTERY VOLTAGE INTO PERCENTAGE
    private func batteryChargeConversion(batData: Int) -> Int {
        let batEmpty = 320      // 3.2V
        let batFull = 420       // 4.2V
        
        let batCharge = (100*(batData+300-batEmpty)) / (batFull-batEmpty)
        
        print("batCharge (V): \(Float(batData+300)/100)")
        return batCharge
    }
  
     private func ErgolineConversion(from characteristic: CBCharacteristic) -> OpenerData {
        guard let characteristicData = characteristic.value else { return OpenerData() }
        var E = OpenerData()
        let byteArray = [UInt8](characteristicData)
        
        if Int(byteArray[0]) == 1 {
            E.received = true
        } else {
            E.received = false
        }
    
        if E.received {
            print("Signal received!")
        }
        
        return E
    }
    
}
