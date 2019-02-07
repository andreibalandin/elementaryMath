//
//  ViewController.swift
//  elementaryMath
//
//  Created by Andrei Balandin on 2019-02-06.
//  Copyright © 2019 Andrei Balandin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var studentName: UITextField!
    @IBOutlet weak var assignmentDate: UITextField!
    @IBOutlet weak var problem: UIProblemView!
    
    @IBAction func verify(_ sender: UIButton) {
        print(studentName?.text as Any)
        print(assignmentDate?.text as Any)
        print(problem.isCorrect)
        print(problem.expression)
    }
    
    override func viewDidLoad() {
        problem.randomize(complexity: 0)
        print(problem.expression)
    }
}
