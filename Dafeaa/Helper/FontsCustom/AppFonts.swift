//
//  AppFonts.swift
//
//
//  Created by Nura on 4/11/23.
//  Copyright © 2023 Nura.com. All rights reserved.
//

import SwiftUI
enum AppFontsTypes: String {
    case bold = "Bold"
    case extraBold = "ExtraBold"
    case semiBold = "SemiBold"
    case plain = "Plain"
    case light = "Light"
    case extraLight = "ExtraLight"
//    case regular = "Regular"
    case black = "Black"
}

struct AppFonts {
    static let shared  = AppFonts()
    func name(_ type:AppFontsTypes) -> String {
        let fontName = Constants.shared.isAR ? "Bahij_TheSansArabic" :"Poppins" + "-" + type.rawValue
            return fontName
    }
    
}
