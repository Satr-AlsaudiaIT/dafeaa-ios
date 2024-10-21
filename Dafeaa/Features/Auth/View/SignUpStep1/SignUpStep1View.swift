//
//  SignUpStep1View.swift
//  Dafeaa
//
//  Created by M.Magdy on 06/10/2024.
//


import SwiftUI

struct SignUpStep1View: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedOption: AccountTypeOption = .none
    @State private var isShowStep2 : Bool = false
    
    var body: some View {
        
        VStack(alignment: .leading , spacing: 16) {
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Image(.arrowLeft)
                        .resizable()
                        .frame(width: 32,height: 32)
                        .foregroundColor(.black222222)
                }
                Spacer()
                
            }
            
            HStack{
                RoundedRectangle(cornerRadius: 2).foregroundColor(Color(.primary))
                RoundedRectangle(cornerRadius: 2).foregroundColor(Color(.grayF6F6F6))
            }.frame(maxWidth: .infinity)
                .frame(height: 3)
            VStack(alignment:.leading,spacing:8){
                Text("selectAccountType".localized())
                    .textModifier(.plain, 19, .black222222)
                
                // Subtitle
                Text("selectAccountTypeSubtitle".localized())
                    .textModifier(.plain, 15, .gray666666)
                
            }
            
            VStack(alignment:.leading, spacing: 8) {
                // Company or Merchant option
                AccountOptionView(
                    optionType: .companyOrMerchant,
                    isSelected: selectedOption == .companyOrMerchant,
                    isGrayOut: selectedOption != .none && selectedOption != .companyOrMerchant,
                    onSelect: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedOption = .companyOrMerchant
                        }
                    }
                )
                
                // Individual option
                AccountOptionView(
                    optionType: .individual,
                    isSelected: selectedOption == .individual,
                    isGrayOut: selectedOption != .none && selectedOption != .individual,
                    onSelect: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedOption = .individual
                        }
                    }
                )
            }
            
            Spacer()
            
            ReusableButton(buttonText: "continue", isEnabled: selectedOption != .none) {
                isShowStep2 = true
                
            }
            
        }
        .safeAreaPadding(24)
        .navigationDestination(isPresented: $isShowStep2)  {
            SignUpStep2View(selectedOption: selectedOption)
        }.navigationBarHidden(true)
        
    }
}


#Preview {
    SignUpStep1View()
}
