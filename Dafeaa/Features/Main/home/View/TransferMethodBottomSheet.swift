//
//  TransferMethodBottomSheet.swift
//  Dafeaa
//
//  Created by AMNY on 20/01/2026.
//

import SwiftUI

enum TransferMethod {
    case iban
    case phone
}

struct TransferMethodBottomSheet: View {
    @Binding var isSheetPresented: Bool
    @Binding var navigateToIBANTransfer: Bool
    @Binding var navigateToPhoneTransfer: Bool
    
    var body: some View {
        ZStack {
            Color.clear
            VStack(spacing: 24) {
              
                
                Text("Choose transfer method".localized())
                    .textModifier(.bold, 19, .gray8B8C86)
                    .padding(.horizontal, 24)
                    .padding(.top,50)
                
                // Transfer Methods
                VStack(alignment: .leading,spacing: 16) {
                    // Phone Transfer
                    Button {
                        navigateToPhoneTransfer = true
                        isSheetPresented = false
                    } label: {
                        HStack(spacing: 16) {
                            Image(.transferPhone)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Transfer using phone number".localized())
                                    .textModifier(.plain, 14, .black222222)
                             
                            }
                            
                            Spacer()
                            
                            Image(systemName: Constants.shared.isAR ? "chevron.left" :  "chevron.right")
                                .foregroundColor(.gray8B8C86)
                        }
                        .padding(16)
                        .background(Color(.grayF6F6F6))
                        .cornerRadius(12)
                    }
                    
                    // IBAN Transfer
                    Button {
                        navigateToIBANTransfer = true
                        isSheetPresented = false
                    } label: {
                        HStack(spacing: 16) {
                            Image(.transferIban)
                                
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Transfer using IBAN".localized())
                                    .textModifier(.plain, 14, .black222222)
                            }
                            
                            Spacer()
                            
                            Image(systemName: Constants.shared.isAR ? "chevron.left" :  "chevron.right")
                                .foregroundColor(.gray8B8C86)
                        }
                        .padding(16)
                        .background(Color(.grayF6F6F6))
                        .cornerRadius(12)
                    }

                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .padding(.bottom, 40)
            .background(Color.white)
            .cornerRadius(24)
        }
        .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft : .leftToRight)
    }
}
