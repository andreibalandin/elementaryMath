//
//  ControlView.swift
//  elementaryMath
//
//  Created by Andrei Balandin on 2019-02-14.
//  Copyright © 2019 Andrei Balandin. All rights reserved.
//

import UIKit

@IBDesignable
class ControlView: UIView {
    @IBOutlet private weak var nameLabel: UILabel!
    var name: String {
        get {
            return (nameLabel?.text)!
        }
        set {
            nameLabel?.text = newValue
        }
    }
    
    @IBOutlet private weak var dateLabel: UILabel!
    var date: Date = Date() {
        didSet {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            dateLabel.text = formatter.string(from: date)
        }
    }
    
    @IBOutlet private weak var scoreLabel: UILabel!
    
    @IBOutlet private weak var attemptsLabel: UILabel!
    private var attempts = 0 {
        didSet {
            attemptsLabel?.text = String(attempts)
        }
    }
    
    public weak var delegate: GameControlDelegate?
    public weak var view: UIView?
    private var complexity = 10 {
        didSet {
            reset()
        }
    }
    
    @IBAction func lessComplex(_ sender: Any) {
        if complexity > 0 {
            complexity -= 1
        }
    }
    
    @IBAction func moreComplex(_ sender: Any) {
        if complexity < 100 {
            complexity += 1
        }
    }
    
    @IBAction func verifyAction(_ sender: Any) {
        scoreLabel?.text = String(delegate!.verify())
        
        UIGraphicsBeginImageContext(view!.frame.size)
        view!.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
    }
    
    func reset() {
        attempts = 0
        if timer != nil {
            timer?.invalidate()
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            self?.secondsPassed += 1
        }
        
        secondsPassed = 0
        scoreLabel?.text = "0"
        
        delegate!.reset(complexity: complexity)
    }

    @IBOutlet private weak var timeLabel: UILabel!
    private weak var timer: Timer?
    private var secondsPassed = 0 {
        // https://stackoverflow.com/questions/26794703/swift-integer-conversion-to-hours-minutes-seconds
        didSet {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.unitsStyle = .full
            
            timeLabel.text = formatter.string(from: TimeInterval(secondsPassed))!
        }
    }

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

protocol GameControlDelegate: class {
    func reset(complexity: Int) -> Void
    func verify() -> Int
}
