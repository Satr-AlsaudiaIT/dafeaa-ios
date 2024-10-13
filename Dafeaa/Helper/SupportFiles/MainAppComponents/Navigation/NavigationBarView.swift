//
//  NavigationBarView.swift
//  Proffer
//
//  Created by M.Magdy on 18/02/2024.
//  Copyright © 2024 Nura. All rights reserved.
//

import SwiftUI

struct NavigationBarView: View {
    @State var title: String = ""
    @State var color : Color = .black222222
    @State var backGroundColor : Color = Color(.primary)
    @State var withoutBack: Bool = false
    let onBack: () -> Void

    var body: some View {
        HStack {
            Button(action: onBack, label: {
                //MARK: - ToDo
                Image(!withoutBack ? "backArrow" : "")
                    .resizable()
                    .frame(width: 10 ,height: 17)
                
            })
            Spacer()
            Text(title)
                .font(.custom(AppFonts.shared.name(AppFontsTypes.plain), size: 17))
                .foregroundStyle(Color(color))
            Spacer()
            Image("")
                .resizable()
                .frame(width: 10 ,height: 17)
            
        }

        .padding(24)
        .background(Color(backGroundColor))
    }
}
