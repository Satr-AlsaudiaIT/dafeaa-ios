//
//  LogoView.swift
//  Proffer
//
//  Created by M.Magdy on 18/02/2024.
//  Copyright © 2024 Nura. All rights reserved.
//

import SwiftUI

struct LogoView: View {
    @State var title : String = ""
    @State var subTitle: String = ""
    var body: some View {
        VStack(spacing: 10) {
            //MARK:- ToDo
            Image("Asset.logo.name")
                .resizable()
                .frame(width: 183,height: 47)
            Text(title)
                .font(.custom(AppFonts.shared.name(AppFontsTypes.plain), size: 27))
                .foregroundStyle(Color(.mainBG))
            Text(subTitle)
            .font(.custom(AppFonts.shared.name(AppFontsTypes.plain), size: 17))
            .foregroundStyle(Color(.black222222))
        }
    }
}

#Preview {
    LogoView()
}
