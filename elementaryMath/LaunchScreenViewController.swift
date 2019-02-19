//
//  LaunchScreenViewController.swift
//  elementaryMath
//
//  Created by Andrei Balandin on 2019-02-12.
//  Copyright © 2019 Andrei Balandin. All rights reserved.
//

import UIKit

// provides way to input name and date, and to choose one of two worksheets
class LaunchScreenViewController: UIViewController {
    @IBOutlet weak var studentName: UITextField!
    @IBOutlet weak var assignmentDate: UITextField!
    private var date: Date? {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.date(from: assignmentDate?.text ?? "")
        }
    }

    // before choosing a worksheet, name and current date must be filled
    private func verify() -> Bool {
        let isNameValid = verifyName(studentName.text)
        if !isNameValid {
            studentName.attributedText = self.formatWrongAnswer(studentName.text)
        }

        let isDateValid = verifyDate(date)
        if !isDateValid {
            assignmentDate?.attributedText = self.formatWrongAnswer(assignmentDate.text)
        }
        
        return isNameValid && isDateValid
    }
    
    // name can be any letter sequence
    private func verifyName(_ name: String?) -> Bool {
        let regex = try! NSRegularExpression(pattern: "[a-z]+", options: .caseInsensitive)
        let range = NSRange(location: 0, length: name!.utf16.count)
        return regex.firstMatch(in: name!, options: [], range: range) != nil
    }
    
    // date must be todays date
    private func verifyDate(_ date: Date?) -> Bool {
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
    // pass name and date to next screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "calculationsGameSegue":
            // this screen has original header code in it
            let calcualtionsGameController = segue.destination as! ViewController
            calcualtionsGameController.initValues = (studentName.text, assignmentDate.text)
        case "matchingGameSegue":
            // here the header was extracted into its own class
            var props = segue.destination as! GameInitialization
            props.name = (studentName!.text)!
            props.date = date!
            print("matchingGameSegue")
        default:
            print("segue \(segue.identifier!) not supported")
        }
    }
    
    // check name and date before navigating away
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return self.verify()
    }
}

// implement to receive data from launcher screen
protocol GameInitialization {
    var name: String { get set }
    var date: Date { get set }
}

// extracted from original math sheet since now this code is used by three screens
extension UIViewController {
    func formatWrongAnswer(_ answer: String?) -> NSMutableAttributedString {
        let range = NSMakeRange(0, answer!.count)
        let attributedText = NSMutableAttributedString(string: answer!)
        attributedText.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: range)
        return attributedText
    }
}
