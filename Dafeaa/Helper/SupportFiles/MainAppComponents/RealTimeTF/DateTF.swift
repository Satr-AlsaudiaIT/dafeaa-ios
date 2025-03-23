//
//  DateTF.swift
//  Proffer
//
//  Created by M.Magdy on 29/02/2024.
//  Copyright © 2024 Nura. All rights reserved.
//

import SwiftUI

struct DateTF: View {
    var title: String
    var image: UIImage
    var currentIsMinDate: Bool = false
    var submitLabel: SubmitLabel
    var placeHolder: String
    @State private  var active :Bool = false
    @Binding var text :String
    @Binding var date: Date?
    
    
    var body: some View {
        ZStack{
            VStack(alignment: .leading) {
                ZStack(alignment: .leading ){

                     
                    VStack(alignment: .leading,spacing: 0) {
                            HStack {
                                Image.init(uiImage:image)
                                    .resizable()
                                    .frame(width: 20,height: 20)
                                    .padding(.leading,20)
                                DatePickerTextField(currentIsMinDate: currentIsMinDate,placeholder: placeHolder, date: $date,isActive: $active)
                                    .onChange(of: date) { _, newValue in
                                        text = date?.formatDateFromDate() ?? ""
                                    }
                                    .font(.custom(AppFonts.shared.name(AppFontsTypes.plain), size: 15))
//                                    .padding(.leading,10)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .textModifier(.plain, 15,.black)
                                    .padding(.trailing,15)
                            }
                            .background(Color(.grayF6F6F6))
                                .cornerRadius(5)
//                                .shadow(radius: 1)
                                .frame(height: 48)
                                
                        }
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(active ? Color(.primary) : Color.clear, lineWidth: 1)
                    )
                }
                .animation(.default,value: 2)
                .onAppear{
                    if text != "" {
                        date = text.toDate()
                    }
                }
            }
        }
//            .padding([.leading,.trailing],20)
    }
}
