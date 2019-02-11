//
//  ViewController.swift
//  elementaryMath
//
//  Created by Andrei Balandin on 2019-02-06.
//  Copyright © 2019 Andrei Balandin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "problemCell", for: indexPath) as! ProblemCell
        cell.label.text = "lol"
        return cell
    }
    
    @IBOutlet weak var problemsCollectionView: UICollectionView!
    @IBOutlet weak var studentName: UITextField!
    @IBOutlet weak var assignmentDate: UITextField!
    @IBOutlet weak var problem: UIProblemView!
    
    var complexity = 10
    
    @IBAction func verify(_ sender: UIButton) {
        print("name is valid: \(verifyName(studentName?.text))")
        print("date valid: \(verifyDate(assignmentDate?.text))")
        
        print(problem.isCorrect)
        print(problem.expression)
    }
    
    @IBAction func moreComplex(_ sender: Any) {
        if complexity < 50 {
            complexity += 1
            problem.randomize(complexity: complexity)
        }
    }
    
    @IBAction func lessComplex(_ sender: Any) {
        if complexity > 5 {
            complexity -= 1
            problem.randomize(complexity: complexity)
        }
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
        problem.randomize(complexity: complexity)
        print(problem.expression)
    }
    
    override func loadView() {
        super.loadView()
        problemsCollectionView.dataSource = self
        problemsCollectionView.delegate = self
    }
}

class ProblemCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
}
