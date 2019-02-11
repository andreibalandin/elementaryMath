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
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "problemCell", for: indexPath) as! ProblemCell
        cell.problem.randomize(complexity: complexity)
        return cell
    }
    
    @IBOutlet weak var problemsCollectionView: UICollectionView!
    @IBOutlet weak var studentName: UITextField!
    @IBOutlet weak var assignmentDate: UITextField!
    
    var complexity = 10
    
    @IBAction func verify(_ sender: UIButton) {
        print("name is valid: \(verifyName(studentName?.text))")
        print("date valid: \(verifyDate(assignmentDate?.text))")
    }
    
    @IBAction func moreComplex(_ sender: Any) {
        if complexity < 50 {
            complexity += 1
            randomizeProblems()
        }
    }
    
    @IBAction func lessComplex(_ sender: Any) {
        if complexity > 5 {
            complexity -= 1
            randomizeProblems()
        }
    }
    
    private func eachProblem(_ f: (UIProblemView) -> Void) {
        for problemCell in problemsCollectionView!.visibleCells as! [ProblemCell] {
            f(problemCell.problem)
        }
    }
    
    private func randomizeProblems() {
        eachProblem({ $0.randomize(complexity: complexity) })
    }
    
    func verifyName(_ name:String?) -> Bool {
        let regex = try! NSRegularExpression(pattern: "[a-z]+", options: .caseInsensitive)
        let range = NSRange(location: 0, length: name!.utf16.count)
        return regex.firstMatch(in: name!, options: [], range: range) != nil
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
    
    override func loadView() {
        super.loadView()
        problemsCollectionView.dataSource = self
        problemsCollectionView.delegate = self
    }
}

class ProblemCell: UICollectionViewCell {
    @IBOutlet weak var problem: UIProblemView!
}
