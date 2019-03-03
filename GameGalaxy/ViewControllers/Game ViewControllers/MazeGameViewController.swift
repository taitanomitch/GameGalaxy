//
//  MazeGameViewController.swift
//  GameGalaxy
//
//  Created by Mitchell Taitano on 4/17/18.
//  Copyright © 2018 Mitchell Taitano. All rights reserved.
//

import UIKit


class MazeGameViewController: UIViewController {
    
    enum RandomDirection {
        case Up
        case Down
        case Left
        case Right
        case None
    }
    
    private var mazeGrid: [[MazeSquareView]]!
    private var mazeView: UIView!
    private var playerView: UIView!
    private var keyView: UIView!
    private var exitView: UIView!
    private var playerMazeSquare: MazeSquareView!
    private var mazeDeadEnds: [MazeSquareView]!
    private var startingSquare: MazeSquareView!
    private var keyMazeSquare: MazeSquareView!
    private var exitMazeSquare: MazeSquareView!
    
    var delegate: SelectionDelegate?
    
    public var screenWidth: CGFloat = -1
    public var screenHeight: CGFloat = -1
    private var mazeHeight: Int = 20
    private var mazeWidth: Int = 20
    private var mazeSquareWidth: CGFloat = 40
    private var playerWidth: CGFloat = 30
    private var keyWidth: CGFloat = 15
    private var exitWidth: CGFloat = 30
    private var scrollSpeed: CGFloat = 5
    private var mazeLoadingBackgroundHexColor: String  = "254299"
    
