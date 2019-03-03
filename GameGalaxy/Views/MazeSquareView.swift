//
//  MazeSquareView.swift
//  GameGalaxy
//
//  Created by Mitchell Taitano on 4/17/18.
//  Copyright © 2018 Mitchell Taitano. All rights reserved.
//

import UIKit

class MazeSquareView: UIView {

    @IBOutlet var ContentView: UIView!
    
    @IBOutlet weak var BackgroundView: UIView!
    
    @IBOutlet weak var LeftWall: UIView!
    @IBOutlet weak var RightWall: UIView!
    @IBOutlet weak var TopWall: UIView!
    @IBOutlet weak var BottomWall: UIView!
    
    @IBOutlet weak var LeftWallConstraint: NSLayoutConstraint!
    @IBOutlet weak var RightWallConstraint: NSLayoutConstraint!
    @IBOutlet weak var TopWallConstraint: NSLayoutConstraint!
    @IBOutlet weak var BottomWallConstraint: NSLayoutConstraint!
    
    var iPosition: Int!
    var jPosition: Int!
    
    var leftSquare: MazeSquareView!
    var rightSquare: MazeSquareView!
    var topSquare: MazeSquareView!
    var bottomSquare: MazeSquareView!
    
    var squareBackgroundColor: UIColor = UIColor.gray
    var wallBackgroundColor: UIColor = UIColor.black
    
    var visited: Bool = false
    
    var hasLeftWall: Bool = true
    var hasRightWall: Bool = true
    var hasTopWall: Bool = true
    var hasBottomWall: Bool = true
    
    var wallWidth: CGFloat = 3.0

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        ContentView = Bundle.main.loadNibNamed("MazeSquareView", owner: self, options: nil)?.first as! UIView
        addSubview(ContentView)
        ContentView.frame = self.bounds
        ContentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    func setUpCell() {
        BackgroundView.backgroundColor = squareBackgroundColor
        LeftWall.backgroundColor = wallBackgroundColor
        RightWall.backgroundColor = wallBackgroundColor
        TopWall.backgroundColor = wallBackgroundColor
        BottomWall.backgroundColor = wallBackgroundColor
        
        LeftWallConstraint.constant = wallWidth
        RightWallConstraint.constant = wallWidth
        TopWallConstraint.constant = wallWidth
        BottomWallConstraint.constant = wallWidth
        
        if(hasLeftWall) {
            
        } else {
            LeftWall.removeFromSuperview()
        }
        
        if(hasRightWall) {
            
        } else {
            RightWall.removeFromSuperview()
        }
        
        if(hasTopWall) {
            
        } else {
            TopWall.removeFromSuperview()
        }
        
        if(hasBottomWall) {
            
        } else {
            BottomWall.removeFromSuperview()
        }
    }
    
    func isDeadEnd() -> Bool {
        var count = 0
        if(hasLeftWall) {
            count = count + 1
        }
        if(hasRightWall) {
            count = count + 1
        }
        if(hasTopWall) {
            count = count + 1
        }
        if(hasBottomWall) {
            count = count + 1
        }
        return count == 3
    }
}
