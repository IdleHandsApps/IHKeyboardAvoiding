//
//  ViewController.swift
//  KeyboardAvoiding
//
//  Created by Fraser on 20/12/16.
//  Copyright © 2016 IdleHandsApps. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var avoidingView: UIView!
    @IBOutlet var textFieldTop: UITextField!
    @IBOutlet var textFieldMiddle: UITextField!
    @IBOutlet var textFieldBottom: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "diamond_upholstery")!)
        
        KeyboardAvoiding.avoidingView = self.avoidingView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    
    // Optional
    // These delegate methods can be used so that test fields that are hidden by the keyboard are shown when they are focused
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.textFieldTop {
            KeyboardAvoiding.avoidingView = self.avoidingView
        }
        else if textField == self.textFieldMiddle {
            KeyboardAvoiding.avoidingView = self.avoidingView
        }
        else if textField == self.textFieldBottom {
            KeyboardAvoiding.padding = 20
            KeyboardAvoiding.avoidingView = textField
            KeyboardAvoiding.padding = 0
        }
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.textFieldTop {
            self.textFieldMiddle.becomeFirstResponder()
        }
        else if textField == self.textFieldMiddle {
            self.textFieldBottom.becomeFirstResponder()
        }
        else if textField == self.textFieldBottom {
            textField.resignFirstResponder()
        }
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

