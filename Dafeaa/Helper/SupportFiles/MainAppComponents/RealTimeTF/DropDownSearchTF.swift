//
//  DropDownSearchTF.swift
//  Proffer
//
//  Created by M.Magdy on 28/02/2024.
//  Copyright © 2024 Nura. All rights reserved.
//

import SwiftUI



import SwiftUI

struct DropdownSearchTF: View {
    @State private var selection = ""
    @State private var searchTerm = ""
    @State private var searchEmpty = ""
    @State var placeHolder:String
    @Binding var isOpen: Bool?
    @State private var active :Bool = false
    @Binding var text : String
    private var idiom : UIUserInterfaceIdiom {UIDevice.current.userInterfaceIdiom }
    var title: String
    @Binding var options: [String]
    var submitLabel: SubmitLabel
    @State var height : CGFloat = 48
    @State var radius :CGFloat = 5
    @State var titleSize: CGFloat = 14
    @State var image : UIImage = UIImage()
    var filteredItems: [String] {
        if searchTerm.isEmpty {
            return options
        } else {
            return options.filter { $0.localizedCaseInsensitiveContains(searchTerm) }
        }
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 0) {
            ZStack(alignment: .leading ){
                ZStack{
                    HStack {
                        Text("")
                        Spacer()
                    }
                }
                .frame(height: height)
                .background(Color(.grayF6F6F6))
                .cornerRadius(radius)
                    
                VStack {
                    ZStack {
                        HStack {
                            Image(uiImage: image)
                                .foregroundColor(Color.yellow)
                                .frame(width: 20, height: 20)
                                .padding(.leading,20)
                            TextField("", text: selection == "" && !(isOpen ?? false ) ? $searchEmpty: $searchTerm, onEditingChanged: { (editingChanged) in
                                self.active =  editingChanged ? true:false
                                self.isOpen = editingChanged ? true:false
                            })
                            .placeholder(when: selection == "") {
                                Text(selection == "" && !(isOpen ?? false) ? placeHolder: selection).foregroundColor(Color(.lightGray))
                            }
                            .background(Color.init(.clear))
//                            .cornerRadius(5)
//                            .padding(.leading,10)
                            .font(.custom(AppFonts.shared.name(AppFontsTypes.plain), size: 14))
                            .foregroundColor(.black292D32)
                            .submitLabel(submitLabel)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .onTapGesture {
                                searchTerm = ""
                                selection = ""
                                isOpen = true
                                active = true
                            }
                            Spacer()
                            Image(systemName: "chevron.down")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.trailing,15)
                        }
                    }
                    .frame(height: height)
                    .animation(.default,value: 2)
                    .cornerRadius(5)
                }
            }
            if isOpen ?? false {
                VStack{
                   
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
//                            Color(Asset.white.color)
                            ForEach(filteredItems, id: \.self) { option in
                                Button(action: {
                                    selection = option
                                    isOpen = false
                                    active = false
                                    searchTerm = selection
                                    text = selection
                                    hideKeyboard()
                                }) {
                                    VStack {
                                        HStack {
                                            Text(String(describing: option))
                                                .foregroundColor(.black)
                                                .padding(.leading)
                                                .padding(.top,4)
                                            //    .cornerRadius(8)
                                            Spacer()
                                        }
                                        Divider()
                                            .padding(.vertical, 2)
                                    }
                                    }
//
                            }
                        }
//                        .padding(.horizontal, 4)
//                        .cornerRadius(8)
//                        .shadow(radius: 4)
                        
                    }
                    .frame(height: filteredItems.count < 5 ? CGFloat((filteredItems.count * 40)) : 150)
                    .cornerRadius(8)
                }
                .padding(.top, 0)
                .cornerRadius(5)
               
            }
        }
//        .padding([.leading,.trailing])
        .onChange(of: text, { _, _ in
            selection = text
            searchTerm = text
        })
        .onAppear{
            if !text.isBlank{
                selection = text
                searchTerm = text
            }
        }
//        .padding(.bottom,8)
    }
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
//#Preview {
//    DropdownSearchTF(placeHolder: "Area", isOpen: .constant(false), text: .constant(""), title: "Area", options: ["jjj","kkkk", "hjk"], submitLabel: .next)
//}
