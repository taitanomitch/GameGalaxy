//
//  SelectionMenuViewController.swift
//  GameGalaxy
//
//  Created by Mitchell Taitano on 2/2/18.
//  Copyright © 2018 Mitchell Taitano. All rights reserved.
//

import UIKit

protocol SelectionDelegate {
    func selectedGame(game: GameGalaxyViewController.Games, viewController: UIViewController)
    func showMenuView()
}

class SelectionMenuViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    enum GameNames: String {
        case BlasterGame = "Blaster"
        case TrailBlazerGame = "TrailBlazer"
        case AdventureGame = "Adventure"
        case MazeGame = "Maze"
        case SpelunkerGame = "Spelunker"
        case Unknown
    }
    
    //IBOutlets
    @IBOutlet private weak var GamePicker: UIPickerView!
    @IBOutlet weak var MazeLoadingView: UIView!
    
    //Variables
    private var gameOptions: [String] = []
    private var numberOfGames: Int = 6
    private var selectedGame: GameGalaxyViewController.Games = GameGalaxyViewController.Games.Unknown
    private var selectedPickerRow: Int = 0
    public var delegate: SelectionDelegate?
    private var mazeLoadingBackgroundHexColor: String  = "254299"

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpUI()
        setUpPicker()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - SetUp Functions
    private func setUpUI() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        setUpMazeLoadingView()
    }
    
    private func setUpPicker() {
        gameOptions = ["Blaster", "Adventure", "TrailBlazer", "Maze", "Spelunker", "Other"]
        self.GamePicker.delegate = self
        self.GamePicker.dataSource = self
        selectedPickerRow = 0
        GamePicker.selectRow(selectedPickerRow, inComponent: 0, animated: false)
        pickerView(GamePicker, didSelectRow: selectedPickerRow, inComponent: 0)
    }
    
    private func setUpMazeLoadingView() {
        MazeLoadingView.alpha = 0.0
        MazeLoadingView.layer.cornerRadius = 5.0
        MazeLoadingView.layer.masksToBounds = true
        MazeLoadingView.backgroundColor = Utilities.hexUIColor(hex: mazeLoadingBackgroundHexColor)
    }
    
    // MARK: - Menu Functions
    func returnToMenu() {
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    // MARK: - Maze Loading Functions
    private func hideMazeLoadingView() {
        MazeLoadingView.alpha = 0.0
    }
    
    private func presentMazeLoadingViewAndLaunchGame() {
        MazeLoadingView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.3) {
            self.MazeLoadingView.alpha = 1.0
        }
        UIView.animate(withDuration: 1.0,
                       delay: 0,
                       usingSpringWithDamping: CGFloat(0.18),
                       initialSpringVelocity: CGFloat(2.0),
                       options: UIViewAnimationOptions.allowUserInteraction,
                       animations: {
                        self.MazeLoadingView.transform = CGAffineTransform.identity
        },
                       completion: { (done) in
                        let mazeGameViewController:MazeGameViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MazeGame") as! MazeGameViewController
                        mazeGameViewController.screenWidth = self.view.frame.width
                        mazeGameViewController.screenHeight = self.view.frame.height
                        self.delegate?.showMenuView()
                        self.navigationController?.pushViewController(mazeGameViewController, animated: false)
                        self.selectedGame = GameGalaxyViewController.Games.MazeGame
                        self.selectGame(viewController: mazeGameViewController)
        }
        )
    }
    
    
    // MARK: - Buttons Functions
    func AButtonPressed() {
        switch selectedGame {
        case GameGalaxyViewController.Games.BlasterGame:
            let blasterGameViewController:BlasterGameViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BlasterGame") as! BlasterGameViewController
            delegate?.showMenuView()
            self.navigationController?.pushViewController(blasterGameViewController, animated: false)
            selectedGame = GameGalaxyViewController.Games.BlasterGame
            selectGame(viewController: blasterGameViewController)
        case GameGalaxyViewController.Games.AdventureGame:
            let adventureGameViewController:AdventureViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AdventureGame") as! AdventureViewController
            delegate?.showMenuView()
            self.navigationController?.pushViewController(adventureGameViewController, animated: false)
            selectedGame = GameGalaxyViewController.Games.AdventureGame
            selectGame(viewController: adventureGameViewController)
        case GameGalaxyViewController.Games.TrailBlazerGame:
            let trailblazerGameViewController:TrailBlazerViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TrailBlazerGame") as! TrailBlazerViewController
            delegate?.showMenuView()
            self.navigationController?.pushViewController(trailblazerGameViewController, animated: false)
            selectedGame = GameGalaxyViewController.Games.TrailBlazerGame
            selectGame(viewController: trailblazerGameViewController)
        case GameGalaxyViewController.Games.MazeGame:
            presentMazeLoadingViewAndLaunchGame()
        case GameGalaxyViewController.Games.SpelunkerGame:
            let spelunkerGameViewController:SpelunkerGameViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SpelunkerGame") as! SpelunkerGameViewController
            delegate?.showMenuView()
            self.navigationController?.pushViewController(spelunkerGameViewController, animated: false)
            selectedGame = GameGalaxyViewController.Games.SpelunkerGame
            selectGame(viewController: spelunkerGameViewController)
        default:
            return
        }
        
    }

    func BButtonPressed() {
        selectedPickerRow = selectedPickerRow + 1
        if(selectedPickerRow == gameOptions.count) {
            selectedPickerRow = 0
        }
        GamePicker.selectRow(selectedPickerRow, inComponent: 0, animated: true)
        pickerView(GamePicker, didSelectRow: selectedPickerRow, inComponent: 0)
    }
    
    func menuButtonPressed() {

    }
    
    func leftButtonPressed() {
        
    }
    
    func rightButtonPressed() {
        
    }
    
    func upButtonPressed() {
        selectedPickerRow = selectedPickerRow - 1
        if(selectedPickerRow < 0) {
            selectedPickerRow = gameOptions.count - 1
        }
        GamePicker.selectRow(selectedPickerRow, inComponent: 0, animated: true)
        pickerView(GamePicker, didSelectRow: selectedPickerRow, inComponent: 0)
    }
    
    func downButtonPressed() {
        selectedPickerRow = selectedPickerRow + 1
        if(selectedPickerRow == gameOptions.count) {
            selectedPickerRow = 0
        }
        GamePicker.selectRow(selectedPickerRow, inComponent: 0, animated: true)
        pickerView(GamePicker, didSelectRow: selectedPickerRow, inComponent: 0)
    }
    
    func selectGame(viewController: UIViewController) {
        delegate?.selectedGame(game: selectedGame, viewController: viewController)
    }
    
    // MARK: - Picker Functionality
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return gameOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return gameOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch gameOptions[row] {
        case GameNames.BlasterGame.rawValue:
            selectedGame = GameGalaxyViewController.Games.BlasterGame
        case GameNames.TrailBlazerGame.rawValue:
            selectedGame = GameGalaxyViewController.Games.TrailBlazerGame
        case GameNames.AdventureGame.rawValue:
            selectedGame = GameGalaxyViewController.Games.AdventureGame
        case GameNames.MazeGame.rawValue:
            selectedGame = GameGalaxyViewController.Games.MazeGame
        case GameNames.SpelunkerGame.rawValue:
            selectedGame = GameGalaxyViewController.Games.SpelunkerGame
        default:
            selectedGame = GameGalaxyViewController.Games.Unknown
        }
    }
}
