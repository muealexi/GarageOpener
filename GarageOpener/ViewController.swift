//
//  ViewController.swift
//  GarageOpener
//
//  Created by Alexis Müller on 14.07.20.
//  Copyright © 2020 Alexis Müller. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        designCircle()
        setupBLEObserver()
        changeConnectionState()
        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var Circle: UIView!
    @IBOutlet weak var Button: UIButton!

    
    @IBAction func PressDownInside(_ sender: Any) {
        let power:String = String(format:"Opening Gate",Int(1))
        send()
        BLE.sharedInstance.writeErgolineValue(withValue: power)
        print("Opening Gate")
    }
    
    @IBAction func ReleaseInside(_ sender: Any) {
        changeConnectionState()
    }
    
    func setupBLEObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(openerConnectionCheck), name: .opener_ConnectionNotification, object: BLE.sharedInstance)
        
        NotificationCenter.default.addObserver(self, selector: #selector(signalReceived), name: .signalReceived_Notification, object: BLE.sharedInstance)
    }
    
    @objc private func signalReceived(notification: Notification){
//        changeConnectionState()
//        print(BLE.sharedInstance.openerData.received)
        DispatchQueue.main.async {
            self.Button.setImage(UIImage(named: "Garage4.png"), for: .normal)
            }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.Button.setImage(UIImage(named: "Garage3.png"), for: .normal)
            BLE.sharedInstance.openerData.received = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.Button.setImage(UIImage(named: "Garage2.png"), for: .normal)
            BLE.sharedInstance.openerData.received = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.Button.setImage(UIImage(named: "Garage1.png"), for: .normal)
            BLE.sharedInstance.openerData.received = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.Button.setImage(UIImage(named: "Garage2.png"), for: .normal)
            BLE.sharedInstance.openerData.received = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.Button.setImage(UIImage(named: "Garage3.png"), for: .normal)
            BLE.sharedInstance.openerData.received = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            self.Button.setImage(UIImage(named: "Garage4.png"), for: .normal)
            BLE.sharedInstance.openerData.received = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            self.Button.setImage(UIImage(named: "Garage5.png"), for: .normal)
            BLE.sharedInstance.openerData.received = false
        }



        
        }
    
    @objc private func openerConnectionCheck(notification: Notification){
        changeConnectionState()
    }

    
    func designCircle(){
        Circle.frame = CGRect(x: UIScreen.main.bounds.width/8, y: UIScreen.main.bounds.height/2 - 3*UIScreen.main.bounds.width/8, width: 3*UIScreen.main.bounds.width/4, height: 3*UIScreen.main.bounds.width/4)
        Circle.layer.cornerRadius = Circle.frame.size.width/2
        Circle.layer.borderColor = UIColor.gray.cgColor
        Circle.layer.borderWidth = UIScreen.main.bounds.width/30
        Circle.layer.backgroundColor = UIColor.white.cgColor
        
        Button.frame = CGRect(x: UIScreen.main.bounds.width/4, y: UIScreen.main.bounds.height/2 - 1*UIScreen.main.bounds.width/3.5, width: 1*UIScreen.main.bounds.width/2, height: 1*UIScreen.main.bounds.width/2)

    }
    
    func changeConnectionState(){
        DispatchQueue.main.async {
            if BLE.sharedInstance.connectedToOpener{
                self.Circle.layer.backgroundColor = UIColor.green.cgColor
            }
            else{
                self.Circle.layer.backgroundColor = UIColor.init(displayP3Red: 0.9, green: 0.9, blue: 0.9, alpha: 1).cgColor            }
        }
    }
    
    func send(){
//        if BLE.sharedInstance.connectedToOpener{
            Circle.layer.backgroundColor =
                UIColor.init(displayP3Red: 0.7, green: 0.7, blue: 0.7, alpha: 1).cgColor
//        }
    }
}

