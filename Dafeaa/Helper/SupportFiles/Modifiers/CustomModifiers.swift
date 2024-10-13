//Proffer
//CustomModifiers.swift

//Created by: Kareem on 2/26/24                      
//Copyright (c) 2023 Kareem

import SwiftUI

extension View {
    func textModifier(_ type: AppFontsTypes, _ size: CGFloat, _ color: Color) -> some View {
        self
            .font(.custom(AppFonts.shared.name(type), size: size))
            .foregroundStyle(color)
            .lineSpacing(4)

    }
}
