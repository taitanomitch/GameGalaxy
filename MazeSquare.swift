//
//  MazeSquare.swift
//  GameGalaxy
//
//  Created by Mitchell Taitano on 4/17/18.
//  Copyright © 2018 Mitchell Taitano. All rights reserved.
//

import UIKit

class MazeSquare: UIView {

    public var hasLeftWall: Bool = true
    public var hasRightWall: Bool = true
    public var hasTopWall: Bool = true
    public var hasBottomWall: Bool = true
    
    public var wallWidth: CGFloat = 4.0
    
    public var wallColor: UIColor = UIColor.white
    public var backColor: UIColor = UIColor.black
    
    
    @IBOutlet var ContentView: MazeSquare!
    
    @IBOutlet weak var BackgroundView: UIView!
    @IBOutlet weak var LeftWallView: UIView!
    @IBOutlet weak var RightWallView: UIView!
    @IBOutlet weak var TopWallView: UIView!
    @IBOutlet weak var BottomWallView: UIView!
    
    @IBOutlet weak var LeftWallConstraint: NSLayoutConstraint!
    @IBOutlet weak var RightWallConstraint: NSLayoutConstraint!
    @IBOutlet weak var TopWallConstraint: NSLayoutConstraint!
    @IBOutlet weak var BottomWallConstraint: NSLayoutConstraint!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Bundle.main.loadNibNamed("MazeSquare", owner: self, options: nil)
        addSubview(ContentView)
        ContentView.frame = self.bounds
        ContentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
    }
    
    func setupCell() {
        self.backgroundColor = backColor
        setUpWalls()
    }
    
    func setUpWalls() {
        if(hasLeftWall) {
            LeftWallView.backgroundColor = wallColor
            LeftWallConstraint.constant = wallWidth
        } else {
            LeftWallView.removeFromSuperview()
        }
        if(hasRightWall) {
            RightWallView.backgroundColor = wallColor
            RightWallConstraint.constant = wallWidth
        } else {
            RightWallView.removeFromSuperview()
        }
        if(hasTopWall) {
            TopWallView.backgroundColor = wallColor
            TopWallConstraint.constant = wallWidth
        } else {
            TopWallView.removeFromSuperview()
        }
        if(hasBottomWall) {
            BottomWallView.backgroundColor = wallColor
            BottomWallConstraint.constant = wallWidth
        } else {
            BottomWallView.removeFromSuperview()
        }
    }

}
