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

    private func verify() -> Bool {
        let isNameValid = verifyName(studentName?.text)
        if !isNameValid {
            studentName.attributedText = self.formatWrongAnswer(studentName?.text)
        }

        let isDateValid = verifyDate(assignmentDate?.text)
        if !isDateValid {
            assignmentDate?.attributedText = self.formatWrongAnswer(assignmentDate?.text)
        }
        
        return isNameValid && isDateValid
    }
    
    private func verifyName(_ name:String?) -> Bool {
        let regex = try! NSRegularExpression(pattern: "[a-z]+", options: .caseInsensitive)
        let range = NSRange(location: 0, length: name!.utf16.count)
        let isValid = regex.firstMatch(in: name!, options: [], range: range) != nil
        
        return isValid
    }
    
    private func verifyDate(_ stringDate: String?) -> Bool {
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
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "calculationsGameSegue":
            let calcualtionsGameController = segue.destination as! ViewController
            calcualtionsGameController.initValues = (studentName!.text, assignmentDate!.text)
        case "matchingGameSegue":
            print("matchingGameSegue")
        default:
            print("segue \(segue.identifier!) not supported")
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return self.verify()
    }
}

extension UIViewController {
    func formatWrongAnswer(_ answer: String?) -> NSMutableAttributedString {
        let range = NSMakeRange(0, answer!.count)
        let attributedText = NSMutableAttributedString(string: answer!)
        attributedText.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: range)
        return attributedText
    }
}
