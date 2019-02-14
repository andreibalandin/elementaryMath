//
//  MatchingViewController.swift
//  elementaryMath
//
//  Created by Andrei Balandin on 2019-02-13.
//  Copyright © 2019 Andrei Balandin. All rights reserved.
//

import UIKit

class MatchingViewController: UIViewController, GameInitialization, GameControlDelegate {
    var name: String = ""
    var date: Date = Date()
    
    @IBOutlet weak var gameControl: ControlView!
    
    func reset(complexity: Int) {
        
    }
    
    func verify() -> Int {
        return 0
    }
    
    override func viewDidLayoutSubviews() {
        gameControl.name = name
        gameControl.date = date
        gameControl.delegate = self
    }
}
