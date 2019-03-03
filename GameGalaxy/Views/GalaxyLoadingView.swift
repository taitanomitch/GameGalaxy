//
//  GalaxyLoadingView.swift
//  GameGalaxy
//
//  Created by Mitchell Taitano on 5/9/18.
//  Copyright © 2018 Mitchell Taitano. All rights reserved.
//

import UIKit

class GalaxyLoadingView: UIView {
    
    enum ViewsToShow: Int {
        case One = 1
        case Two = 2
        case Three = 3
        case Four = 4
        case Five = 5
        case Six = 6
        case Seven = 7
    }
    
    @IBOutlet var ContentView: UIView!
    
    @IBOutlet var ViewsOne: [UIView]!
    @IBOutlet var ViewsTwo: [UIView]!
    @IBOutlet var ViewsThree: [UIView]!
    @IBOutlet var ViewsFour: [UIView]!
    @IBOutlet var ViewsFive: [UIView]!
    @IBOutlet var ViewsSix: [UIView]!
    @IBOutlet var ViewsSeven: [UIView]!
    
    
    private var loadingTimer: Timer = Timer()
    private var viewShowing: ViewsToShow = ViewsToShow.One
    
    private var recallRate: Double = 0.1
    private var rotationAmount: CGFloat = 0.05
    private var squareColor: UIColor = UIColor.black
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        ContentView = Bundle.main.loadNibNamed("GalaxyLoadingView", owner: self, options: nil)?.first as! UIView
        addSubview(ContentView)
        ContentView.frame = self.bounds
        ContentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setUp()
        loadingTimer = Timer.scheduledTimer(timeInterval: recallRate, target: self, selector: #selector(loopThroughLoadingViews), userInfo: nil, repeats: true)
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        loadingTimer.invalidate()
    }
    
    func setUp() {
        setColors()
    }
    
    func setColors() {
        for aView in ViewsOne {
            aView.backgroundColor = squareColor
        }
        for aView in ViewsTwo {
            aView.backgroundColor = squareColor
        }
        for aView in ViewsThree {
            aView.backgroundColor = squareColor
        }
        for aView in ViewsFour {
            aView.backgroundColor = squareColor
        }
        for aView in ViewsFive {
            aView.backgroundColor = squareColor
        }
        for aView in ViewsSix {
            aView.backgroundColor = squareColor
        }
        for aView in ViewsSeven {
            aView.backgroundColor = squareColor
        }
    }
    
    @objc func loopThroughLoadingViews() {
        ContentView.transform = ContentView.transform.rotated(by: rotationAmount)
        switch viewShowing {
        case .One:
            for aView in ViewsOne {
                aView.alpha = 1.0
            }
            for aView in ViewsTwo {
                aView.alpha = 0.6
            }
            for aView in ViewsThree {
                aView.alpha = 0.3
            }
            for aView in ViewsFour {
                aView.alpha = 0.0
            }
            for aView in ViewsFive {
                aView.alpha = 0.0
            }
            for aView in ViewsSix {
                aView.alpha = 0.3
            }
            for aView in ViewsSeven {
                aView.alpha = 0.6
            }
            viewShowing = .Two
        case .Two:
            for aView in ViewsOne {
                aView.alpha = 0.6
            }
            for aView in ViewsTwo {
                aView.alpha = 1.0
            }
            for aView in ViewsThree {
                aView.alpha = 0.6
            }
            for aView in ViewsFour {
                aView.alpha = 0.3
            }
            for aView in ViewsFive {
                aView.alpha = 0.0
            }
            for aView in ViewsSix {
                aView.alpha = 0.0
            }
            for aView in ViewsSeven {
                aView.alpha = 0.3
            }
            viewShowing = .Three
        case .Three:
            for aView in ViewsOne {
                aView.alpha = 0.3
            }
            for aView in ViewsTwo {
                aView.alpha = 0.6
            }
            for aView in ViewsThree {
                aView.alpha = 1.0
            }
            for aView in ViewsFour {
                aView.alpha = 0.6
            }
            for aView in ViewsFive {
                aView.alpha = 0.3
            }
            for aView in ViewsSix {
                aView.alpha = 0.0
            }
            for aView in ViewsSeven {
                aView.alpha = 0.0
            }
            viewShowing = .Four
        case .Four:
            for aView in ViewsOne {
                aView.alpha = 0.0
            }
            for aView in ViewsTwo {
                aView.alpha = 0.3
            }
            for aView in ViewsThree {
                aView.alpha = 0.6
            }
            for aView in ViewsFour {
                aView.alpha = 1.0
            }
            for aView in ViewsFive {
                aView.alpha = 0.6
            }
            for aView in ViewsSix {
                aView.alpha = 0.3
            }
            for aView in ViewsSeven {
                aView.alpha = 0.0
            }
            viewShowing = .Five
        case .Five:
            for aView in ViewsOne {
                aView.alpha = 0.0
            }
            for aView in ViewsTwo {
                aView.alpha = 0.0
            }
            for aView in ViewsThree {
                aView.alpha = 0.3
            }
            for aView in ViewsFour {
                aView.alpha = 0.6
            }
            for aView in ViewsFive {
                aView.alpha = 1.0
            }
            for aView in ViewsSix {
                aView.alpha = 0.6
            }
            for aView in ViewsSeven {
                aView.alpha = 0.3
            }
            viewShowing = .Six
        case .Six:
            for aView in ViewsOne {
                aView.alpha = 0.3
            }
            for aView in ViewsTwo {
                aView.alpha = 0.0
            }
            for aView in ViewsThree {
                aView.alpha = 0.0
            }
            for aView in ViewsFour {
                aView.alpha = 0.3
            }
            for aView in ViewsFive {
                aView.alpha = 0.6
            }
            for aView in ViewsSix {
                aView.alpha = 1.0
            }
            for aView in ViewsSeven {
                aView.alpha = 0.6
            }
            viewShowing = .Seven
        case .Seven:
            for aView in ViewsOne {
                aView.alpha = 0.6
            }
            for aView in ViewsTwo {
                aView.alpha = 0.3
            }
            for aView in ViewsThree {
                aView.alpha = 0.0
            }
            for aView in ViewsFour {
                aView.alpha = 0.0
            }
            for aView in ViewsFive {
                aView.alpha = 0.3
            }
            for aView in ViewsSix {
                aView.alpha = 0.6
            }
            for aView in ViewsSeven {
                aView.alpha = 1.0
            }
            viewShowing = .One
        }
    }
    
}
