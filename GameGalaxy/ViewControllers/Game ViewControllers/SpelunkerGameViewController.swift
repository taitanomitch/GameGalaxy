//
//  SpelunkerGameViewController.swift
//  GameGalaxy
//
//  Created by Mitchell Taitano on 5/14/18.
//  Copyright © 2018 Mitchell Taitano. All rights reserved.
//

import UIKit

class SpelunkerGameViewController: UIViewController {
    
    // MARK: - Variables
    private var playerView: UIView!
    private var caveViews: [CaveTileView]!
    private var caveCoinViews: [UIView]!
    
    var delegate: SelectionDelegate?
    
    private var caveTileSpawnTimer: Timer = Timer()
    private var caveTileMovementTimer: Timer = Timer()
    private var caveCoinMovementTimer: Timer = Timer()
    private var increaseCaveSpeedTimer: Timer = Timer()
    private var reduceCaveHeightTimer: Timer = Timer()
    
    private var remainingTimeToCaveTileSpawn: Double = -1
    private var remainingTimeUntilCaveMovement: Double = -1
    private var remainingTimeToIncreaseCaveSpeed: Double = -1
    private var remainingTimeToChangeCaveHeight: Double = -1
    
    private var playerWidth: CGFloat = 10
    private var playerHeight: CGFloat = 10
    private var playerStartingX: CGFloat = 30
    private var playerMovementSpeed: CGFloat = 2
    
    private var startingCaveTileMovementSpeed: Double = 7
    private var startingCavePathHeight: CGFloat = 100
    private var startingCavePathOffset: CGFloat = 0
    
    private var recallRate: Double = 0.03
    private var tileSpawnRate: Double = 0.060
    
    private var caveViewWidth: CGFloat = 15
    private var caveCoinWidth: CGFloat = 7
    
    private var caveTileSpeedIncreaseAmount: Double = 0.5
    private var cavePathOffsetChangeAmount: CGFloat = 2.5
    private var cavePathHeightChangeAmount: CGFloat = 8
    
    private var caveSpeedIncreaseRate: Double = 10
    private var caveHeightChangeRate: Double = 1
    
    private var maximumCavePathHeight: CGFloat = 120
    private var minimumCavePathHeight: CGFloat = 60
    private var maximumCaveSpeed: Double = 7
    private var cavePathBufferSpaceSize: CGFloat = 20
    private var pathShiftingDelay: Int = 80
    private var caveCoinSpawnCounter: Int = 0
    
    private var shouldReduceCaveHeight: Bool = true
    private var cavePathMovingDown: Bool = false
    private var cavePathDirectionChosen: Bool = false
    private var collidedWithCaveCoin: Bool = false
    private var checkingCaveCoinCollision: Bool = false
    
