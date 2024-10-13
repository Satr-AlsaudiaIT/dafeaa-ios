//
//  CustomSegment.swift
//  
//
//  Created by M.Magdy on 05/09/2023.
//  Copyright © 2023  Nura. All rights reserved.
//

import Foundation
import UIKit

    extension UISegmentedControl {
      func clearBG() {
        let clearImage = UIImage().imageWithColor(color: .clear)
        setBackgroundImage(clearImage, for: .normal, barMetrics: .default)
          setBackgroundImage(UIImage().imageWithColor(color: UIColor(.mainBG)), for: .selected, barMetrics: .default)
        setDividerImage(clearImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
      }
    }

    public extension UIImage {
        func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage()}
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
      }
    }