    private var screenDeltaX: CGFloat = 0
    private var screenDeltaY: CGFloat = 0
    private var startingI: Int = 0
    private var startingJ: Int = 0
    private var posI: Int = 0
    private var posJ: Int = 0
    private var currentI: Int = 0
    private var currentJ: Int = 0
    private var directionToGo: RandomDirection = .None
    private var keyFound: Bool = false
    private var exitFound: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUp()
    }
    
    //MARK: - Set Up Functions
    private func setUp() {
        currentI = startingI
        currentJ = startingJ
        screenDeltaX = 0
        screenDeltaY = 0
        keyFound = false
        exitFound = false
        directionToGo = .None
        
        initializeMaze()
        buildMaze()
        insertMaze()
        getDeadEnds()
        selectDeadEnds()
        initializePlayer()
        initializeKey()
    }
    
    private func selectDeadEnds() {
        selectDeadEndForStartingPosition()
        selectDeadEndForKey()
        selectDeadEndForExit()
    }
    
    
    // MARK: - Timer Functions
    private func setUpTimers() {

    }
    
    private func invalidateAllTimers() {

    }
    
    
    // MARK: - Pause Functions
    public func pauseGame() {
        invalidateAllTimers()
    }
    
    public func resumeGame() {

    }
    
    public func restartGame() {
        self.removeKey()
        self.removeExit()
        self.removePlayer()
        self.removeMaze()
        self.setUp()
    }
    
    public func quitGame() {
        invalidateAllTimers()
    }

    
    // MARK: - Player Functions
    private func selectDeadEndForStartingPosition() {
        let randomSpot: Int = 0
        startingSquare = mazeDeadEnds[randomSpot]
        startingI = startingSquare.iPosition
        startingJ = startingSquare.jPosition
        currentI = startingI
        currentJ = startingJ
    }
    
    private func initializePlayer() {
        posI = startingI
        posJ = startingJ
        let xPos = mazeGrid[posI][posJ].frame.midX - (playerWidth/2)
        let yPos = mazeGrid[posI][posJ].layer.frame.midY - (playerWidth/2)
        playerView = UIView(frame: CGRect(x: xPos, y: yPos, width: playerWidth, height: playerWidth))
        playerView.layer.cornerRadius = playerWidth/2
        playerView.layer.masksToBounds = true
        playerView.backgroundColor = UIColor.yellow
        mazeView.addSubview(playerView)
        playerMazeSquare = mazeGrid[posI][posJ]
    }
    
    private func removePlayer() {
        playerView.removeFromSuperview()
    }
    
    
    //MARK: - Key Functions
    private func selectDeadEndForKey() {
        var randomSpot: Int = Int(arc4random_uniform(UInt32(mazeDeadEnds.count)))
        keyMazeSquare = mazeDeadEnds[randomSpot]
        while(keyMazeSquare.iPosition == startingSquare.iPosition && keyMazeSquare.jPosition == startingSquare.jPosition) {
            randomSpot = Int(arc4random_uniform(UInt32(mazeDeadEnds.count)))
            keyMazeSquare = mazeDeadEnds[randomSpot]
        }
    }
    
    private func initializeKey() {
        let xPos = mazeGrid[keyMazeSquare.iPosition][keyMazeSquare.jPosition].frame.midX - (keyWidth/2)
        let yPos = mazeGrid[keyMazeSquare.iPosition][keyMazeSquare.jPosition].layer.frame.midY - (keyWidth/2)
        keyView = UIView(frame: CGRect(x: xPos, y: yPos, width: keyWidth, height: keyWidth))
        keyView.layer.cornerRadius = keyWidth/2
        keyView.layer.masksToBounds = true
        keyView.backgroundColor = UIColor.orange
        mazeView.addSubview(keyView)
    }
    
    private func removeKey() {
        if let kView = keyView {
            kView.removeFromSuperview()
        }
    }
    
    
    //MARK: - Exit Functions
    private func selectDeadEndForExit() {
        var randomSpot: Int = Int(arc4random_uniform(UInt32(mazeDeadEnds.count)))
        exitMazeSquare = mazeDeadEnds[randomSpot]
        while((exitMazeSquare.iPosition == startingSquare.iPosition && exitMazeSquare.jPosition == startingSquare.jPosition) || (exitMazeSquare.iPosition == keyMazeSquare.iPosition && exitMazeSquare.jPosition == keyMazeSquare.jPosition)) {
            randomSpot = Int(arc4random_uniform(UInt32(mazeDeadEnds.count)))
            exitMazeSquare = mazeDeadEnds[randomSpot]
        }
    }
    
    private func initializeExit() {
        let xPos = mazeGrid[exitMazeSquare.iPosition][exitMazeSquare.jPosition].frame.midX - (exitWidth/2)
        let yPos = mazeGrid[exitMazeSquare.iPosition][exitMazeSquare.jPosition].layer.frame.midY - (exitWidth/2)
        exitView = UIView(frame: CGRect(x: xPos, y: yPos, width: exitWidth, height: exitWidth))
        exitView.layer.cornerRadius = exitWidth/2
        exitView.layer.masksToBounds = true
        exitView.backgroundColor = UIColor.cyan
        mazeView.addSubview(exitView)
    }
    
    private func removeExit() {
        if let eView = exitView {
            eView.removeFromSuperview()
        }
    }
    
    
    //MARK: - Maze Functions
    private func initializeMaze() {
        let line = [MazeSquareView](repeating: MazeSquareView(), count:mazeWidth)
        mazeGrid = [[MazeSquareView]](repeating: line, count: mazeHeight)
        for i in 0..<mazeHeight {
            for j in 0..<mazeWidth {
                let newMazeNode = MazeSquareView()
                mazeGrid[i][j] = newMazeNode
            }
        }
    }
    
    private func insertMaze() {
        mazeView = UIView(frame: CGRect(x: 0, y: 0, width: mazeSquareWidth*CGFloat(mazeWidth) + 10, height: mazeSquareWidth*CGFloat(mazeHeight) + 10))
        mazeView.backgroundColor = UIColor.clear
        
        self.view.addSubview(mazeView)
        
        for i in 0..<mazeHeight {
            for j in 0..<mazeWidth {
                mazeGrid[i][j].frame = CGRect(x: CGFloat(j)*mazeSquareWidth + 5, y: CGFloat(i)*mazeSquareWidth + 5, width: mazeSquareWidth, height: mazeSquareWidth)
                mazeGrid[i][j].commonInit()
                mazeGrid[i][j].setUpCell()
                mazeGrid[i][j].iPosition = i
                mazeGrid[i][j].jPosition = j
                mazeView.addSubview(mazeGrid[i][j])
            }
        }
    }
    
    private func removeMaze() {
        for i in 0..<mazeHeight {
            for j in 0..<mazeWidth {
                mazeGrid[i][j].removeFromSuperview()
            }
        }
    }
    
    private func buildMaze() {
        mazeGrid[currentI][currentJ].visited = true
        let holdI = currentI
        let holdJ = currentJ
        
        var nextI: Int = -1
        var nextJ: Int = -1
        
        var canLeft: Bool = false
        var canRight: Bool = false
        var canUp: Bool = false
        var canDown: Bool = false
        
        canLeft = currentJ - 1 >= 0 && !mazeGrid[currentI][currentJ - 1].visited
        canRight = currentJ + 1 < mazeWidth && !mazeGrid[currentI][currentJ + 1].visited
        canUp = currentI - 1 >= 0 && !mazeGrid[currentI - 1][currentJ].visited
        canDown = currentI + 1 < mazeHeight && !mazeGrid[currentI + 1][currentJ].visited
        
        while(canLeft || canRight || canUp || canDown) {
            currentI = holdI
            currentJ = holdJ
            var goodPath = false
            
            canLeft = currentJ - 1 >= 0 && !mazeGrid[currentI][currentJ - 1].visited
            canRight = currentJ + 1 < mazeWidth && !mazeGrid[currentI][currentJ + 1].visited
            canUp = currentI - 1 >= 0 && !mazeGrid[currentI - 1][currentJ].visited
            canDown = currentI + 1 < mazeHeight && !mazeGrid[currentI + 1][currentJ].visited
            if(!canLeft && !canRight && !canUp && !canDown) {
                break
            }
            
            while(!goodPath) {
                getRandomDirection()
                switch directionToGo {
                case .Left:
                    if(canLeft) {
                        canLeft = false
                        nextI = currentI
                        nextJ = currentJ - 1
                        goodPath = true
                        mazeGrid[currentI][currentJ].hasLeftWall = false
                        mazeGrid[nextI][nextJ].hasRightWall = false
                    }
                case .Right:
                    if(canRight) {
                        canRight = false
                        nextI = currentI
                        nextJ = currentJ + 1
                        goodPath = true
                        mazeGrid[currentI][currentJ].hasRightWall = false
                        mazeGrid[nextI][nextJ].hasLeftWall = false
                    }
                case .Up:
                    if(canUp) {
                        canUp = false
                        nextI = currentI - 1
                        nextJ = currentJ
                        goodPath = true
                        mazeGrid[currentI][currentJ].hasTopWall = false
                        mazeGrid[nextI][nextJ].hasBottomWall = false
                    }
                case .Down:
                    if(canDown) {
                        canDown = false
                        nextI = currentI + 1
                        nextJ = currentJ
                        goodPath = true
                        mazeGrid[currentI][currentJ].hasBottomWall = false
                        mazeGrid[nextI][nextJ].hasTopWall = false
                    }
                case .None:
                    return
                }
            }
            
            currentI = nextI
            currentJ = nextJ
            buildMaze()
        }
    }
    
    private func getRandomDirection() {
        var direction: RandomDirection = .None
        let randomNum = arc4random_uniform(4)
        switch randomNum {
        case 0:
            direction = .Left
        case 1:
            direction = .Right
        case 2:
            direction = .Up
        case 3:
            direction = .Down
        default:
            direction = .None
        }
        directionToGo = direction
    }
    
    private func getDeadEnds() {
        mazeDeadEnds = [MazeSquareView]()
        for i in 0..<mazeHeight {
            for j in 0..<mazeWidth {
                if(mazeGrid[i][j].isDeadEnd()) {
                    mazeDeadEnds.append(mazeGrid[i][j])
                }
            }
        }
    }
    
    private func reorientMazeForGameStart() {
        shiftMazeHorizontally()
        shiftMazeVertically()
        
    }
    
    private func shiftMazeHorizontally() {
        if(playerView.center.x < self.view.center.x) {
            return
        } else {
            while(playerView.center.x > self.view.center.x) {
                mazeView.frame.origin.x = mazeView.frame.origin.x - scrollSpeed
                if(mazeView.frame.origin.x >= self.view.frame.width - mazeView.frame.width) {
                    mazeView.frame.origin.x = self.view.frame.width - mazeView.frame.width
                    break
                }
            }
        }
    }
    
    private func shiftMazeVertically() {
        if(playerView.center.y < self.view.center.y) {
            return
        } else {
            while(playerView.center.y > self.view.center.y) {
                mazeView.frame.origin.y = mazeView.frame.origin.y - scrollSpeed
                if(mazeView.frame.origin.y >= self.view.frame.height - mazeView.frame.height) {
                    mazeView.frame.origin.y = self.view.frame.height - mazeView.frame.height
                    break
                }
            }
        }
    }
    
    //MARK: - Movement Functions
    private func movePlayerLeft() {
        playerView.frame.origin.x = playerView.frame.origin.x - scrollSpeed
    }
    
    private func movePlayerRight() {
        playerView.frame.origin.x = playerView.frame.origin.x + scrollSpeed
    }
    
    private func movePlayerUp() {
        playerView.frame.origin.y = playerView.frame.origin.y - scrollSpeed
    }
    
    private func movePlayerDown() {
        playerView.frame.origin.y = playerView.frame.origin.y + scrollSpeed
    }
    
    private func movePlayerMazeLeft() {
        if(mazeView.frame.origin.x + scrollSpeed < 0) {
            movePlayerLeft()
            mazeView.frame.origin.x = mazeView.frame.origin.x + scrollSpeed
            screenDeltaX = screenDeltaX - scrollSpeed
        } else {
            movePlayerLeft()
            mazeView.frame.origin.x = 0
            screenDeltaX = 0
        }
    }
    
    private func movePlayerMazeRight() {
        if((mazeView.frame.origin.x + mazeView.frame.width) - scrollSpeed >= (self.view.frame.width)) {
            movePlayerRight()
            mazeView.frame.origin.x = mazeView.frame.origin.x - scrollSpeed
            screenDeltaX = screenDeltaX + scrollSpeed
        } else {
            movePlayerRight()
            screenDeltaX = screenDeltaX + (mazeView.frame.origin.x - (self.view.frame.width - mazeView.frame.width))
            mazeView.frame.origin.x = self.view.frame.width - mazeView.frame.width
        }
    }
    
    private func movePlayerMazeUp() {
        if(mazeView.frame.origin.y + scrollSpeed < 0) {
            movePlayerUp()
            mazeView.frame.origin.y = mazeView.frame.origin.y + scrollSpeed
            screenDeltaY = screenDeltaY - scrollSpeed
        } else {
            movePlayerUp()
            mazeView.frame.origin.y = 0
            screenDeltaY = 0
        }
    }
    
    private func movePlayerMazeDown() {
        if((mazeView.frame.origin.y + mazeView.frame.height) - scrollSpeed >= (self.view.frame.height)) {
            movePlayerDown()
            mazeView.frame.origin.y = mazeView.frame.origin.y - scrollSpeed
            screenDeltaY = screenDeltaY + scrollSpeed
        } else {
            movePlayerDown()
            screenDeltaY = screenDeltaY + (mazeView.frame.origin.y - (self.view.frame.height - mazeView.frame.height))
            mazeView.frame.origin.y = self.view.frame.height - mazeView.frame.height
        }
    }
    
    
    // MARK: - Button Functions
    func menuButtonPressed() {
        
    }
    
    func leftButtonPressed() {
        let center = (screenDeltaX + (screenWidth/2))
        if(((playerView.center.x < center) && (mazeView.frame.origin.x == 0)) || ((playerView.center.x > center) && (mazeView.frame.origin.x <= self.view.frame.width - mazeView.frame.width))) {
            if(playerMazeSquare.hasLeftWall) {
                if(playerView.center.x > playerMazeSquare.center.x) {
                    movePlayerLeft()
                }
            } else {
                movePlayerLeft()
            }
        } else {
            if(playerMazeSquare.hasLeftWall) {
                if(playerView.center.x > playerMazeSquare.center.x) {
                    movePlayerMazeLeft()
                }
            } else {
                movePlayerMazeLeft()
            }
        }
        if(playerView.center.x < playerMazeSquare.frame.origin.x) {
            posJ = posJ - 1
            playerMazeSquare = mazeGrid[posI][posJ]
        }
    }
    
    
    func rightButtonPressed() {
        let center = (screenDeltaX + (screenWidth/2))
        if(((playerView.center.x < center) && (mazeView.frame.origin.x == 0)) || ((playerView.center.x > center) && (mazeView.frame.origin.x <= self.view.frame.width - mazeView.frame.width))) {
            if(playerMazeSquare.hasRightWall) {
                if(playerView.center.x < playerMazeSquare.center.x) {
                    movePlayerRight()
                }
            } else {
                movePlayerRight()
            }
        } else {
            if(playerMazeSquare.hasRightWall) {
                if(playerView.center.x < playerMazeSquare.center.x) {
                    movePlayerMazeRight()
                }
            } else {
                movePlayerMazeRight()
            }
        }
        if(playerView.center.x > (playerMazeSquare.frame.origin.x + mazeSquareWidth)) {
            posJ = posJ + 1
            playerMazeSquare = mazeGrid[posI][posJ]
        }
    }
    
    
    func upButtonPressed() {
        let center = (screenDeltaY + (screenHeight/2))
        if(((playerView.center.y < center) && (mazeView.frame.origin.y == 0)) || ((playerView.center.y > center) && (mazeView.frame.origin.y <= self.view.frame.height - mazeView.frame.height))) {
            if(playerMazeSquare.hasTopWall) {
                if(playerView.center.y > playerMazeSquare.center.y) {
                    movePlayerUp()
                }
            } else {
                movePlayerUp()
            }
        } else {
            if(playerMazeSquare.hasTopWall) {
                if(playerView.center.y > playerMazeSquare.center.y) {
                    movePlayerMazeUp()
                }
            } else {
                movePlayerMazeUp()
            }
        }
        if(playerView.center.y < playerMazeSquare.frame.origin.y) {
            posI = posI - 1
            playerMazeSquare = mazeGrid[posI][posJ]
        }
    }
    
    
    func downButtonPressed() {
        let center = (screenDeltaY + (screenHeight/2))
        if(((playerView.center.y < center) && (mazeView.frame.origin.y == 0)) || ((playerView.center.y > center) && (mazeView.frame.origin.y <= self.view.frame.height - mazeView.frame.height))) {
            if(playerMazeSquare.hasBottomWall) {
                if(playerView.center.y < playerMazeSquare.center.y) {
                    movePlayerDown()
                }
            } else {
                movePlayerDown()
            }
        } else {
            if(playerMazeSquare.hasBottomWall) {
                if(playerView.center.y < playerMazeSquare.center.y) {
                    movePlayerMazeDown()
                }
            } else {
                movePlayerMazeDown()
            }
        }
        if(playerView.center.y > (playerMazeSquare.frame.origin.y + mazeSquareWidth)) {
            posI = posI + 1
            playerMazeSquare = mazeGrid[posI][posJ]
        }
    }
    
    func AButtonPressed() {
        if(keyFound && posI == exitMazeSquare.iPosition && posJ == exitMazeSquare.jPosition) {
            //AT EXIT WITH KEY
            exitFound = true
            removeExit()
        } else if(!keyFound && posI == keyMazeSquare.iPosition && posJ == keyMazeSquare.jPosition) {
            //KEY FOUND
            keyFound = true
            removeKey()
            initializeExit()
        }
    }
    
    func BButtonPressed() {
        
    }
}
