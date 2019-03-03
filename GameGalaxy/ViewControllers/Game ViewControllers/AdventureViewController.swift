//
//  AdventureViewController.swift
//  GameGalaxy
//
//  Created by Mitchell Taitano on 3/27/18.
//  Copyright © 2018 Mitchell Taitano. All rights reserved.
//

import UIKit

class AdventureViewController: UIViewController {
    
    private var appendTextTimer: Timer = Timer()
    var textToSet: String = ""
    var textArray: [String]?
    var delegate: SelectionDelegate?
    private var recallRate: Double = 0.15
    private var animationDuration: TimeInterval = 0.4
    
    @IBOutlet weak var TextLabel: UILabel!
    @IBOutlet weak var TextAreaView: UIView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - SetUp Functions
    private func setUpUI() {
        TextLabel.sizeToFit()
        TextLabel.numberOfLines = 0
        TextLabel.backgroundColor = UIColor.clear
        TextAreaView.backgroundColor = UIColor.cyan
    }
    
    // MARK: - Timer Functions
    private func setUpTimers() {

    }
    
    private func invalidateAllTimers() {
        appendTextTimer.invalidate()
    }
    
    
    // MARK: - Pause Functions    
    public func pauseGame() {
        invalidateAllTimers()
    }
    
    public func resumeGame() {
        let textString: String = "Do not be conformed to this world, but be transformed by the renewal of your mind, that by testing you may discern what is the will of God, what is good and acceptable and perfect. -Romans 12:2"
        textToSet = textString
        textArray = textString.components(separatedBy: " ")
        appendTextTimer = Timer.scheduledTimer(timeInterval: recallRate, target: self, selector: #selector(appendText), userInfo: nil, repeats: true)
    }
    
    public func restartGame() {
        
    }
    
    public func quitGame() {
        invalidateAllTimers()
    }
    
    
    // MARK: - Button Functions
    func menuButtonPressed() {
        
    }
    
    func leftButtonPressed() {
        
    }
    
    func rightButtonPressed() {
        
    }
    
    func upButtonPressed() {
        
    }
    
    func downButtonPressed() {
        
    }
    
    func AButtonPressed() {
        appendTextTimer.invalidate()
        TextLabel.text = textToSet
    }
    
    func BButtonPressed() {
        
    }
    
    // MARK: - Utility Functions
    @objc private func appendText() {
        guard let stringtoAppend = textArray?.remove(at: 0) else {
            return
        }
        if(textArray?.count == 0) {
            appendTextTimer.invalidate()
            addNewText(label: TextLabel, text: stringtoAppend)
        } else {
            let textWithSpace = stringtoAppend + " "
            addNewText(label: TextLabel, text: textWithSpace)
        }
    }
    
    //MARK: - Animate Writing
    private func addNewText(label: UILabel, text: String) {
        label.fadeTransition(animationDuration)
        label.text?.append(text)
    }
}

// MARK: - Extensions
extension UIView {
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionFade
        animation.duration = duration
        layer.add(animation, forKey: kCATransitionFade)
    }
}
