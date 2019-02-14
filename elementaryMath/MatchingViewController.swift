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
    
    private var buttons: [MatchingButton] = []
    
    @IBOutlet weak var gameControl: ControlView!
    
    func reset(complexity: Int) {
        print("match reset \(complexity)")
        print("frame \(view.frame)")
        
        let width = Int(view.frame.size.width)
        let height = width
        let yOffset = 200
        let size = width/10
        let padding = 10
        
        for x in stride(from:0, to:width, by:size) {
            for y in stride(from:0, to:height-50, by:size) {
                let buttonFrame = CGRect(x:x+padding, y:y+yOffset+padding, width:size-padding*2, height:size-padding*2)
                let button = MatchingButton(frame: buttonFrame)
                button.x = x
                button.y = y
                button.setTitle(String(Int.random(in: 1..<10)), for:.normal)
                button.backgroundColor = UIColor.gray
                button.layer.cornerRadius = 10
                button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
                buttons.append(button)
                view.addSubview(button)
            }
        }
    }
    
    @objc func buttonAction(sender: UIButton!) {
        print("Button tapped")
    }

    func verify() -> Int {
        return 0
    }
    
    override func viewDidLoad() {
        gameControl.name = name
        gameControl.date = date
        gameControl.view = view
        gameControl.delegate = self
        
        gameControl.reset()
    }
}

class MatchingButton: UIButton {
    var x = 0
    var y = 0
    var connectionTo: (Int, Int)? = nil
}
