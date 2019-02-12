//
//  LaunchScreenViewController.swift
//  elementaryMath
//
//  Created by Andrei Balandin on 2019-02-12.
//  Copyright © 2019 Andrei Balandin. All rights reserved.
//

import UIKit

class LaunchScreenViewController: UIViewController {
    @IBOutlet weak var studentName: UITextField!
    @IBOutlet weak var assignmentDate: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "calculationsGameSegue":
            let calcualtionsGameController = segue.destination as! ViewController
            calcualtionsGameController.initValues = (studentName!.text, assignmentDate!.text)
        default:
            print("segue \(segue.identifier!) not supported")
        }
    }
}
