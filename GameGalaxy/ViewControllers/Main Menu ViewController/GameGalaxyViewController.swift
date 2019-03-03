//
//  ViewController.swift
//  GameGalaxy
//
//  Created by Mitchell Taitano on 1/5/18.
//  Copyright © 2018 Mitchell Taitano. All rights reserved.
//

import UIKit

class GameGalaxyViewController: UIViewController, SelectionDelegate {
    
    enum Games {
        case Menu
        case BlasterGame
        case AdventureGame
        case TrailBlazerGame
        case MazeGame
        case SpelunkerGame
        case Unknown
    }
    
    enum MenuOptions {
        case Continue
        case Restart
        case Quit
        case Unknown
    }
    
    //Background
    @IBOutlet weak var BackgroundView: UIView!
    
    //IBOutlets for GameGalaxyScreen
    @IBOutlet weak var ScreenContainerView: UIView!
    @IBOutlet weak var MenusView: UIView!
    @IBOutlet weak var pausedLabel: UILabel!
    @IBOutlet weak var continueLabel: UILabel!
    @IBOutlet weak var restartLabel: UILabel!
    @IBOutlet weak var quitLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var MazeLoadingView: UIView!
    @IBOutlet weak var MazeLoadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var BuildingMazeLabel: UILabel!
    
    //IBOutlets for GameGalaxy Appearance
    @IBOutlet weak var UpperView: UIView!
    @IBOutlet weak var BottomRightView: UIView!
    @IBOutlet weak var BottomLeftView: UIView!
    
    //GameGalaxy Buttons
    @IBOutlet weak var UpButton: UIButton!
    @IBOutlet weak var RightButton: UIButton!
    @IBOutlet weak var DownButton: UIButton!
    @IBOutlet weak var LeftButton: UIButton!
    @IBOutlet weak var AButton: UIButton!
    @IBOutlet weak var BButton: UIButton!
    @IBOutlet weak var MenuButton: UIButton!
    @IBOutlet weak var ArrowButtonVerticalBackground: UIView!
    @IBOutlet weak var ArrowButtonHorizontalBackground: UIView!
    
    //Variables
    var ActiveScreen: Games = Games.Unknown
    var GalaxyNavigationController: GalaxyNavigationController?
    var SelectionMenuViewController: SelectionMenuViewController?
    var BlasterGameViewController: BlasterGameViewController?
    var AdventureGameViewController: AdventureViewController?
    var TrailBlazerViewController: TrailBlazerViewController?
    var MazeGameViewController: MazeGameViewController?
    var SpelunkerGameViewController: SpelunkerGameViewController?
    var leftButtonIsDown: Bool = false
    var rightButtonIsDown: Bool = false
    var upButtonIsDown: Bool = false
    var downButtonIsDown: Bool = false
    var timer: Timer = Timer()
    var pauseMenuIsUp: Bool = false
    var selectedMenuOption: MenuOptions = .Unknown
    var menuCanBeClosed: Bool = false
    var gameOverScreenCanBeClosed: Bool = false
    var shouldRestartGame: Bool = false
    var startingGame: Bool = false
    
    //Constants
    var recallRate: Double = 0.03
    private var mazeLoadingBackgroundHexColor: String  = "254299"
    
