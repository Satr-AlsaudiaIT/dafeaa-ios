//
//  CustomSegmentView.swift
//  Proffer
//
//  Created by AMN on 25/02/2024.
//  Copyright © 2024 Nura. All rights reserved.
//

import SwiftUI
struct CustomSegmentView:View{
    @State var titlesArray:[String]
    @State var selectedTitleColor:Color? = Color(.mainOrange)
    @State var selectedBackGroundColor:Color? = Color(.gray888888)
    @State var fontsize:CGFloat? = 14
    @Binding var selectedSegment :Int

    var body: some View{
        ZStack(alignment:.bottom){
            Rectangle()
                .fill(Color(.lightGray))
                .cornerRadius(2)
                .padding([.leading,.trailing],3)
                .frame(height: 1)
            HStack{
                ForEach(0..<(titlesArray.count), id: \.self) { index in
                    VStack{
                        Text(titlesArray[index].localized())
                            .frame(maxWidth: .infinity)
                            .frame(height: 35)
                            .font(.custom(AppFonts.shared.name(AppFontsTypes.plain), size: fontsize ?? 14))
                            .foregroundColor(selectedSegment == index ? selectedTitleColor: .black)
                        Rectangle()
                            .fill((selectedSegment == index ? selectedTitleColor: .clear) ?? .clear)
                            .cornerRadius(3)
                            .padding([.leading,.trailing],3)
                            .padding(.bottom,-2)
                            .frame(height: 3)
                    }
                        .onTapGesture {
                            selectedSegment = index
                            }
                }
            }
           
        }
        .padding(1)
        .frame(height: 40)
        .frame(maxWidth: .infinity)

    }
    
}
//struct CustomSegmentView:View{
//    var body: some View{
//        
//        VStack {
//            GeometryReader { geo in
//                VStack {
//                    Spacer()
//                    Rectangle()
//                        .fill(Color(Asset.lightGray.name).opacity(0.4))
//                        .frame(width: UIScreen.main.bounds.width - 95 , height: 2)
//                        .padding(.leading,5)
//                        .padding(.top,29)
//                }
//                .frame(height: 30)
//                HStack  {
//                    VStack {
//                        Button {
//                            selectedTap = .current
//                        } label: {
//                            VStack(spacing: 0) {
//                                if selectedTap == .current {
//                                    Text("Current".localized())
//                                        .foregroundColor(Color(Asset.secondColor.name))
//                                        .font(.custom(AppFonts.shared.name(AppFontsTypes.extraBold), size: 14))
//                                    Rectangle()
//                                        .fill(Color(Asset.secondColor.name))
//                                        .cornerRadius(3)
//                                        .padding([.leading,.trailing],3)
//                                        .frame(height: 5)
//                                }
//                                else {
//                                    
//                                    Text("Current".localized())
//                                        .foregroundColor(Color(Asset.lightGray.name).opacity(0.4))
//                                        .font(.custom(AppFonts.shared.name(AppFontsTypes.bold), size: 11))
//                                }
//                            }
//                        }
//                        
//                    }
//                    .frame(maxWidth: .infinity)
//                    VStack {
//                        Button {
//                            selectedTap = .history
//                            
//                        } label: {
//                            VStack(spacing: 0) {
//                                if selectedTap == .history {
//                                    Text("History".localized())
//                                        .foregroundColor(Color(Asset.secondColor.name))
//                                        .font(.custom(AppFonts.shared.name(AppFontsTypes.extraBold), size: 14))
//                                    Rectangle()
//                                        .fill(Color(Asset.secondColor.name))
//                                        .cornerRadius(3)
//                                        .padding([.leading,.trailing],3)
//                                        .frame(height: 5)
//                                }
//                                else {
//                                    
//                                    Text("History".localized())
//                                        .foregroundColor(Color(Asset.lightGray.name).opacity(0.4))
//                                        .font(.custom(AppFonts.shared.name(AppFontsTypes.bold), size: 11))
//                                }
//                            }
//                        }
//                        
//                    }
//                    .frame(maxWidth: .infinity)
//                    
//                }
//                
//                .frame(height: 30)
//                .padding(.top,8)
//                Spacer()
//            }
//            .frame(height: 30)
//            .frame(width: UIScreen.main.bounds.width - 80 )
//            .padding([.leading,.trailing], 40)
//        }
//    }
//}
