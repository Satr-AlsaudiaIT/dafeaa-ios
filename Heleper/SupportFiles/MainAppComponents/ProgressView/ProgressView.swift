//
//  ProgressView.swift
//  
//
//  Created by AMN on 5/4/23.
//  Copyright © 2023  Nura. All rights reserved.
//

import Foundation
import SwiftUI

struct WithBackgroundProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ProgressView(configuration)
            .padding(8)
            .background(Color.black.opacity(0.7))
            .font(.custom(AppFonts.shared.name(AppFontsTypes.plain), size: 16))
            .tint(Color(.mainBG))
            .cornerRadius(8)
            
    }
}
