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
    var onBack: (() -> Void)? = nil  // Optional onBack closure

      var body: some View {
          HStack {
              if let onBack = onBack {
                  Button(action: onBack, label: {
                      Image("backArrow")
                          .resizable()
                          .frame(width: 10, height: 17)
                  })
              } else {
                  Image("")
                      .resizable()
                      .frame(width: 10, height: 17)
              }
            Spacer()
            Text(title.localized())
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
