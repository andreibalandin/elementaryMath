//
//  UIProblemView.swift
//  elementaryMath
//
//  Created by Andrei Balandin on 2019-02-06.
//  Copyright © 2019 Andrei Balandin. All rights reserved.
//

import UIKit

@IBDesignable
class ProblemView: UIView {
    @IBOutlet private weak var leftOperand: UILabel!
    @IBOutlet private weak var operation: UILabel!
    @IBOutlet private weak var rightOperand: UILabel!
    @IBOutlet private weak var comparison: UILabel!
    @IBOutlet weak var answer: UITextField!
    
    private var contentView:UIView?
    
    var expression:String {
        return (leftOperand?.text)! + (operation?.text)! + (rightOperand?.text)! + (comparison?.text)! + (answer?.text)!
    }
    
    var isCorrect:Bool {
        let l = Int((leftOperand?.text!)!)
        let r = Int((rightOperand?.text)!)
        let a = Int((answer?.text)!)
        switch operation?.text! {
        case "-": return l! - r! == a
        case "+": return l! + r! == a
        case "/": return l! / r! == a
        case "*": return l! * r! == a
        default: return false
        }
    }
    
    private func rnd(_ scale:Int) -> String {
        return "\(Int.random(in: 1...scale))"
    }
    
    func randomize(complexity:Int) {
        leftOperand.text = rnd(complexity)
        operation.text = (["-", "+", "/", "*"])[Int.random(in:0...3)]
        rightOperand.text = rnd(complexity)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        contentView = view
    }
    
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "ProblemView", bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
}