     // MARK: - Loading Functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpUI()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        getViewControllerValues()
        setUpButtonFunctionalities()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let galaxyNavigationontroller as GalaxyNavigationController:
            self.GalaxyNavigationController = galaxyNavigationontroller
        default:
            break
        }
    }
    
    // MARK: - Setup
    func setUpUI() {
        prepareMenu()
        hideMenu()
        countdownLabel.alpha = 0.0
        UpperView.layer.cornerRadius = 10.0
        UpperView.layer.masksToBounds = true
        BottomRightView.layer.cornerRadius = 40.0
        BottomRightView.layer.masksToBounds = true
        BottomLeftView.layer.cornerRadius = 10.0
        BottomLeftView.layer.masksToBounds = true
        
        BackgroundView.backgroundColor = Utilities.hexUIColor(hex: Utilities.Colors_GameGalaxy.GameGalaxyBlack.rawValue)
        MazeLoadingView.backgroundColor = Utilities.hexUIColor(hex: mazeLoadingBackgroundHexColor)
        BuildingMazeLabel.textColor = UIColor.white
        
        UpperView.backgroundColor = Utilities.hexUIColor(hex: Utilities.Colors_GameGalaxy.GameGalaxyWhite.rawValue)
        BottomRightView.backgroundColor = Utilities.hexUIColor(hex: Utilities.Colors_GameGalaxy.GameGalaxyWhite.rawValue)
        BottomLeftView.backgroundColor = Utilities.hexUIColor(hex: Utilities.Colors_GameGalaxy.GameGalaxyWhite.rawValue)
        
        MenusView.layer.masksToBounds = true
        MenuButton.layer.cornerRadius = 3.0
        MenuButton.layer.masksToBounds = true
        ArrowButtonVerticalBackground.layer.masksToBounds = true
        ArrowButtonVerticalBackground.layer.cornerRadius = 3.0
        ArrowButtonHorizontalBackground.layer.masksToBounds = true
        ArrowButtonHorizontalBackground.layer.cornerRadius = 3.0
        MazeLoadingView.layer.cornerRadius = 4.0
        MazeLoadingView.layer.masksToBounds = true
        
        AButton.layer.cornerRadius = AButton.frame.width / 2
        AButton.layer.masksToBounds = true
        BButton.layer.cornerRadius = BButton.frame.width / 2
        BButton.layer.masksToBounds = true
    }
    
    func setUpButtonFunctionalities() {
        MenuButton.addTarget(self, action: #selector(MenuButtonPressed), for: .touchUpInside)
        AButton.addTarget(self, action: #selector(AButtonPressed), for: .touchUpInside)
        BButton.addTarget(self, action: #selector(BButtonPressed), for: .touchUpInside)
        LeftButton.addTarget(self, action: #selector(leftButtonDown(sender:)), for: .touchDown)
        LeftButton.addTarget(self, action: #selector(leftButtonUp(sender:)), for: [.touchUpInside, .touchUpOutside])
        RightButton.addTarget(self, action: #selector(rightButtonDown(sender:)), for: .touchDown)
        RightButton.addTarget(self, action: #selector(rightButtonUp(sender:)), for: [.touchUpInside, .touchUpOutside])
        UpButton.addTarget(self, action: #selector(upButtonDown(sender:)), for: .touchDown)
        UpButton.addTarget(self, action: #selector(upButtonUp(sender:)), for: [.touchUpInside, .touchUpOutside])
        DownButton.addTarget(self, action: #selector(downButtonDown(sender:)), for: .touchDown)
        DownButton.addTarget(self, action: #selector(downButtonUp(sender:)), for: [.touchUpInside, .touchUpOutside])
    }
    
    func getViewControllerValues() {
        guard let selectionMenu = GalaxyNavigationController?.viewControllers.first as? SelectionMenuViewController else {
            return
        }
        self.SelectionMenuViewController = selectionMenu
        selectionMenu.delegate = self
        ActiveScreen = Games.Menu
    }
    
    // MARK: - SelectionDelegate Functions
    func showMenuView() {
        showMenu()
    }
    
    func selectedGame(game: GameGalaxyViewController.Games, viewController: UIViewController) {
        ActiveScreen = game
        switch game {
        case .BlasterGame:
            guard let blasterGame = viewController as? BlasterGameViewController else {
                return
            }
            BlasterGameViewController = blasterGame
            BlasterGameViewController?.delegate = self
            startGame()
        case .AdventureGame:
            guard let adventureGame = viewController as? AdventureViewController else {
                return
            }
            AdventureGameViewController = adventureGame
            AdventureGameViewController?.delegate = self
            startGame()
        case .TrailBlazerGame:
            guard let trailerBlazerGame = viewController as? TrailBlazerViewController else {
                return
            }
            TrailBlazerViewController = trailerBlazerGame
            TrailBlazerViewController?.delegate = self
            startGame()
        case .MazeGame:
            guard let mazeGame = viewController as? MazeGameViewController else {
                return
            }
            MazeGameViewController = mazeGame
            MazeGameViewController?.delegate = self
            startGame()
        case .SpelunkerGame:
            guard let spelunkerGame = viewController as? SpelunkerGameViewController else {
                return
            }
            SpelunkerGameViewController = spelunkerGame
            SpelunkerGameViewController?.delegate = self
            startGame()
        case .Menu:
            return
        case .Unknown:
            return
        }

    }
    
    // MARK: - Pause Menu Functionality
    func prepareMenu() {
        selectedMenuOption = MenuOptions.Unknown
        countdownLabel.alpha = 0.0
        pausedLabel.alpha = 0.0
        MazeLoadingView.alpha = 0.0
        hideMenuOptions()
        self.pausedLabel.text = "PAUSED"
        shouldRestartGame = false
    }
    
    func prepareToShowMenu() {
        selectedMenuOption = MenuOptions.Continue
        countdownLabel.alpha = 0
        setMenuOptionsAppearance()
        pausedLabel.alpha = 1.0
    }
    
    func prepareMenuForGameStart() {
        continueLabel.alpha = 0.0
        restartLabel.alpha = 0.0
        quitLabel.alpha = 0.0
        pausedLabel.alpha = 0.0
    }
    
    func showMenu() {
        MenusView.alpha = 1.0
    }
    
    func hideMenu() {
        MenusView.alpha = 0.0
    }
    
    func setMenuOptionsAppearance() {
        switch selectedMenuOption {
        case .Continue:
            continueLabel.alpha = 1.0
            restartLabel.alpha = 0.5
            quitLabel.alpha = 0.5
        case .Restart:
            continueLabel.alpha = 0.5
            restartLabel.alpha = 1.0
            quitLabel.alpha = 0.5
        case .Quit:
            continueLabel.alpha = 0.5
            restartLabel.alpha = 0.5
            quitLabel.alpha = 1.0
        case .Unknown:
            return
        }
    }
    
    func hideMenuOptions() {
        continueLabel.alpha = 0.0
        restartLabel.alpha = 0.0
        quitLabel.alpha = 0.0
        pausedLabel.alpha = 0.0
    }
    
    func beginCountDown() {
        menuCanBeClosed = false
        startingGame = true
        if(shouldRestartGame) {
            restartGame()
        }
        UIView.animate(withDuration: 0.5, animations: {
            self.hideMenuOptions()
        }) { (done) in
            self.countdownLabel.text = "3"
            self.countdownLabel.alpha = 1.0
            UIView.animate(withDuration: 0.5, animations: {
                self.countdownLabel.alpha = 0.0
            }, completion: { (done2) in
                self.countdownLabel.text = "2"
                self.countdownLabel.alpha = 1.0
                UIView.animate(withDuration: 0.5, animations: {
                    self.countdownLabel.alpha = 0.0
                }, completion: { (done3) in
                    self.countdownLabel.text = "1"
                    self.countdownLabel.alpha = 1.0
                    UIView.animate(withDuration: 0.5, animations: {
                        self.countdownLabel.alpha = 0.0
                    }, completion: { (done4) in
                        UIView.animate(withDuration: 0.2, animations: {
                            self.hideMenu()
                        }, completion: { (done5) in
                            if(!self.shouldRestartGame) {
                                self.continueGame()
                            }
                            self.pauseMenuIsUp = false
                            self.startingGame = false
                        })
                    })
                })
            })
        }
    }
    
    private func animateSelectedMenuOption() {
        switch selectedMenuOption {
        case .Continue:
            UIView.animate(withDuration: 0.2, animations: {
                self.continueLabel.alpha = 1.0
                self.restartLabel.alpha = 0.5
                self.quitLabel.alpha = 0.5
            })
        case .Restart:
            UIView.animate(withDuration: 0.2, animations: {
                self.continueLabel.alpha = 0.5
                self.restartLabel.alpha = 1.0
                self.quitLabel.alpha = 0.5
            })
        case .Quit:
            UIView.animate(withDuration: 0.2, animations: {
                self.continueLabel.alpha = 0.5
                self.restartLabel.alpha = 0.5
                self.quitLabel.alpha = 1.0
            })
        case .Unknown:
            return
        }
    }
    
    // MARK: - Maze Loading Functionality
    private func hideMazeLoadingView() {
        self.MazeLoadingView.alpha = 0.0
    }
    
    private func showMazeLoadingView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.MazeLoadingView.alpha = 1.0
        }) { (done) in
            self.MazeGameViewController?.restartGame()
            self.hideMazeLoadingView()
        }
    }
    
    // MARK: - Menu Commands
    func startGame() {
        prepareMenuForGameStart()
        showMenu()
        beginCountDown()
    }
    
    func continueGame() {
        switch ActiveScreen {
        case .BlasterGame:
            BlasterGameViewController?.resumeGame()
        case .AdventureGame:
            AdventureGameViewController?.resumeGame()
        case .TrailBlazerGame:
            TrailBlazerViewController?.resumeGame()
        case .MazeGame:
            return
        case .SpelunkerGame:
            SpelunkerGameViewController?.resumeGame()
        case .Menu:
            return
        case .Unknown:
            return
        }
    }
    
    func restartGame() {
        switch ActiveScreen {
        case .BlasterGame:
            BlasterGameViewController?.restartGame()
        case .AdventureGame:
            AdventureGameViewController?.restartGame()
        case .TrailBlazerGame:
            TrailBlazerViewController?.restartGame()
        case .MazeGame:
            showMazeLoadingView()
        case .SpelunkerGame:
            SpelunkerGameViewController?.restartGame()
        case .Menu:
            return
        case .Unknown:
            return
        }
    }
    
    func quitToMenu() {
        pauseMenuIsUp = false
        switch ActiveScreen {
        case .BlasterGame:
            BlasterGameViewController?.quitGame()
        case .AdventureGame:
            AdventureGameViewController?.quitGame()
        case .TrailBlazerGame:
            TrailBlazerViewController?.quitGame()
        case .MazeGame:
            MazeGameViewController?.quitGame()
        case .SpelunkerGame:
            SpelunkerGameViewController?.quitGame()
        case .Menu:
            return
        case .Unknown:
            return
        }
        ActiveScreen = .Menu
        SelectionMenuViewController?.returnToMenu()
    }
    
    func pauseGame() {
        switch ActiveScreen {
        case .BlasterGame:
            BlasterGameViewController?.pauseGame()
        case .AdventureGame:
            AdventureGameViewController?.pauseGame()
        case .TrailBlazerGame:
            TrailBlazerViewController?.pauseGame()
        case .MazeGame:
            MazeGameViewController?.pauseGame()
        case .SpelunkerGame:
            SpelunkerGameViewController?.pauseGame()
        case .Menu:
            return
        case .Unknown:
            return
        }
    }
    
    // MARK: - Menu Navigation Functions
    func upPressedInMenu() {
        switch selectedMenuOption {
        case .Continue:
            selectedMenuOption = .Quit
        case .Restart:
            selectedMenuOption = .Continue
        case .Quit:
            selectedMenuOption = .Restart
        case .Unknown:
            return
        }
        animateSelectedMenuOption()
    }
    
    func downPressedInMenu() {
        switch selectedMenuOption {
        case .Continue:
            selectedMenuOption = .Restart
        case .Restart:
            selectedMenuOption = .Quit
        case .Quit:
            selectedMenuOption = .Continue
        case .Unknown:
            return
        }
        animateSelectedMenuOption()
    }
    
    func selectMenuOption() {
        switch selectedMenuOption {
        case .Continue:
            shouldRestartGame = false
            beginCountDown()
            shouldRestartGame = false
        case .Restart:
            shouldRestartGame = true
            beginCountDown()
            shouldRestartGame = false
        case .Quit:
            quitToMenu()
            hideMenu()
        case .Unknown:
            return
        }
    }
    
    // MARK: - Menu Button Pressed Functions
    @objc func MenuButtonPressed() {
        if(!startingGame) {
            if (pauseMenuIsUp) {
                beginCountDown()
                BlasterGameViewController?.resumeGame()
                pauseMenuIsUp = false
            } else {
                switch ActiveScreen {
                case .BlasterGame:
                    guard let gameOverIsUp = BlasterGameViewController?.getGameOverIsUp() else {
                        return
                    }
                    if(!gameOverIsUp) {
                        pauseMenuIsUp = true
                        prepareToShowMenu()
                        showMenu()
                        BlasterGameViewController?.pauseGame()
                    }
                case .AdventureGame:
                    pauseMenuIsUp = true
                    prepareToShowMenu()
                    showMenu()
                    TrailBlazerViewController?.pauseGame()
                case .TrailBlazerGame:
                    pauseMenuIsUp = true
                    prepareToShowMenu()
                    showMenu()
                    TrailBlazerViewController?.pauseGame()
                case .MazeGame:
                    pauseMenuIsUp = true
                    prepareToShowMenu()
                    showMenu()
                    MazeGameViewController?.pauseGame()
                case .SpelunkerGame:
                    pauseMenuIsUp = true
                    prepareToShowMenu()
                    showMenu()
                    SpelunkerGameViewController?.pauseGame()
                case .Menu:
                    SelectionMenuViewController?.menuButtonPressed()
                case .Unknown:
                    return
                }
            }
        }
    }
    
    // MARK: - A Button Pressed Function
    @objc func AButtonPressed() {
        if(!startingGame) {
            if(pauseMenuIsUp) {
                selectMenuOption()
            } else {
                switch ActiveScreen {
                case .BlasterGame:
                    BlasterGameViewController?.AButtonPressed()
                case .AdventureGame:
                    AdventureGameViewController?.AButtonPressed()
                case .TrailBlazerGame:
                    TrailBlazerViewController?.AButtonPressed()
                case .MazeGame:
                    MazeGameViewController?.AButtonPressed()
                case .SpelunkerGame:
                    SpelunkerGameViewController?.AButtonPressed()
                case .Menu:
                    SelectionMenuViewController?.AButtonPressed()
                case .Unknown:
                    return
                }
            }
        }
    }
    
    // MARK: - B Button Pressed Function
    @objc func BButtonPressed() {
        if(!startingGame) {
            if(pauseMenuIsUp) {
                
            } else {
                switch ActiveScreen {
                case .BlasterGame:
                    BlasterGameViewController?.BButtonPressed()
                case .AdventureGame:
                    AdventureGameViewController?.BButtonPressed()
                case .TrailBlazerGame:
                    TrailBlazerViewController?.BButtonPressed()
                case .MazeGame:
                    MazeGameViewController?.BButtonPressed()
                case .SpelunkerGame:
                    SpelunkerGameViewController?.BButtonPressed()
                case .Menu:
                    SelectionMenuViewController?.BButtonPressed()
                case .Unknown:
                    return
                }
            }
        }
    }

    // MARK: - Left Button Pressed Function
    @objc func leftButtonPressed() {
        if(!startingGame) {
            if(pauseMenuIsUp) {
                upPressedInMenu()
            } else {
                switch ActiveScreen {
                case .BlasterGame:
                    BlasterGameViewController?.leftButtonPressed()
                case .AdventureGame:
                    AdventureGameViewController?.leftButtonPressed()
                case .TrailBlazerGame:
                    TrailBlazerViewController?.leftButtonPressed()
                case .MazeGame:
                    MazeGameViewController?.leftButtonPressed()
                case .SpelunkerGame:
                    SpelunkerGameViewController?.leftButtonPressed()
                case .Menu:
                    SelectionMenuViewController?.leftButtonPressed()
                case .Unknown:
                    return
                }
            }
        }
    }
    
    // MARK: - Right Button Pressed Function
    @objc func rightButtonPressed() {
        if(!startingGame) {
            if(pauseMenuIsUp) {
                downPressedInMenu()
            } else {
                switch ActiveScreen {
                case .BlasterGame:
                    BlasterGameViewController?.rightButtonPressed()
                case .AdventureGame:
                    AdventureGameViewController?.rightButtonPressed()
                case .TrailBlazerGame:
                    TrailBlazerViewController?.rightButtonPressed()
                case .MazeGame:
                    MazeGameViewController?.rightButtonPressed()
                case .SpelunkerGame:
                    SpelunkerGameViewController?.rightButtonPressed()
                case .Menu:
                    SelectionMenuViewController?.rightButtonPressed()
                case .Unknown:
                    return
                }
            }
        }
    }
    
    // MARK: - Up Button Pressed Function
    @objc func upButtonPressed() {
        if(!startingGame) {
            if(pauseMenuIsUp) {
                upPressedInMenu()
            } else {
                switch ActiveScreen {
                case .BlasterGame:
                    BlasterGameViewController?.upButtonPressed()
                case .AdventureGame:
                    AdventureGameViewController?.upButtonPressed()
                case .TrailBlazerGame:
                    TrailBlazerViewController?.upButtonPressed()
                case .MazeGame:
                    MazeGameViewController?.upButtonPressed()
                case .SpelunkerGame:
                    SpelunkerGameViewController?.upButtonPressed()
                case .Menu:
                    SelectionMenuViewController?.upButtonPressed()
                case .Unknown:
                    return
                }
            }
        }
    }
    
    // MARK: - Down Button Pressed Function
    @objc func downButtonPressed() {
        if(!startingGame) {
            if(pauseMenuIsUp) {
                downPressedInMenu()
            } else {
                switch ActiveScreen {
                case .BlasterGame:
                    BlasterGameViewController?.downButtonPressed()
                case .AdventureGame:
                    AdventureGameViewController?.downButtonPressed()
                case .TrailBlazerGame:
                    TrailBlazerViewController?.downButtonPressed()
                case .MazeGame:
                    MazeGameViewController?.downButtonPressed()
                case .SpelunkerGame:
                    SpelunkerGameViewController?.downButtonPressed()
                case .Menu:
                    SelectionMenuViewController?.downButtonPressed()
                case .Unknown:
                    return
                }
            }
        }
    }
    
    // MARK: - Left Button Functionality
    @objc func leftButtonDown(sender: UIButton) {
        if(!startingGame) {
            if(pauseMenuIsUp) {
                leftButtonPressed()
            } else {
                switch ActiveScreen {
                case .BlasterGame:
                    if(!rightButtonIsDown && !downButtonIsDown && !upButtonIsDown) {
                        leftButtonIsDown = true
                        leftButtonPressed()
                        timer = Timer.scheduledTimer(timeInterval: recallRate, target: self, selector: #selector(leftButtonPressed), userInfo: nil, repeats: true)
                    }
                case .AdventureGame:
                    AdventureGameViewController?.leftButtonPressed()
                case .TrailBlazerGame:
                    leftButtonPressed()
                case .MazeGame:
                    if(!rightButtonIsDown && !downButtonIsDown && !upButtonIsDown) {
                        leftButtonIsDown = true
                        leftButtonPressed()
                        timer = Timer.scheduledTimer(timeInterval: recallRate, target: self, selector: #selector(leftButtonPressed), userInfo: nil, repeats: true)
                    }
                case .SpelunkerGame:
                    leftButtonPressed()
                case .Menu:
                    leftButtonPressed()
                case .Unknown:
                    return
                }
            }
        }
    }
    
    @objc func leftButtonUp(sender: UIButton) {
        timer.invalidate()
        leftButtonIsDown = false
    }
    
    
    // MARK: - Right Button Functionality
    @objc func rightButtonDown(sender: UIButton) {
        if(!startingGame) {
            if(pauseMenuIsUp) {
                rightButtonPressed()
            } else {
                switch ActiveScreen {
                case .BlasterGame:
                    if(!leftButtonIsDown && !downButtonIsDown && !upButtonIsDown) {
                        rightButtonIsDown = true
                        rightButtonPressed()
                        timer = Timer.scheduledTimer(timeInterval: recallRate, target: self, selector: #selector(rightButtonPressed), userInfo: nil, repeats: true)
                    }
                case .AdventureGame:
                    rightButtonPressed()
                case .TrailBlazerGame:
                    rightButtonPressed()
                case .MazeGame:
                    if(!leftButtonIsDown && !downButtonIsDown && !upButtonIsDown) {
                        rightButtonIsDown = true
                        rightButtonPressed()
                        timer = Timer.scheduledTimer(timeInterval: recallRate, target: self, selector: #selector(rightButtonPressed), userInfo: nil, repeats: true)
                    }
                case .SpelunkerGame:
                    rightButtonPressed()
                case .Menu:
                    rightButtonPressed()
                case .Unknown:
                    return
                }
            }
        }
    }
    
    @objc func rightButtonUp(sender: UIButton) {
        timer.invalidate()
        rightButtonIsDown = false
    }
    
    
    // MARK: - Up Button Functionality
    @objc func upButtonDown(sender: UIButton) {
        if(!startingGame) {
            if(pauseMenuIsUp) {
                upButtonPressed()
            } else {
                switch ActiveScreen {
                case .BlasterGame:
                    if(!leftButtonIsDown && !downButtonIsDown && !rightButtonIsDown) {
                        upButtonIsDown = false
                        upButtonPressed()
                        timer = Timer.scheduledTimer(timeInterval: recallRate, target: self, selector: #selector(upButtonPressed), userInfo: nil, repeats: true)
                    }
                case .AdventureGame:
                    upButtonPressed()
                case .TrailBlazerGame:
                    upButtonPressed()
                case .MazeGame:
                    if(!leftButtonIsDown && !downButtonIsDown && !rightButtonIsDown) {
                        upButtonIsDown = false
                        upButtonPressed()
                        timer = Timer.scheduledTimer(timeInterval: recallRate, target: self, selector: #selector(upButtonPressed), userInfo: nil, repeats: true)
                    }
                case .SpelunkerGame:
                    if(!leftButtonIsDown && !downButtonIsDown && !rightButtonIsDown) {
                        upButtonIsDown = false
                        upButtonPressed()
                        timer = Timer.scheduledTimer(timeInterval: recallRate, target: self, selector: #selector(upButtonPressed), userInfo: nil, repeats: true)
                    }
                case .Menu:
                    upButtonPressed()
                case .Unknown:
                    return
                }
            }
        }
    }
    
    @objc func upButtonUp(sender: UIButton) {
        timer.invalidate()
        upButtonIsDown = false
    }
    
    // MARK: - Down Button Functions
    @objc func downButtonDown(sender: UIButton) {
        if(!startingGame) {
            if(pauseMenuIsUp) {
                downButtonPressed()
            } else {
                switch ActiveScreen {
                case .BlasterGame:
                    if(!leftButtonIsDown && !rightButtonIsDown && !upButtonIsDown) {
                        downButtonIsDown = true
                        downButtonPressed()
                        timer = Timer.scheduledTimer(timeInterval: recallRate, target: self, selector: #selector(downButtonPressed), userInfo: nil, repeats: true)
                    }
                case .AdventureGame:
                    downButtonPressed()
                case .TrailBlazerGame:
                    downButtonPressed()
                case .MazeGame:
                    if(!leftButtonIsDown && !rightButtonIsDown && !upButtonIsDown) {
                        downButtonIsDown = true
                        downButtonPressed()
                        timer = Timer.scheduledTimer(timeInterval: recallRate, target: self, selector: #selector(downButtonPressed), userInfo: nil, repeats: true)
                    }
                case .SpelunkerGame:
                    if(!leftButtonIsDown && !rightButtonIsDown && !upButtonIsDown) {
                        downButtonIsDown = true
                        downButtonPressed()
                        timer = Timer.scheduledTimer(timeInterval: recallRate, target: self, selector: #selector(downButtonPressed), userInfo: nil, repeats: true)
                    }
                case .Menu:
                    downButtonPressed()
                case .Unknown:
                    return
                }
            }
        }
    }
    
    @objc func downButtonUp(sender: UIButton) {
        timer.invalidate()
        downButtonIsDown = false
    }
}
