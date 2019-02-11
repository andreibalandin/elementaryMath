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
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "problemCell", for: indexPath) as! ProblemCell
        cell.problem.randomize(complexity: complexity)
        return cell
    }
    
    @IBOutlet weak var problemsCollectionView: UICollectionView!
    @IBOutlet weak var studentName: UITextField!
    @IBOutlet weak var assignmentDate: UITextField!
    @IBOutlet weak var attemptsLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var complexity = 10
    var wrongAnswers = 0
    var score = 0.0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }
    var numberOfAttempts: Int = 0 {
        didSet {
            attemptsLabel.text = "\(numberOfAttempts)"
        }
    }
    
    @IBAction func verify(_ sender: UIButton) {
        let isNameValid = verifyName(studentName?.text)
        if !isNameValid {
            studentName.attributedText = formatWrongAnswer(studentName?.text)
        }
        print("name is valid: \(isNameValid)")
        print("date valid: \(verifyDate(assignmentDate?.text))")
        
        wrongAnswers = 0
        eachProblem {
            if !$0.isCorrect {
                $0.answer.attributedText = formatWrongAnswer($0.answer.text)
                wrongAnswers += 1
            }
        }
        
        numberOfAttempts += 1
        let totalProblems = Double(problemsCollectionView.visibleCells.count)
        score = (totalProblems - Double(wrongAnswers))/totalProblems/Double(numberOfAttempts)
        print("score \(score), totla \(totalProblems), wrong \(wrongAnswers), attempts \(numberOfAttempts)")
    }
    
    @IBAction func moreComplex(_ sender: Any) {
        if complexity < 50 {
            complexity += 1
            reset()
        }
    }
    
    @IBAction func lessComplex(_ sender: Any) {
        if complexity > 5 {
            complexity -= 1
            reset()
        }
    }
    
    private func reset() {
        numberOfAttempts = 0
        timeLabel.text = "00:00"
        score = 0.0
        randomizeProblems()
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
        let isValid = regex.firstMatch(in: name!, options: [], range: range) != nil
        
        return isValid
    }
    
    func verifyDate(_ stringDate: String?) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: stringDate ?? "")
        if date != nil {
            let calendar = Calendar.current
            let todayComponents = calendar.dateComponents([.year, .month, .day], from: Date())
            let answerComponents = calendar.dateComponents([.year, .month, .day], from: date!)
            print("today is \(Date()), \(todayComponents == answerComponents)")
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
    
    private func formatWrongAnswer(_ answer: String?) -> NSMutableAttributedString {
        let range = NSMakeRange(0, answer!.count)
        let attributedText = NSMutableAttributedString(string: answer!)
        attributedText.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: range)
        return attributedText
    }
}

class ProblemCell: UICollectionViewCell {
    @IBOutlet weak var problem: UIProblemView!
}
