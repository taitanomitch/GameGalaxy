//
//  TrailBlazerViewController.swift
//  GameGalaxy
//
//  Created by Mitchell Taitano on 2/4/18.
//  Copyright © 2018 Mitchell Taitano. All rights reserved.
//

import UIKit

class TrailBlazerViewController: UIViewController {

    enum ScoreLabelShowing {
        case BottomLeft
        case BottomRight
        case TopLeft
        case TopRight
    }
    
    enum Directon {
        case Left
        case Right
        case Up
        case Down
    }
    
    //IBOutlets
    @IBOutlet weak var PlayerView: UIView!
    @IBOutlet weak var BackgroundView: UIView!
    @IBOutlet weak var TopLeftScoreLabel: UILabel!
    @IBOutlet weak var TopRightScoreLabel: UILabel!
    @IBOutlet weak var BottomLeftScoreLabel: UILabel!
    @IBOutlet weak var BottomRightScoreLabel: UILabel!
    
    //Variables
    private var playerTimer: Timer = Timer()
    private var trailCreateTimer: Timer = Timer()
    private var trailIncreaseTimer: Timer = Timer()
    private var endGameDelayTimer: Timer = Timer()
    private var eatEnergyBallDelayTimer: Timer = Timer()
    private var energyBallSpawnTimer: Timer = Timer()
    private var movingDirection: Directon = Directon.Right
    private var pauseMenuIsUp: Bool = false
    private var blazeTrailViews: [TrailView] = []
    private var energyBall: UIView = UIView()
    private var collidedWithEnergyBall: Bool = false
    private var checkingEnergyBallCollision: Bool = false
    private var resuming: Bool = false
    private var scoreLabelPosition: ScoreLabelShowing = ScoreLabelShowing.TopLeft
    private var playerScore: Int = 0
    var delegate: SelectionDelegate?
    
    //Constants
    private var startingPlayerSpeed: CGFloat = 2
    private var playerSquareSpeed: CGFloat = 2
    private var recallRate: Double = 0.03
    private var trailCreationRate: Double = 0.02
    private var trailIncreaseRate: Double = 3.0
    private var energyEatDelay: Double = 0.08
    private var tailCollisionDelay: Double = 0.05
    private var blazeWidth: CGFloat = 3
    private var blazeHeight: CGFloat = 3
    private var startingBlazeTime: Double = 0.3
    private var blazeTime: Double = 0.0
    private var blazeTimeIncreaseAmount: Double = 0.05
    private var playerSpeedIncreaseAmount: CGFloat = 0.05
    private var scoreAnimationDuration: Double = 0.4
    private var graceWidth: CGFloat = 3
    
