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
        print("name is valid: \(verifyName(studentName?.text))")
        print("date valid: \(verifyDate(assignmentDate?.text))")
        
        print(problem.isCorrect)
        print(problem.expression)
    }
    
    func verifyName(_ name:String?) -> Bool {
        return name != ""
    }
    
    func verifyDate(_ stringDate: String?) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: stringDate ?? "")
        if date != nil {
            let today = Date()
            print("today is \(today), \(today.compare(date!))")
            return true
        }
        else {
            return false
        }
    }
    
    override func viewDidLoad() {
        problem.randomize(complexity: 10)
        print(problem.expression)
    }
}
