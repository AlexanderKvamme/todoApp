//
//  UIColor.swift
//  todoApp
//
//  Created by Alexander K on 15/04/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit


extension UIColor {
    // Theme
    static let primary = UIColor(hexString: "383644")
    static let primaryLight = UIColor(hexString: "363443")
    static let primaryContrast = UIColor(hexString: "f7eff6")
    
    enum categories {
        static let _default = UIColor(hexString: "b0e0e6")
        static let pleasure = UIColor(hexString: "c7dba8")
        static let business = UIColor(hexString: "efe4d0")
        static let groceries = UIColor(hexString: "f7a385")
    }
    
//    static let primary = UIColor(hexString: "383644")
//    //    static let primaryLight = UIColor(hexString:  "2e2c3a")
//    static let primaryLight = UIColor(hexString: "2e2c3a")
    
    static let secondary = UIColor(hexString: "BC4553") // noteMakerView

    // Static
    static let green = UIColor(hexString: "7ED99C")
    static let dijon = UIColor(hexString: "ffae5e")
    static let dijonLight = UIColor(hexString: "FFA955")

    /// Initializer for Hex colors
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"#%06x", rgb)
    }
}
