//
//  ControlView.swift
//  elementaryMath
//
//  Created by Andrei Balandin on 2019-02-14.
//  Copyright © 2019 Andrei Balandin. All rights reserved.
//

import UIKit

// this view provides problem complexity control, name and date fields and verify button
// also the number of attempts and the timer are displayed
// the view can be placed on story board
@IBDesignable
class ControlView: UIView {
    // student name
    @IBOutlet private weak var nameLabel: UILabel!
    // simplify access and hide implementation detail
    var name: String {
        get {
            return (nameLabel?.text)!
        }
        set {
            nameLabel?.text = newValue
        }
    }
    
    // todays date
    @IBOutlet private weak var dateLabel: UILabel!
    // default to today, but it is set from the start screen
    var date: Date = Date() {
        didSet {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            dateLabel.text = formatter.string(from: date)
        }
    }
    
    // write computed score here
    @IBOutlet private weak var scoreLabel: UILabel!
    
    // and the number of times verify button was pressed
    @IBOutlet private weak var attemptsLabel: UILabel!
    private var attempts = 0 {
        didSet {
            attemptsLabel?.text = String(attempts)
        }
    }
    
    // consumer has to implement a few methods to receive messages from this class
    public weak var delegate: GameControlDelegate?
    
    // this view will be saved as a screen shot after verification
    public weak var view: UIView?
    
    // complexity value is used by consumer to set up the game
    private var complexity = 10 {
        didSet {
            // restart the game if complexity changes
            reset()
        }
    }
    
    // upper and lower complexity bounds are fixed, so let the increase be configurable
    var complexityStep = 1
    @IBAction private func lessComplex(_ sender: Any) {
        if complexity > complexityStep + 1 {
            complexity -= complexityStep
        }
    }
    
    @IBAction private func moreComplex(_ sender: Any) {
        if complexity <= 100 - complexityStep {
            complexity += complexityStep
        }
    }
    
    // let consumer class verify the answers
    @IBAction private func verifyAction(_ sender: Any) {
        // display calculated score
        scoreLabel?.text = String(delegate!.verify())
        
        // need this view for screen shot
        guard view != nil else {
            assertionFailure("view property must be set up")
            return
        }
        UIGraphicsBeginImageContext(view!.frame.size)
        view!.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
    }
    
    // let the consumer reset the game
    func reset() {
        attempts = 0
        
        // stop existing timer
        if timer != nil {
            timer?.invalidate()
        }
        
        // start counting again
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            self?.secondsPassed += 1
        }
        
        secondsPassed = 0
        scoreLabel?.text = "0"
        
        // let consumer do its preparations
        delegate!.reset(complexity: complexity)
    }

    // display timer
    @IBOutlet private weak var timeLabel: UILabel!
    private weak var timer: Timer?
    private var secondsPassed = 0 {
        // don't display the date
        // https://stackoverflow.com/questions/26794703/swift-integer-conversion-to-hours-minutes-seconds
        didSet {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.unitsStyle = .full
            
            timeLabel.text = formatter.string(from: TimeInterval(secondsPassed))!
        }
    }

    // for IBDesignable
    private var contentView:UIView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        contentView = view
    }
    
    private func loadViewFromNib() -> UIView? {
        let nib = UINib(nibName: "ControlView", bundle: Bundle.main)
        let instance = nib.instantiate(withOwner: self, options: nil)
        return instance.first as? UIView
    }
}

// consumer has to implement those methods
protocol GameControlDelegate: class {
    func reset(complexity: Int) -> Void
    func verify() -> Int
}
