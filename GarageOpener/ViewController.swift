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
        // Do any additional setup after loading the view.
    }

    @IBAction func OpenSesame(_ sender: Any) {
        let power:String = String(format:"Opening Gate",Int(1))
        BLE.sharedInstance.writeErgolineValue(withValue: power)
        print("Opening Gate")
    }
    
}

