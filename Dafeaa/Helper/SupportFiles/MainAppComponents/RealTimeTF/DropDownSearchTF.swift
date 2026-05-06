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
    @State var placeHolder: String
    @Binding var isOpen: Bool?
    @State private var active: Bool = false
    @Binding var text: String
    
    var title: String
    @Binding var options: [String]
    var submitLabel: SubmitLabel = .done
    @State var height: CGFloat = 48
    @State var radius: CGFloat = 5
    @State var titleSize: CGFloat = 14
    @State var image: UIImage? = nil
    var isSearchable: Bool = true
    
    var filteredItems: [String] {
        if searchTerm.isEmpty || !isSearchable {
            return options
        } else {
            return options.filter { $0.localizedCaseInsensitiveContains(searchTerm) }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: radius)
                    .fill(Color(.grayF6F6F6))
                    .frame(height: height)
                
                HStack {
                    if let image {
                        Image(uiImage: image)
                            .renderingMode(.template)
                            .foregroundColor(Color.yellow)
                            .frame(width: 20, height: 20)
                            .padding(.leading, 20)
                    } else {
                        Spacer().frame(width: 16)
                    }
                    
                    if isSearchable {
                        TextField(placeHolder.localized(), text: $searchTerm, onEditingChanged: { editingChanged in
                            self.active = editingChanged
                            self.isOpen = editingChanged
                        })
                        .foregroundColor(text.isEmpty ? .grayB5B5B5 : .black)
                        .font(.system(size: titleSize))
                        .submitLabel(submitLabel)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onTapGesture {
                            searchTerm = ""
                            isOpen = true
                            active = true
                        }
                    } else {
                        Button(action: {
                            hideKeyboard()
                            withAnimation {
                                isOpen = !(isOpen ?? false)
                                active = isOpen ?? false
                                searchTerm = ""
                            }
                        }) {
                            Text(text.isEmpty ? placeHolder.localized() : text)
                                .foregroundColor(text.isEmpty ? Color(.grayB5B5B5) : Color(.black))
                                .font(.system(size: titleSize))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.grayB5B5B5)
                        .padding(.trailing, 15)
                        .rotationEffect(.degrees((isOpen ?? false) ? 180 : 0))
                }
                .frame(height: height)
                .overlay(
                    RoundedRectangle(cornerRadius: radius)
                        .stroke(Color(active ? .primary : .clear), lineWidth: 1)
                )
            }
            .onTapGesture {
                if !isSearchable {
                    hideKeyboard()
                    withAnimation {
                        isOpen = !(isOpen ?? false)
                        active = isOpen ?? false
                        searchTerm = ""
                    }
                }
            }
            
            if isOpen ?? false {
                VStack {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(filteredItems, id: \.self) { option in
                                Button(action: {
                                    selection = option
                                    text = option
                                    searchTerm = option
                                    withAnimation {
                                        isOpen = false
                                        active = false
                                    }
                                    hideKeyboard()
                                }) {
                                    VStack {
                                        HStack {
                                            Text(option)
                                                .foregroundColor(.black)
                                                .padding(.leading)
                                                .padding(.top, 4)
                                            Spacer()
                                        }
                                        Divider().padding(.vertical, 2)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                    .frame(height: filteredItems.count < 5 ? CGFloat((filteredItems.count * 40)) : 150)
                }
                .background(Color.white)
                .cornerRadius(radius)
                .overlay(
                    RoundedRectangle(cornerRadius: radius)
                        .stroke(Color(.grayAAAAAA), lineWidth: 0.3)
                )
                .padding(.top, 4)
            }
        }
        .onChange(of: text) { _, newValue in
            selection = newValue
            if isSearchable && !(isOpen ?? false) {
                searchTerm = newValue
            }
        }
        .onAppear {
            if !text.isEmpty {
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
