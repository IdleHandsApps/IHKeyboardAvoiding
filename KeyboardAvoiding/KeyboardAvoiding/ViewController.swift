//
//  ViewController.swift
//  KeyboardAvoiding
//
//  Created by Fraser on 20/12/16.
//  Copyright © 2016 IdleHandsApps. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var avoidingView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "diamond_upholstery")!)
        
        KeyboardAvoiding.avoidingView = self.avoidingView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

