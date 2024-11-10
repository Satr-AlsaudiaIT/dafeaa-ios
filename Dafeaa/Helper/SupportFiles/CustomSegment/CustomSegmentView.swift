//
//  CustomSegmentView.swift
//  Proffer
//
//  Created by AMN on 25/02/2024.
//  Copyright © 2024 Nura. All rights reserved.
//

import SwiftUI
struct CustomSegmentViewUnderLine:View{
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
import SwiftUI

struct CustomSegmentView: View {
    @State var titlesArray: [String]
    @State var selectedTitleColor: Color? = Color(.black222222)
    @State var selectedBackGroundColor: Color? = Color(.primary)
    @State var fontsize: CGFloat? = 14
    @Binding var selectedSegment: Int
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.black).opacity(0.1), lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.clear))
            
            HStack {
                ForEach(0..<titlesArray.count, id: \.self) { index in
                    VStack {
                        Text(titlesArray[index].localized())
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .font(.custom(AppFonts.shared.name(AppFontsTypes.semiBold), size: fontsize ?? 14))
                            .foregroundColor(selectedSegment == index ? selectedTitleColor : .grayAAAAAA)
                    }
                    .background(selectedSegment == index ? Color(.primary) : Color.clear)
                    .cornerRadius(8)
                    .onTapGesture {
                        selectedSegment = index
                    }
                }
            }
        }
        .frame(height: 45)
        .frame(maxWidth: .infinity)
    }
}
