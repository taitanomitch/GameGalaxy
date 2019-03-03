//
//  BlasterGameViewController.swift
//  GameGalaxy
//
//  Created by Mitchell Taitano on 1/29/18.
//  Copyright © 2018 Mitchell Taitano. All rights reserved.
//

import UIKit


class BlasterGameViewController: UIViewController {
    
    enum EnemyMovement {
        case Dodge
        case Attack
        case Unknown
    }
    
    enum MenuOptions {
        case Continue
        case Restart
        case Quit
        case Unknown
    }
    
    //GAME IBOutlets
    @IBOutlet private weak var playerSquareView: UIView!
    @IBOutlet private weak var enemySquareView: UIView!
    @IBOutlet private weak var playerBodyView: UIView!
    @IBOutlet private weak var playerCannonView: UIView!
    @IBOutlet weak var playerLifeView: UIView!
    @IBOutlet private weak var enemyBodyView: UIView!
    @IBOutlet private weak var enemyCannonView: UIView!
    @IBOutlet weak var enemyLifeView: UIView!
    @IBOutlet private weak var reloadDot1: UIView!
    @IBOutlet private weak var reloadDot2: UIView!
    @IBOutlet private weak var reloadDot3: UIView!
    @IBOutlet private weak var playerHealthBarRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var enemyHealthBarRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topScreenView: UIView!
    @IBOutlet weak var bottomScreenView: UIView!
    
    //GAMEOVER IBOutlets
    @IBOutlet weak var gameOverMenuView: UIView!
    @IBOutlet private weak var resultLabel: UILabel!
    @IBOutlet weak var newGameCountdownLabel: UILabel!
    @IBOutlet weak var playAgainLabel: UILabel!
    
    //OTHER IBOutlets
    @IBOutlet private weak var holderView: UIView!
    
    //SelectionMenuDelegate
    public var delegate: SelectionDelegate?
    
    //Variables
    private var enemyTimer: Timer = Timer()
    private var playerShotMovementTimer: Timer = Timer()
    private var enemyShotMovementTimer: Timer = Timer()
    private var playerShotDelayTimer: Timer = Timer()
    private var enemyShotDelayTimer: Timer = Timer()
    private var enemyAIEvaluationTimer: Timer = Timer()
    private var enemyMovementEvaluationTimer: Timer = Timer()
    private var allowGameOverToCloseTimer: Timer = Timer()
    private var playerShots: [UIView] = []
    private var enemyShots: [UIView] = []
    private var playerCanShoot: Bool = true
    private var playerHitCount: CGFloat = 0
    private var playerDeadFlag = false
    private var playerHitBeingChecked = false
    private var playerStartingPosition: CGFloat = 0
    private var enemyHitCount: CGFloat = 0
    private var enemyDeadFlag = false
    private var enemyHitBeingChecked = false
    private var enemyAIChoice: EnemyMovement = EnemyMovement.Attack
    private var enemyStartingPosition: CGFloat = 0
    private var shouldReevaluateAIChoice: Bool = true
    private var enemyCanChangeDirecetion: Bool = true
    private var enemeyMovingLeft: Bool = true
    private var menuIsLoading: Bool = false
    private var menuCanBeClosed: Bool = false
    private var selectedMenuOption: MenuOptions = MenuOptions.Unknown
    private var shouldRestartGame: Bool = false
    private var gameOverMenuIsUp: Bool = false
    private var gameOverMenuCanBeClosed: Bool = false
    private var quittingGame: Bool = false
    
