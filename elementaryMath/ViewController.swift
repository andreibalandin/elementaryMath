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
    var numberOfAttempts = 0 {
        didSet {
            attemptsLabel.text = "\(numberOfAttempts)"
        }
    }
    
    @IBAction func verify(_ sender: UIButton) {
        let isNameValid = verifyName(studentName?.text)
        if !isNameValid {
            studentName.attributedText = formatWrongAnswer(studentName?.text)
        }
        let isDateValid = verifyDate(assignmentDate?.text)
        if !isDateValid {
            assignmentDate?.attributedText = formatWrongAnswer(assignmentDate?.text)
        }
        
        wrongAnswers = 0
        eachProblem {
            if !$0.isCorrect {
                $0.answer.attributedText = formatWrongAnswer($0.answer.text)
                wrongAnswers += 1
            }
        }
        
        numberOfAttempts += 1
        let NA = Double(numberOfAttempts)
        let TP = Double(problemsCollectionView.visibleCells.count)
        let WA = Double(wrongAnswers)
        let CA = TP - WA
        score = score * (NA - 1)/NA + CA/TP/NA
        
        if isNameValid, isDateValid {
            screenShot()
        }
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
            return todayComponents == answerComponents
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
    
    // https://stackoverflow.com/questions/25448879/how-do-i-take-a-full-screen-screenshot-in-swift
    func screenShot() {
        //Create the UIImage
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //Save it to the camera roll
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
    }

    // https://stackoverflow.com/questions/34206207/printing-the-view-in-ios-with-swift
    func print() {
        let printInfo = UIPrintInfo(dictionary:nil)
        printInfo.outputType = UIPrintInfo.OutputType.general
        printInfo.jobName = "My Print Job"
        
        // Set up print controller
        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        
        // Assign a UIImage version of my UIView as a printing iten
        printController.printingItem = self.view.toImage()
        
        // If you want to specify a printer
        let printerURL = URL(string: "Your printer URL here, e.g. ipps://HPDC4A3E0DE24A.local.:443/ipp/print")
        let currentPrinter:UIPrinter = UIPrinter(url: printerURL!)
        
        printController.print(to: currentPrinter, completionHandler: nil)
        
        // Do it
        printController.present(from: self.view.frame, in: self.view, animated: true, completionHandler: nil)
    }
}

class ProblemCell: UICollectionViewCell {
    @IBOutlet weak var problem: UIProblemView!
}

// https://stackoverflow.com/questions/34206207/printing-the-view-in-ios-with-swift
extension UIView {
    func toImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
