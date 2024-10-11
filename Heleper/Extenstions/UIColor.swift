//
//  UIColor.swift
//  SlideMenuControllerSwift
//

//  Copyright © . All rights reserved.
//

import UIKit

extension UIColor {
    func as1ptImage() -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 1,height: 1))
        let ctx = UIGraphicsGetCurrentContext()
        self.setFill()
        ctx!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
}

    convenience init(hex: String) {
        self.init(hex: hex, alpha:1)
    }

    convenience init(hex: String, alpha: CGFloat) {
        var hexWithoutSymbol = hex
        if hexWithoutSymbol.hasPrefix("#") {
            hexWithoutSymbol.remove(at: hexWithoutSymbol.startIndex)
        }
        
        let scanner = Scanner(string: hexWithoutSymbol)
        var rgbValue:UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
//        var r:UInt32!, g:UInt32!, b:UInt32!
//        switch (hexWithoutSymbol.length) {
//        case 3: // #RGB
//            r = ((hexInt >> 4) & 0xf0 | (hexInt >> 8) & 0x0f)
//            g = ((hexInt >> 0) & 0xf0 | (hexInt >> 4) & 0x0f)
//            b = ((hexInt << 4) & 0xf0 | hexInt & 0x0f)
//            break;
//        case 6: // #RRGGBB
//            r = (hexInt >> 16) & 0xff
//            g = (hexInt >> 8) & 0xff
//            b = hexInt & 0xff
//            break;
//        default:
//            // TODO:ERROR
//            break;
//        }
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: CGFloat(1.0))
    }
}
