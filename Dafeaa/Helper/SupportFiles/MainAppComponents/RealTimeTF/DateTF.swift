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

                    VStack(spacing: 5) {
                        HStack {
                            Text ("\(title)")
                                .font(.custom(AppFonts.shared.name(AppFontsTypes.semiBold), size: 17 ))
                                .foregroundStyle(Color(.black222222))
                            Spacer()
                        }
                        
                    VStack(alignment: .leading,spacing: 0) {
                            HStack {
                                DatePickerTextField(currentIsMinDate: currentIsMinDate,placeholder: placeHolder, date: $date,isActive: $active)
                                    .onChange(of: date) { _, newValue in
                                        text = date?.formatDateFromDate() ?? ""
                                    }
                                    .font(.custom(AppFonts.shared.name(AppFontsTypes.plain), size: 14))
                                    .padding(.leading,10)
                                Spacer()
                                Image.init(uiImage:image)
                                    .resizable()
                                    .frame(width: 24,height: 24)
                                    .padding([.trailing], 20)
                            }
                                .background(Color(.textFieldBG))
                                .cornerRadius(15)
                                .shadow(radius: 1)
                                .frame(height: 56)
                                
                        }
                    }
                }
                .animation(.default,value: 2)
                .onAppear{
                    if text != "" {
                        date = text.toDate()
                    }
                }
            }
        }
            .padding([.leading,.trailing],20)
    }
}
