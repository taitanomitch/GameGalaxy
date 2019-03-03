//
//  TrailView.swift
//  GameGalaxy
//
//  Created by Mitchell Taitano on 2/4/18.
//  Copyright © 2018 Mitchell Taitano. All rights reserved.
//

import UIKit

protocol TailViewDelegate {
    func removeThisBlazeTail()
}

class TrailView: UIView {
    
    //Variables
    public var blazeRemoved:  Bool = false
    private var blazeTimer: Timer = Timer()
    private var blazeActivationTimer: Timer = Timer()
    private var blazeSelfActivationTimer: Timer = Timer()
    private var remainingTime: TimeInterval = 0
    public var blazeActive: Bool = false
    public var blazeActiveSelf: Bool = false
    private var remainingActivationTime: TimeInterval = 0
    private var remainingSelfActivationTime: TimeInterval = 0
    
    //Constants
    private var blazeTime: Double = 0
    private var oneSecond: Double = 1.0
    private var halfSecond: Double = 0.5
    private var blazeActivationTime: Double = 0.3
    private var blazeSelfActivationTime: Double = 0.7
    
    
    // MARK: - SetUp Functions
    public func setUpTrailBlaze(blazeTime: Double) {
        self.blazeTime = blazeTime
        remainingSelfActivationTime = blazeActivationTime
        self.backgroundColor = UIColor.cyan
    }
    
    // MARK: - Timer Functions
    public func startBlazeTimer() {
        blazeTimer = Timer.scheduledTimer(timeInterval: (blazeTime), target: self, selector: #selector(extinguishBlaze), userInfo: nil, repeats: false)
        if(!blazeActive) {
            blazeActivationTimer = Timer.scheduledTimer(timeInterval: (remainingActivationTime), target: self, selector: #selector(makeBlazeDamaging), userInfo: nil, repeats: false)
        }
        if(!blazeActiveSelf) {
            blazeSelfActivationTimer = Timer.scheduledTimer(timeInterval: (remainingSelfActivationTime), target: self, selector: #selector(makeBlazeSelfDamaging), userInfo: nil, repeats: false)
        }
    }
    
    private func invalidateTimers() {
        blazeTimer.invalidate()
        blazeActivationTimer.invalidate()
        blazeSelfActivationTimer.invalidate()
    }
    
    // MARK: - Pause/Resume Functions
    public func pauseBlaze() {
        getRemainingTimeInTail()
        getRemainingTimeToActivation()
        getRemainingTimeToSelfActivation()
        invalidateTimers()
    }
    
    public func resumeBlaze() {
        blazeTimer = Timer.scheduledTimer(timeInterval: remainingTime, target: self, selector: #selector(extinguishBlaze), userInfo: nil, repeats: false)
    }
    
    // MARK: - Delete Function
    @objc private func extinguishBlaze() {
        blazeTimer.invalidate()
        self.removeFromSuperview()
        blazeRemoved = true
    }
    
    // MARK: - Blaze Activation Functions
    @objc private func makeBlazeSelfDamaging() {
        blazeActiveSelf = true
    }
    
    @objc private func makeBlazeDamaging() {
        blazeActive = true
    }
    
    // MARK: - Get Remaining Time Functions
    private func getRemainingTimeInTail() {
        let firstDate = blazeTimer.fireDate
        let nowDate = NSDate()
        remainingTime = (nowDate.timeIntervalSince(firstDate) * -1)
    }
    
    private func getRemainingTimeToActivation() {
        let firstDate = blazeActivationTimer.fireDate
        let nowDate = NSDate()
        remainingActivationTime = (nowDate.timeIntervalSince(firstDate) * -1)
    }
    
    private func getRemainingTimeToSelfActivation() {
        let firstDate = blazeSelfActivationTimer.fireDate
        let nowDate = NSDate()
        remainingSelfActivationTime = (nowDate.timeIntervalSince(firstDate) * -1)
    }
}
