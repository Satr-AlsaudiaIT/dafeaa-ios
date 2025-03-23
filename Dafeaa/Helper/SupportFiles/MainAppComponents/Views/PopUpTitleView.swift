//
//  PopUpTitleView.swift
//  Proffer
//
//  Created by M.Magdy on 22/02/2024.
//  Copyright © 2024 Nura. All rights reserved.
//

import SwiftUI

struct PopUpTitleView: View {
    @State var image : String = ""
    @State var title :String = ""
    @State var subTitle:String = ""
    
    var body: some View {
            
            VStack {
                Image (image)
                   
                Text(title)
                    .font(.custom(AppFonts.shared.name(AppFontsTypes.plain), size: 27))
                    .foregroundStyle(Color(.mainOrange))
                    .padding(.bottom)
                Text(subTitle)
                    .font(.custom(AppFonts.shared.name(AppFontsTypes.plain), size: 17))
                .foregroundStyle(Color(.lightGray))
                .multilineTextAlignment(.center)
                .padding([.leading,.trailing],30)
                
                
            }
        

    }
}

#Preview {
    PopUpTitleView()
}