    private var score: Int = -1
    private var caveTilesSpawned: Int = -1
    private var caveTileSpawnTime: Double = -1
    private var caveTileMovementSpeed: Double = -1
    private var cavePathOffset: CGFloat = -1
    private var cavePathHeight: CGFloat = -1
    private var screenWidth: CGFloat = -1
    private var screenHeight: CGFloat = -1

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUp()
    }
    
    
    // MARK: - Set Up Functions
    private func setUp() {
        caveViews = [CaveTileView]()
        caveCoinViews = [UIView]()
        screenWidth = self.view.frame.width
        screenHeight = self.view.frame.height
        cavePathHeight = startingCavePathHeight
        cavePathOffset = startingCavePathOffset
        caveTileMovementSpeed = startingCaveTileMovementSpeed
        resetScore()
        caveTilesSpawned = 0
        caveCoinSpawnCounter = 0
        caveTileSpawnTime = tileSpawnRate
        cavePathDirectionChosen = false
        chooseInitialPathDirection()
        spawnCaveTile()
        spawnPlayer()
    }
    
    
    // MARK: - Timer Functions
    private func setUpTimers() {
//        caveTileSpawnTimer = Timer.scheduledTimer(timeInterval: caveTileSpawnTime, target: self, selector: #selector(spawnCaveTile), userInfo: nil, repeats: true)
        caveTileMovementTimer = Timer.scheduledTimer(timeInterval: recallRate, target: self, selector: #selector(moveCaveTiles), userInfo: nil, repeats: true)
        caveCoinMovementTimer = Timer.scheduledTimer(timeInterval: recallRate, target: self, selector: #selector(moveCaveCoins), userInfo: nil, repeats: true)
//        increaseCaveSpeedTimer = Timer.scheduledTimer(timeInterval: caveSpeedIncreaseRate, target: self, selector: #selector(increaseCaveSpeed), userInfo: nil, repeats: true)
        reduceCaveHeightTimer = Timer.scheduledTimer(timeInterval: caveHeightChangeRate, target: self, selector: #selector(changeCavePathHeight), userInfo: nil, repeats: true)
    }
    
    private func invalidateAllTimers() {
        caveTileSpawnTimer.invalidate()
        caveTileMovementTimer.invalidate()
        caveCoinMovementTimer.invalidate()
        increaseCaveSpeedTimer.invalidate()
        reduceCaveHeightTimer.invalidate()
    }
    
    private func resumeTimers() {
        
    }
    
    
    // MARK: - Cave Tile Functions
    @objc private func spawnCaveTile() {
        let newCaveTile = CaveTileView()
        if(caveViews.count > 0) {
            let x = caveViews[caveViews.count-1].frame.origin.x
            let y = caveViews[caveViews.count-1].frame.origin.y
            newCaveTile.frame = CGRect(x: x + caveViewWidth, y: y, width: caveViewWidth, height: screenHeight)
        } else {
            newCaveTile.frame = CGRect(x: screenWidth, y: 0, width: caveViewWidth, height: screenHeight)
        }
        
        newCaveTile.setup(height: cavePathHeight, offset: cavePathOffset)
        
        caveViews.append(newCaveTile)
        self.view.addSubview(newCaveTile)
        if let player = playerView {
            self.view.bringSubview(toFront: player)
            self.view.setNeedsLayout()
        }
        
        caveCoinSpawnCounter = caveCoinSpawnCounter + 1
        caveCoinSpawnCounter = caveCoinSpawnCounter % 10
        if(caveCoinSpawnCounter == 0) {
            spawnCaveCoin(caveTile:newCaveTile , height: cavePathHeight, offset: cavePathOffset)
        } else if(caveCoinSpawnCounter == 5) {
            collidedWithCaveCoin = false
        }
        
        if(caveTilesSpawned > pathShiftingDelay) {
            changeCaveOffset()
        } else {
            caveTilesSpawned = caveTilesSpawned + 1
        }
    }
    
    private func despawnCaveTiles() {
        for caveTile in caveViews {
            caveTile.removeFromSuperview()
        }
        caveViews = [CaveTileView]()
    }
    
    @objc private func moveCaveTiles() {
        for tile in caveViews {
            tile.frame.origin.x = tile.frame.origin.x - CGFloat(caveTileMovementSpeed)
            if(tile.frame.origin.x + CGFloat(caveViewWidth) + 5 < 0) {
                tile.removeFromSuperview()
                tile.shouldBeRemoved = true
            }
        }
        checkPlayerCollisionWithWall()
        if(caveViews.count > 0) {
            if(caveViews[caveViews.count-1].frame.origin.x <= screenWidth + (caveViewWidth*2)) {
                spawnCaveTile()
            }
        }
        caveViews = caveViews.filter { (caveTile) -> Bool in
            !caveTile.shouldBeRemoved
        }
    }
    
    @objc private func increaseCaveSpeed() {
        caveTileMovementSpeed = caveTileMovementSpeed + caveTileSpeedIncreaseAmount
        if(caveTileMovementSpeed >= maximumCaveSpeed) {
            caveTileMovementSpeed = maximumCaveSpeed
        }
        caveTileSpawnTime = (Double(caveViewWidth) / caveTileMovementSpeed) * recallRate
        caveTileSpawnTimer.invalidate()
        caveTileSpawnTimer = Timer.scheduledTimer(timeInterval: caveTileSpawnTime, target: self, selector: #selector(spawnCaveTile), userInfo: nil, repeats: true)
        caveTileSpawnTimer.fire()
    }
    
    private func changeCaveOffset() {
        let randomNumber = arc4random_uniform(3) + 1
        if(cavePathMovingDown && randomNumber == 1) {
            cavePathMovingDown = false
        } else if(!cavePathMovingDown && randomNumber == 1) {
            cavePathMovingDown = true
        }
        
        if(cavePathOffset.magnitude + (cavePathHeight/2) + cavePathBufferSpaceSize >= (screenHeight/2)) {
            if(cavePathOffset > 0) {
                cavePathMovingDown = false
                movePathUp()
            } else {
                cavePathMovingDown = true
                movePathDown()
            }
        } else if(cavePathMovingDown) {
            movePathDown()
        } else {
            movePathUp()
        }
    }
    
    private func movePathUp() {
        cavePathOffset = cavePathOffset - cavePathOffsetChangeAmount
        cavePathMovingDown = false
    }
    
    private func movePathDown() {
        cavePathOffset = cavePathOffset + cavePathOffsetChangeAmount
        cavePathMovingDown = true
    }
    
    private func chooseInitialPathDirection() {
        let randomNumber = arc4random_uniform(2) + 1
        if(randomNumber == 1) {
            cavePathMovingDown = false
        } else {
            cavePathMovingDown = true
        }
    }
    
    @objc private func changeCavePathHeight() {
        decideCaveHeightIncreaseOrDecrease()
        if(shouldReduceCaveHeight) {
            cavePathHeight = cavePathHeight - cavePathHeightChangeAmount
            if(cavePathHeight <= minimumCavePathHeight) {
                cavePathHeight = minimumCavePathHeight
            }
        } else {
            cavePathHeight = cavePathHeight + cavePathHeightChangeAmount
            if(cavePathHeight >= maximumCavePathHeight) {
                cavePathHeight = maximumCavePathHeight
            }
        }
    }
    
    private func decideCaveHeightIncreaseOrDecrease() {
        let randomNumber = arc4random_uniform(3) + 1
        if(randomNumber == 1) {
            shouldReduceCaveHeight = false
        } else {
            shouldReduceCaveHeight = true
        }
    }
    
    // MARK: - Cave Coin Functions
    private func spawnCaveCoin(caveTile: CaveTileView, height: CGFloat, offset: CGFloat) {
        let lowerBound: CGFloat = (caveTile.frame.height / 2) + offset - (height / 2) + 10
        let upperBound: CGFloat = (caveTile.frame.height / 2) + offset + (height / 2) - 10
        let randomPercent: CGFloat = CGFloat(arc4random_uniform(100)) / 100
        let x: CGFloat = caveTile.center.x
        let y: CGFloat = lowerBound + ((upperBound - lowerBound) * randomPercent)
        let nextCaveCoin = UIView(frame: CGRect(x: x, y: y, width: caveCoinWidth, height: caveCoinWidth))
        nextCaveCoin.layer.cornerRadius = caveCoinWidth / 2
        nextCaveCoin.layer.masksToBounds = true
        nextCaveCoin.backgroundColor = UIColor.yellow
        
        caveCoinViews.append(nextCaveCoin)
        self.view.addSubview(nextCaveCoin)
        if let player = playerView {
            self.view.bringSubview(toFront: player)
            self.view.setNeedsLayout()
        }
    }
    
    private func despawnCaveCoins() {
        for coin in caveCoinViews {
            coin.removeFromSuperview()
        }
        caveCoinViews = [UIView]()
    }
    
    @objc private func moveCaveCoins() {
        for coin in caveCoinViews {
            coin.frame.origin.x = coin.frame.origin.x - CGFloat(caveTileMovementSpeed)
            if(coin.frame.origin.x + CGFloat(caveCoinWidth) + 5 < 0) {
                coin.removeFromSuperview()
            }
        }
        checkPlayerCollisionWithCaveCoin()
        caveCoinViews = caveCoinViews.filter { (caveCoin) -> Bool in
            !(caveCoin.frame.origin.x + CGFloat(caveCoinWidth) + 5 < 0)
        }
    }
    
    private func increaseScore() {
        score = score + 1
    }
    
    private func resetScore() {
        score = 0
    }
    
    
    // MARK: - Player Functions
    private func spawnPlayer() {
        let x: CGFloat = playerStartingX
        let y: CGFloat = screenHeight / 2
        playerView = UIView(frame: CGRect(x: x, y: y, width: playerWidth, height: playerHeight))
        playerView.layer.cornerRadius = playerView.frame.width / 2
        playerView.layer.masksToBounds = true
        playerView.backgroundColor = UIColor.black
        self.view.addSubview(playerView)
    }
    
    private func despawnPlayer() {
        playerView.removeFromSuperview()
        playerView = UIView()
    }
    
    private func checkPlayerCollisionWithWall() {
        let playerViewLeft = playerView.frame.origin.x
        let playerViewRight = playerViewLeft + playerWidth
        for tile in caveViews {
            let tileLeft = tile.frame.origin.x
            let tileRight = tileLeft + caveViewWidth
            if(tileLeft < playerViewRight && tileRight > playerViewLeft) {
                if((playerView.frame.origin.y < (tile.CeilingView.frame.origin.y + tile.CeilingView.frame.height)) || ((playerView.frame.origin.y + playerHeight) > tile.FloorView.frame.origin.y)) {
                }
            }
        }
    }
    
    private func checkPlayerCollisionWithCaveCoin() {
        if(!collidedWithCaveCoin && !checkingCaveCoinCollision) {
            checkingCaveCoinCollision = true
            for coin in caveCoinViews {
                let playerX: CGFloat = playerView.center.x
                let playerY: CGFloat = playerView.center.y
                let playerRadius: CGFloat = (playerView.frame.width / 2) - 1
                
                let left = pow((playerRadius - coin.frame.width), 2)
                let right = pow((playerRadius + coin.frame.width), 2)
                let xx = pow((playerX - coin.center.x), 2)
                let yy = pow(playerY - coin.center.y, 2)
                let xPlusy = xx + yy
                
                if(left <= xPlusy && right >= xPlusy) {
                    increaseScore()
                    coin.removeFromSuperview()
                }
            }
        }
        checkingCaveCoinCollision = false
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
    
    public func restartGame() {
        despawnCaveTiles()
        despawnCaveCoins()
        despawnPlayer()
        setUp()
    }

    
    // MARK: - Button Functions
    func menuButtonPressed() {
        
    }
    
    func leftButtonPressed() {

    }
    
    func rightButtonPressed() {

    }
    
    func upButtonPressed() {
        playerView.frame.origin.y = playerView.frame.origin.y - 2
    }
    
    func downButtonPressed() {
        playerView.frame.origin.y = playerView.frame.origin.y + 2
    }
    
    func AButtonPressed() {
        
    }
    
    func BButtonPressed() {
        
    }
}
