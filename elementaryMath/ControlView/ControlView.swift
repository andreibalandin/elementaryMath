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
    private var contentView:UIView?
    
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
        let nib = UINib(nibName: "ControlView", bundle: Bundle.main)
        let instance = nib.instantiate(withOwner: self, options: nil)
        return instance.first as? UIView
    }
}
