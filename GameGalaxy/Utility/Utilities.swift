//
//  Utilities.swift
//  GameGalaxy
//
//  Created by Mitchell Taitano on 1/6/18.
//  Copyright © 2018 Mitchell Taitano. All rights reserved.
//

import UIKit

class Utilities {
    
    enum Colors_GameGalaxy: String {
        case GameGalaxyTeal = "28BACF"
        case GameGalaxyPink = "ECEAFF"
        case GameGalaxyGray = "95919B"
        case GameGalaxySkyBlue = "CFFCFF"
        case GameGalaxyMaroon = "D48390"
        case GameGalaxyWhite = "FFFFFF"
        case GameGalaxyBlack = "000000"
    }
    
    static func hexUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