    //Constants
    private var aiEvaluationRate: Double = 0.20
    private var movementEvaluationRate: Double = 0.35
    private var oneSecond: Double = 1.0
    private var halfSecond: Double = 0.5
    private var recallRate: Double = 0.03
    private var reloadTime: Double = 0.3
    private var enemyReloadTime: Double = 0.53
    private var thirdReloadTime: Double = 0.1
    private var squareWidth: CGFloat = 0
    private var playerLifeWidth: CGFloat = 0
    private var enemyLifeWidth: CGFloat = 0
    private var shotsWidth: CGFloat = 2
    private var shotsHeight: CGFloat = 4
    private var shotsSpeed: CGFloat = 3
    private var playerSquareSpeed: CGFloat = 3
    private var enemySquareSpeed: CGFloat = 1.5
    private var safeDistance: CGFloat = 45
    private var enemyHealth: CGFloat = 20
    private var playerHealth: CGFloat = 3
    private var screenHeight: CGFloat = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpVariables()
        setUpUI()
        playerCanShoot = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        invalidateAllTimers()
    }
    
    
    // MARK: - SetUp
    private func setUpVariables() {
        quittingGame = false
        screenHeight = self.view.frame.height
        thirdReloadTime = reloadTime / 3
        menuCanBeClosed = false
        gameOverMenuCanBeClosed = false
        squareWidth = playerSquareView.frame.width
        playerLifeWidth = squareWidth / playerHealth
        enemyLifeWidth = squareWidth / enemyHealth
        playerStartingPosition = playerSquareView.frame.origin.x - squareWidth
        enemyStartingPosition = enemySquareView.frame.origin.x - squareWidth
    }
    
    private func setUpTimers() {
        invalidateAllTimers()
        playerShotMovementTimer = Timer.scheduledTimer(timeInterval: recallRate, target: self, selector: #selector(movePlayerShots), userInfo: nil, repeats: true)
        enemyTimer = Timer.scheduledTimer(timeInterval: recallRate, target: self, selector: #selector(moveEnemy), userInfo: nil, repeats: true)
        enemyMovementEvaluationTimer = Timer.scheduledTimer(timeInterval: movementEvaluationRate, target: self, selector: #selector(resetAIMovementBool), userInfo: nil, repeats: true)
        enemyAIEvaluationTimer = Timer.scheduledTimer(timeInterval: aiEvaluationRate, target: self, selector: #selector(resetAIEvaluationBool), userInfo: nil, repeats: true)
        enemyShotDelayTimer = Timer.scheduledTimer(timeInterval: enemyReloadTime, target: self, selector: #selector(createEnemyShot), userInfo: nil, repeats: true)
        enemyShotMovementTimer = Timer.scheduledTimer(timeInterval: recallRate, target: self, selector: #selector(moveEnemyShots), userInfo: nil, repeats: true)
    }
    
    private func setUpUI() {
        playerSquareView.layer.cornerRadius = 3.0
        playerSquareView.layer.masksToBounds = true
        enemySquareView.layer.cornerRadius = 3.0
        enemySquareView.layer.masksToBounds = true
        playerBodyView.backgroundColor = UIColor.blue
        playerCannonView.backgroundColor = UIColor.blue
        playerLifeView.backgroundColor = UIColor.cyan
        enemyBodyView.backgroundColor = UIColor.red
        enemyCannonView.backgroundColor = UIColor.red
        enemyLifeView.backgroundColor = UIColor.yellow
        if(gameOverMenuIsUp) {
            gameOverMenuView.alpha = 1.0
        } else {
            gameOverMenuView.alpha = 0.0
        }
    }
    
    // MARK: - Restart Functionality
    func restartGame() {
        shouldRestartGame = false
        enemyHitCount = 0
        enemyDeadFlag = false
        enemyCanChangeDirecetion = true
        playerCanShoot = true
        playerHitCount = 0
        playerDeadFlag = false
        playerSquareView.frame.origin.x = playerStartingPosition
        enemySquareView.frame.origin.x = enemyStartingPosition
        for shot in playerShots {
            shot.removeFromSuperview()
        }
        for shot in enemyShots {
            shot.removeFromSuperview()
        }
        playerShots = [UIView]()
        enemyShots = [UIView]()
        moveEnemyHealthBar()
        movePlayerHealthBar()
        allowPlayerToShoot()
    }
    
    // MARK: - Begin Game Function
    public func startGame() {
        setUpTimers()
    }
    
    // MARK: - Menu Functions
    public func pauseGame() {
        invalidateAllTimers()
    }
    
    public func resumeGame() {
        setUpTimers()
    }
    
    public func quitGame() {
        invalidateAllTimers()
    }
    
    // MARK: - Game Over Menu Functions
    private func prepareGameOverMenu() {
        playAgainLabel.text = "Tap 'A' to Play Again"
        if (playerDeadFlag) {
            resultLabel.text = "Defeat!"
            resultLabel.textColor = UIColor.red
        } else if (enemyDeadFlag) {
            if(playerHitCount == 0) {
                resultLabel.text = "PERFECT VICTORY!!"
            } else {
                resultLabel.text = "Victory!"
            }
            resultLabel.textColor = UIColor.cyan
        }
        resultLabel.alpha = 1.0
        newGameCountdownLabel.alpha = 0.0
        playAgainLabel.alpha = 1.0
    }
    
    private func showGameOverMenu() {
        if (!gameOverMenuIsUp) {
            gameOverMenuIsUp = true
            invalidateAllTimers()
            prepareGameOverMenu()
            UIView.animate(withDuration: 0.2, animations: {
                self.gameOverMenuView.alpha = 1.0
            })
            UIView.animate(withDuration: 0.2, animations: {
                self.gameOverMenuView.alpha = 1.0
            }, completion: { (done) in
                self.allowGameOverToCloseTimer = Timer.scheduledTimer(timeInterval: self.halfSecond, target: self, selector: #selector(self.allowGameOverMenuToClose), userInfo: nil, repeats: false)
            })
        }
    }
    
    private func closeGameOverMenu() {
        if(gameOverMenuCanBeClosed) {
            gameOverMenuCanBeClosed = false
            restartGame()
            UIView.animate(withDuration: 0.5, animations: {
                self.resultLabel.alpha = 0.0
                self.playAgainLabel.alpha = 0.0
            }) { (done) in
                self.newGameCountdownLabel.text = "3"
                self.newGameCountdownLabel.alpha = 1.0
                UIView.animate(withDuration: 0.5, animations: {
                    self.newGameCountdownLabel.alpha = 0.0
                }, completion: { (done2) in
                    self.newGameCountdownLabel.text = "2"
                    self.newGameCountdownLabel.alpha = 1.0
                    UIView.animate(withDuration: 0.5, animations: {
                        self.newGameCountdownLabel.alpha = 0.0
                    }, completion: { (done3) in
                        self.newGameCountdownLabel.text = "1"
                        self.newGameCountdownLabel.alpha = 1.0
                        UIView.animate(withDuration: 0.5, animations: {
                            self.newGameCountdownLabel.alpha = 0.0
                        }, completion: { (done4) in
                            self.hideGameOverMenu()
                        })
                    })
                })
            }
        }
    }
    
    private func hideGameOverMenu() {
        gameOverMenuView.alpha = 0.0
        gameOverMenuIsUp = false
        setUpTimers()
    }
    
    @objc private func allowGameOverMenuToClose() {
        gameOverMenuCanBeClosed = true
    }
    
    
    // MARK: - Enemy Movement
    @objc private func moveEnemy() {
        if(shouldReevaluateAIChoice) {
            determineEnemyMovement()
        }
        switch enemyAIChoice {
        case .Attack:
            moveTowardPlayer()
        case .Dodge:
            dodgeShots()
        case .Unknown:
            return
        
        }
    }
    
    private func continueEnemyMovement() {
        if(enemeyMovingLeft) {
            moveEnemyLeft()
        } else {
            moveEnemyRight()
        }
    }
    
    private func moveEnemyLeft() {
        enemeyMovingLeft = true
        if((enemySquareView.frame.origin.x) - enemySquareSpeed > 0) {
            enemySquareView.frame.origin.x = enemySquareView.frame.origin.x - enemySquareSpeed
        } else {
            enemySquareView.frame.origin.x = 0
        }
    }
    
    private func moveEnemyRight() {
        enemeyMovingLeft = false
        if((enemySquareView.frame.origin.x + enemySquareView.frame.width) + enemySquareSpeed < self.view.frame.width) {
            enemySquareView.frame.origin.x = enemySquareView.frame.origin.x + enemySquareSpeed
        } else {
            enemySquareView.frame.origin.x = self.view.frame.width - playerSquareView.frame.width
        }
    }
    
    private func moveTowardPlayer() {
        if(enemyCanChangeDirecetion) {
            enemyCanChangeDirecetion = false
            let playerCenter = playerSquareView.frame.origin.x + playerSquareView.frame.width / 2
            let enemyCenter = enemySquareView.frame.origin.x + enemySquareView.frame.width / 2
            if(playerCenter > enemyCenter) {
                moveEnemyRight()
            } else if(playerCenter < enemyCenter) {
                moveEnemyLeft()
            }
        } else {
            continueEnemyMovement()
        }
    }
    
    private func dodgeShots() {
        if(enemyCanChangeDirecetion) {
            enemyCanChangeDirecetion = false
            guard let closestShot = playerShots.first else {
                return
            }
            let shotCenter = closestShot.frame.origin.x + closestShot.frame.width / 2
            let enemyCenter = enemySquareView.frame.origin.x + enemySquareView.frame.width / 2
            if(shotCenter < enemyCenter) {
                moveEnemyRight()
            } else if(shotCenter > enemyCenter) {
                moveEnemyLeft()
            }
        } else {
            continueEnemyMovement()
        }
    }

    // MARK: - Enemy Shot Functionality
    @objc private func createEnemyShot() {
        let x = enemySquareView.frame.origin.x + enemySquareView.frame.width / 2
        let y = enemySquareView.frame.origin.y + enemySquareView.frame.height + 3
        let customView = UIView(frame: CGRect(x: x, y: y, width: shotsWidth, height: shotsHeight))
        customView.backgroundColor = UIColor.white
        self.view.addSubview(customView)
        enemyShots.append(customView)
    }
    
    @objc private func moveEnemyShots() {
        if (enemyShots.count > 0) {
            var shotsRemovedFlag = false
            var shotsRemovedCounter = 0
            for currentShot in 0..<enemyShots.count {
                let shotView = enemyShots[currentShot]
                var shotHit = false
                moveEnemyShot(shot: shotView)
                if(currentShot == 0) {
                    if(!playerHitBeingChecked) {
                        playerHitBeingChecked = true
                        if(shotView.frame.intersects(playerSquareView.frame)) {
                            shotHit = true
                            playerHit()
                        }
                        if(shotView.frame.intersects(bottomScreenView.frame) || shotHit) {
                            shotView.removeFromSuperview()
                            shotsRemovedFlag = true
                            shotsRemovedCounter = shotsRemovedCounter + 1
                        }
                        playerHitBeingChecked = false
                    }
                }
            }
            if (shotsRemovedFlag) {
                enemyShots.removeFirst(shotsRemovedCounter)
            }
        }
    }
    
    private func moveEnemyShot(shot: UIView) {
        shot.frame.origin.y = shot.frame.origin.y + shotsSpeed
    }
    
    
    // MARK: - Shot Functionality
    @objc private func allowPlayerToShoot() {
        playerShotDelayTimer.invalidate()
        playerCanShoot = true
    }
    
    private func createPlayerShot() {
        let x = playerSquareView.frame.origin.x + playerSquareView.frame.width / 2
        let y = playerSquareView.frame.origin.y - 3
        let customView = UIView(frame: CGRect(x: x, y: y, width: shotsWidth, height: shotsHeight))
        customView.backgroundColor = UIColor.white
        self.view.addSubview(customView)
        playerShots.append(customView)
    }
    
    @objc private func movePlayerShots() {
        if (playerShots.count > 0) {
            var shotsRemovedFlag = false
            var shotsRemovedCounter = 0
            for currentShot in 0..<playerShots.count {
                let shotView = playerShots[currentShot]
                var shotHit = false
                movePlayerShot(shot: shotView)
                if(currentShot == 0) {
                    if (!enemyHitBeingChecked) {
                        enemyHitBeingChecked = true
                        if(shotView.frame.intersects(enemySquareView.frame)) {
                            shotHit = true
                            enemyHit()
                        }
                        if(shotView.frame.intersects(topScreenView.frame) || shotHit) {
                            shotView.removeFromSuperview()
                            shotsRemovedFlag = true
                            shotsRemovedCounter = shotsRemovedCounter + 1
                        }
                        enemyHitBeingChecked = false
                    }
                }
            }
            if (shotsRemovedFlag) {
                playerShots.removeFirst(shotsRemovedCounter)
            }
        }
    }
    
    private func movePlayerShot(shot: UIView) {
        shot.frame.origin.y = shot.frame.origin.y - shotsSpeed
    }
    
    private func hidePlayerReloadDots() {
        reloadDot1.alpha = 0.0
        reloadDot2.alpha = 0.0
        reloadDot3.alpha = 0.0
    }
    
    private func unhidePlayerReloadDots() {
        UIView.animate(withDuration: self.thirdReloadTime, animations: {
            self.reloadDot1.alpha = 1.0
        }) { (done) in
            UIView.animate(withDuration: self.thirdReloadTime, animations: {
                self.reloadDot2.alpha = 1.0
            }, completion: { (done2) in
                UIView.animate(withDuration: self.thirdReloadTime, animations: {
                    self.reloadDot3.alpha = 1.0
                }, completion: nil)
            })
        }
    }
    
    // MARK: - Shot Hit Functionality
    private func enemyHit() {
        enemyHitCount = enemyHitCount + 1
        if(enemyHitCount >= enemyHealth) {
            enemyDeadFlag = true
            enemyHitCount = enemyHealth
        }
        moveEnemyHealthBar()
        UIView.animate(withDuration: 0.05, animations: {
            self.enemyCannonView.backgroundColor = UIColor.yellow
            self.enemyBodyView.backgroundColor = UIColor.yellow
        }, completion: { (done) in
            self.enemyCannonView.backgroundColor = UIColor.red
            self.enemyBodyView.backgroundColor = UIColor.red
        })
        if(enemyDeadFlag) {
            showGameOverMenu()
        }
    }
    
    private func playerHit() {
        playerHitCount = playerHitCount + 1
        if(playerHitCount >= playerHealth) {
            playerDeadFlag = true
            playerHitCount = playerHealth
        }
        movePlayerHealthBar()
        UIView.animate(withDuration: 0.05, animations: {
            self.playerCannonView.backgroundColor = UIColor.white
            self.playerBodyView.backgroundColor = UIColor.white
        }, completion: { (done) in
            self.playerCannonView.backgroundColor = UIColor.blue
            self.playerBodyView.backgroundColor = UIColor.blue
        })
        if(playerDeadFlag) {
            showGameOverMenu()
        }
    }
    
    // MARK: - Health Bars Functionality
    private func moveEnemyHealthBar() {
        enemyHealthBarRightConstraint.constant = enemyLifeWidth * enemyHitCount
        enemyLifeView.layoutIfNeeded()
    }
    
    private func movePlayerHealthBar() {
        playerHealthBarRightConstraint.constant = playerLifeWidth * playerHitCount
        playerLifeView.layoutIfNeeded()
    }
    
    // MARK: - Player Movement Functions
    private func movePlayerLeft() {
        if((playerSquareView.frame.origin.x) - playerSquareSpeed > 0) {
            playerSquareView.frame.origin.x = playerSquareView.frame.origin.x - playerSquareSpeed
        } else {
            playerSquareView.frame.origin.x = 0
        }
    }
    
    private func movePlayerRight() {
        if((playerSquareView.frame.origin.x + playerSquareView.frame.width) + playerSquareSpeed < self.view.frame.width) {
            playerSquareView.frame.origin.x = playerSquareView.frame.origin.x + playerSquareSpeed
        } else {
            playerSquareView.frame.origin.x = self.view.frame.width - playerSquareView.frame.width
        }
    }
    
    
    // MARK: - Button Functions
    func menuButtonPressed() {
       
    }
    
    func leftButtonPressed() {
        if(!gameOverMenuIsUp && !quittingGame) {
            movePlayerLeft()
        }
    }
    
    func rightButtonPressed() {
        if(!gameOverMenuIsUp && !quittingGame) {
            movePlayerRight()
        }
    }
    
    func upButtonPressed() {
        
    }
    
    func downButtonPressed() {

    }
    
    func AButtonPressed() {
        if(!quittingGame) {
            if (gameOverMenuIsUp) {
                closeGameOverMenu()
            } else {
                if(playerCanShoot && !gameOverMenuIsUp) {
                    playerCanShoot = false
                    createPlayerShot()
                    playerShotDelayTimer = Timer.scheduledTimer(timeInterval: reloadTime, target: self, selector: #selector(allowPlayerToShoot), userInfo: nil, repeats: false)
                    hidePlayerReloadDots()
                    unhidePlayerReloadDots()
                }
            }
        }
    }
    
    func BButtonPressed() {

    }

    // MARK: - Enemy AI Functions
    private func determineEnemyMovement() {
        shouldReevaluateAIChoice = false
        guard let closestShot = playerShots.first else {
            enemyAIChoice = EnemyMovement.Attack
            return
        }
        let distance = getDistance(view1: enemySquareView, view2: closestShot)
        if(distance > safeDistance) {
            enemyAIChoice = EnemyMovement.Attack
        } else {
            enemyAIChoice = EnemyMovement.Dodge
        }
    }
    
    @objc private func resetAIEvaluationBool() {
        shouldReevaluateAIChoice = true
    }
    
    @objc private func resetAIMovementBool() {
        enemyCanChangeDirecetion = true
    }
    
    // MARK: - Utility Functions
    public func getGameOverIsUp() -> Bool {
        return gameOverMenuIsUp
    }
    
    private func getDistance(view1: UIView, view2: UIView) -> CGFloat {
        let x1 = view1.frame.origin.x + view1.frame.width / 2
        let y1 = view1.frame.origin.y + view1.frame.height / 2
        let x2 = view2.frame.origin.x + view2.frame.width / 2
        let y2 = view2.frame.origin.y + view2.frame.height / 2
        return (pow((x2 - x1), 2) + pow((y2 - y1), 2)).squareRoot()
    }
    
    private func invalidateAllTimers() {
        enemyTimer.invalidate()
        playerShotMovementTimer.invalidate()
        enemyShotMovementTimer.invalidate()
        playerShotDelayTimer.invalidate()
        enemyShotDelayTimer.invalidate()
        enemyAIEvaluationTimer.invalidate()
        enemyMovementEvaluationTimer.invalidate()
        allowGameOverToCloseTimer.invalidate()
    }
    
    private func restoreAllShots() {
        for shot in enemyShots {
            shot.alpha = 1.0
        }
        for shot in playerShots {
            shot.alpha = 1.0
        }
    }
    
    private func dimAllShotsForMenu() {
        for shot in enemyShots {
            shot.alpha = 0.4
        }
        for shot in playerShots {
            shot.alpha = 0.4
        }
    }
}
