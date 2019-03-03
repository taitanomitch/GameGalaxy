//
//  CaveTileView.swift
//  GameGalaxy
//
//  Created by Mitchell Taitano on 5/14/18.
//  Copyright © 2018 Mitchell Taitano. All rights reserved.
//

import UIKit

class CaveTileView: UIView {

    @IBOutlet var ContentView: UIView!
    
    @IBOutlet weak var CeilingView: UIView!
    @IBOutlet weak var FloorView: UIView!
    
    @IBOutlet weak var PathView: UIView!
    @IBOutlet weak var PathViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var PathViewCenterYConstraint: NSLayoutConstraint!
    
    public var shouldBeRemoved: Bool = false
    
    func setup(height: CGFloat, offset: CGFloat) {
        PathViewHeightConstraint.constant = height
        PathViewCenterYConstraint.constant = offset
        PathView.setNeedsLayout()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        ContentView = Bundle.main.loadNibNamed("CaveTileView", owner: self, options: nil)?.first as! UIView
        addSubview(ContentView)
        ContentView.frame = self.bounds
        ContentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