    // MARK: - Loading Functions
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpUI()
        setUpVariables()
    }
    
    
    // MARK: - SetUp Functions
    private func setUpUI() {
        PlayerView.backgroundColor = UIColor.cyan
        PlayerView.layer.masksToBounds = true
        PlayerView.layer.cornerRadius = PlayerView.frame.width / 2
        hideAllScoreLabels()
        showTopLeftScore()
    }
    
    private func setUpVariables() {
        movingDirection = Directon.Right
        blazeTime = startingBlazeTime
    }
    
    private func prepareVariables() {
        movingDirection = Directon.Right
        blazeTime = startingBlazeTime
    }
    
    private func resetToStartingPosition() {
        PlayerView.center = BackgroundView.center
    }
    
    private func resumeBlazeTrailTimers() {
        for trailview in blazeTrailViews {
            trailview.resumeBlaze()
        }
    }
    
    private func pauseBlazeTrailTimers() {
        for trailview in blazeTrailViews {
            trailview.pauseBlaze()
        }
    }
    
    private func clearPlayerBlazeTrail() {
        for trailview in blazeTrailViews {
            trailview.removeFromSuperview()
        }
        blazeTrailViews.removeAll()
    }
    
    // MARK: - Pause Functions
    public func beginGame() {
        setUpTimers()
    }
    
    public func pauseGame() {
        invalidateTimers()
        pauseBlazeTrailTimers()
    }
    
    public func resumeGame() {
        setUpTimers()
    }
    
    public func quitGame() {
        invalidateTimers()
    }
    
    @objc public func restartGame() {
        invalidateTimers()
        clearPlayerBlazeTrail()
        resetToStartingPosition()
        removeEnergyBall()
        prepareVariables()
        setPlayerScoreToZero()
        updateScoreLabel()
        showTopLeftScore()
        blazeTime = startingBlazeTime
        playerSquareSpeed = startingPlayerSpeed
    }
    
    // MARK: - Timer Functions
    private func setUpTimers() {
        addBlazeToTail()
        playerTimer = Timer.scheduledTimer(timeInterval: recallRate, target: self, selector: #selector(movePlayerInMovementDirection), userInfo: nil, repeats: true)
        trailCreateTimer = Timer.scheduledTimer(timeInterval: trailCreationRate, target: self, selector: #selector(addBlazeToTail), userInfo: nil, repeats: true)
        trailIncreaseTimer = Timer.scheduledTimer(timeInterval: trailIncreaseRate, target: self, selector: #selector(increaseBlazeTime), userInfo: nil, repeats: true)
        if(energyBall.center.x == 0) {
            energyBallSpawnTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(spawnEngergyBall), userInfo: nil, repeats: false)
        }
        resumeBlazeTrailTimers()
    }
    
    private func invalidateTimers() {
        playerTimer.invalidate()
        trailCreateTimer.invalidate()
        trailIncreaseTimer.invalidate()
        energyBallSpawnTimer.invalidate()
        endGameDelayTimer.invalidate()
        eatEnergyBallDelayTimer.invalidate()
    }
    
    // MARK: - Player Score Functions
    private func updateScoreLabel() {
        TopRightScoreLabel.text = "Score: " + String(playerScore)
        TopLeftScoreLabel.text = "Score: " + String(playerScore)
        BottomRightScoreLabel.text = "Score: " + String(playerScore)
        BottomLeftScoreLabel.text = "Score: " + String(playerScore)
    }
    
    private func increasePlayerScore() {
        playerScore = playerScore + 1
    }
    
    private func setPlayerScoreToZero() {
        playerScore = 0
    }
    
    private func decideScoreLabelLocation() {
        if(PlayerView.center.x >= BackgroundView.center.x && PlayerView.center.y >= BackgroundView.center.y) {
            if(scoreLabelPosition != ScoreLabelShowing.TopLeft) {
                showTopLeftScore()
            }
        } else if(PlayerView.center.x >= BackgroundView.center.x && PlayerView.center.y < BackgroundView.center.y) {
            if(scoreLabelPosition != ScoreLabelShowing.BottomLeft) {
                showBottomLeftScore()
            }
        } else if(PlayerView.center.x < BackgroundView.center.x && PlayerView.center.y >= BackgroundView.center.y) {
            if(scoreLabelPosition != ScoreLabelShowing.TopRight) {
                showTopRightScore()
            }
        } else {
            if(scoreLabelPosition != ScoreLabelShowing.BottomRight) {
                showBottomRightScore()
            }
        }
    }
    
    private func showBottomRightScore() {
        scoreLabelPosition = ScoreLabelShowing.BottomRight
        UIView.animate(withDuration: scoreAnimationDuration) {
            self.TopLeftScoreLabel.alpha = 0.0
            self.TopRightScoreLabel.alpha = 0.0
            self.BottomLeftScoreLabel.alpha = 0.0
            self.BottomRightScoreLabel.alpha = 1.0
        }
    }
    
    private func showBottomLeftScore() {
        scoreLabelPosition = ScoreLabelShowing.BottomLeft
        UIView.animate(withDuration: scoreAnimationDuration) {
            self.TopLeftScoreLabel.alpha = 0.0
            self.TopRightScoreLabel.alpha = 0.0
            self.BottomLeftScoreLabel.alpha = 1.0
            self.BottomRightScoreLabel.alpha = 0.0
        }
    }
    
    private func showTopRightScore() {
        scoreLabelPosition = ScoreLabelShowing.TopRight
        UIView.animate(withDuration: scoreAnimationDuration) {
            self.TopLeftScoreLabel.alpha = 0.0
            self.TopRightScoreLabel.alpha = 1.0
            self.BottomLeftScoreLabel.alpha = 0.0
            self.BottomRightScoreLabel.alpha = 0.0
        }
    }
    
    private func showTopLeftScore() {
        scoreLabelPosition = ScoreLabelShowing.TopLeft
        UIView.animate(withDuration: scoreAnimationDuration) {
            self.TopLeftScoreLabel.alpha = 1.0
            self.TopRightScoreLabel.alpha = 0.0
            self.BottomLeftScoreLabel.alpha = 0.0
            self.BottomRightScoreLabel.alpha = 0.0
        }
    }
    
    private func hideAllScoreLabels() {
        self.TopLeftScoreLabel.alpha = 0.0
        self.TopRightScoreLabel.alpha = 0.0
        self.BottomLeftScoreLabel.alpha = 0.0
        self.BottomRightScoreLabel.alpha = 0.0
    }
    
    // MARK: - Energy Ball Functions
    @objc private func spawnEngergyBall() {
        let width = self.view.frame.width - 40
        let height = self.view.frame.height - 40
        let randomX: CGFloat = CGFloat(arc4random_uniform(UInt32(width)) + 20)
        let randomY: CGFloat = CGFloat(arc4random_uniform(UInt32(height)) + 20)
        let newEnergyBall = UIView(frame: CGRect(x: randomX, y: randomY, width: 10, height: 10))
        newEnergyBall.layer.cornerRadius = newEnergyBall.frame.width/2
        newEnergyBall.layer.masksToBounds = true
        newEnergyBall.backgroundColor = UIColor.yellow
        energyBall = newEnergyBall
        collidedWithEnergyBall = false
        self.view.insertSubview(newEnergyBall, belowSubview: PlayerView)
        self.view.layoutIfNeeded()
    }
    
    private func removeEnergyBall() {
        energyBall.removeFromSuperview()
        energyBall = UIView()
    }
    
    @objc private func eatEnergyBall() {
        increasePlayerScore()
        updateScoreLabel()
        removeEnergyBall()
        playerSquareSpeed = playerSquareSpeed + playerSpeedIncreaseAmount
        beginCountdownToEnergyBall()
    }
    
    private func beginCountdownToEnergyBall() {
        energyBallSpawnTimer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(spawnEngergyBall), userInfo: nil, repeats: false)
    }
    
    private func beginLongCountdownToEnergyBall() {
        energyBallSpawnTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(spawnEngergyBall), userInfo: nil, repeats: false)
    }
    
    // MARK: - Trail Functions
    @objc private func addBlazeToTail() {
        let x = PlayerView.frame.origin.x + (PlayerView.frame.width / 2) - (blazeWidth / 2)
        let y = PlayerView.frame.origin.y + (PlayerView.frame.height / 2) - (blazeHeight / 2)
        let newTail = TrailView(frame: CGRect(x: x, y: y, width: blazeWidth, height: blazeHeight))
        newTail.setUpTrailBlaze(blazeTime: blazeTime)
        newTail.startBlazeTimer()
        newTail.layer.cornerRadius = newTail.frame.width / 2
        newTail.layer.masksToBounds = true
        blazeTrailViews.append(newTail)
        self.view.insertSubview(newTail, belowSubview: PlayerView)
        self.view.layoutIfNeeded()
        removeOldBlazesFromTail()
    }
    
    private func removeOldBlazesFromTail() {
        let newTrail = blazeTrailViews.filter { !$0.blazeRemoved }
        blazeTrailViews = newTrail
    }
    
    @objc private func increaseBlazeTime() {
        blazeTime = blazeTime + blazeTimeIncreaseAmount
    }
    
    // MARK: - Player Collision Functions
    private func checkCollisionWithEnergyBall() {
        if(!collidedWithEnergyBall && !checkingEnergyBallCollision) {
            checkingEnergyBallCollision = true
            let playerX: CGFloat = PlayerView.center.x
            let playerY: CGFloat = PlayerView.center.y
            let playerRadius: CGFloat = (PlayerView.frame.width / 2) - graceWidth
            
            let left = pow((playerRadius - energyBall.frame.width), 2)
            let right = pow((playerRadius + energyBall.frame.width), 2)
            let xx = pow((playerX - energyBall.center.x), 2)
            let yy = pow(playerY - energyBall.center.y, 2)
            let xPlusy = xx + yy
            
            if(left <= xPlusy && right >= xPlusy) {
                collidedWithEnergyBall = true
                endGameDelayTimer = Timer.scheduledTimer(timeInterval: energyEatDelay, target: self, selector: #selector(eatEnergyBall), userInfo: nil, repeats: false)
            }
        }
        checkingEnergyBallCollision = false
    }
    
    private func checkIfPlayerCollidedWithOwnTail() {
        let activeTrail = blazeTrailViews.filter { $0.blazeActiveSelf }
        let playerX: CGFloat = PlayerView.center.x
        let playerY: CGFloat = PlayerView.center.y
        let playerRadius: CGFloat = (PlayerView.frame.width / 2) - graceWidth
        for trailview in activeTrail {
            let left = pow((playerRadius - trailview.frame.width), 2)
            let right = pow((playerRadius + trailview.frame.width), 2)
            let xx = pow((playerX - trailview.center.x), 2)
            let yy = pow(playerY - trailview.center.y,2)
            let xPlusy = xx + yy
            if(left <= xPlusy && right >= xPlusy) {
                endGameDelayTimer = Timer.scheduledTimer(timeInterval: tailCollisionDelay, target: self, selector: #selector(playerDidCollideWithTail), userInfo: nil, repeats: false)
            }
        }
    }
    
    @objc private func playerDidCollideWithTail() {
        restartGame()
        resumeGame()
    }
    
    // MARK: - Player Movement Functions
    @objc private func movePlayerInMovementDirection() {
        switch movingDirection {
        case .Right:
            movePlayerRight()
        case .Left:
            movePlayerLeft()
        case .Up:
            movePlayerUp()
        case .Down:
            movePlayerDown()
        }
        checkIfPlayerCollidedWithOwnTail()
        checkCollisionWithEnergyBall()
        decideScoreLabelLocation()
    }
    
    private func movePlayerRight() {
        if(PlayerView.frame.origin.x + playerSquareSpeed < self.view.frame.width) {
            PlayerView.frame.origin.x = PlayerView.frame.origin.x + playerSquareSpeed
        } else {
            PlayerView.frame.origin.x = 0 - PlayerView.frame.width
        }
    }
    
    private func movePlayerLeft() {
        if(PlayerView.frame.origin.x - playerSquareSpeed > 0 - PlayerView.frame.width) {
            PlayerView.frame.origin.x = PlayerView.frame.origin.x - playerSquareSpeed
        } else {
            PlayerView.frame.origin.x = self.view.frame.width + PlayerView.frame.width
        }
    }
    
    private func movePlayerUp() {
        if(PlayerView.frame.origin.y - playerSquareSpeed > 0 - PlayerView.frame.height) {
            PlayerView.frame.origin.y = PlayerView.frame.origin.y - playerSquareSpeed
        } else {
            PlayerView.frame.origin.y = self.view.frame.height + PlayerView.frame.height
        }
    }
    
    private func movePlayerDown() {
        if(PlayerView.frame.origin.y + playerSquareSpeed < self.view.frame.height) {
            PlayerView.frame.origin.y = PlayerView.frame.origin.y + playerSquareSpeed
        } else {
            PlayerView.frame.origin.y = 0 - PlayerView.frame.height
        }
    }
    
    // MARK: - Button Functions
    func menuButtonPressed() {

    }
    
    func leftButtonPressed() {
        if(movingDirection == .Right) {
            playerDidCollideWithTail()
        } else {
            movingDirection = .Left
        }
    }
    
    func rightButtonPressed() {
        if(movingDirection == .Left) {
            playerDidCollideWithTail()
        } else {
            movingDirection = .Right
        }
    }
    
    func upButtonPressed() {
        if(movingDirection == .Down) {
            playerDidCollideWithTail()
        } else {
            movingDirection = .Up
        }
    }
    
    func downButtonPressed() {
        if(movingDirection == .Up) {
            playerDidCollideWithTail()
        } else {
            movingDirection = .Down
        }
    }
    
    func AButtonPressed() {

    }
    
    func BButtonPressed() {
        
    }

}
