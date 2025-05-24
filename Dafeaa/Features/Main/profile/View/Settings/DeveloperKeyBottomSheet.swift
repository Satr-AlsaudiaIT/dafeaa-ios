//
//  DeveloperKeyBottomSheet.swift
//  Dafeaa
//
//  Created by AMNY on 26/04/2025.
//

import SwiftUI

struct DeveloperKeyBottomSheet: View {
    @Binding var isSheetPresented: Bool
    @State var profileID: String = "************************"
    @State var secretKey: String = "************************"
    @State private var dots: String = "************************"
    @State private var showProfileID: Bool = false
    @State private var showSecretKey: Bool = false
    @StateObject var viewModel = MoreVM()
    @State var toast: FancyToast? = nil

    var body: some View {
        ZStack {
            Color.clear
            VStack(spacing: 24) {
                // Header
                Text("developerKeys".localized())
                    .textModifier(.plain, 16, .black222222)
                    .padding(.top, 40)
                
                // Profile ID Section
                keySection(
                    title: "profile_id".localized(),
                    value: showProfileID ? profileID : dots,
                    copyAction: {
                        UIPasteboard.general.string = profileID
                        self.toast = FancyToast(type: .info, title:"", message:  "copied successfully".localized())
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                            isSheetPresented = false
//                        }
                    },
                    toggleAction: { showProfileID.toggle() },
                    showValue: showProfileID
                )
                
                // Secret Key Section
                keySection(
                    title: "secret_key".localized(),
                    value: showSecretKey ? secretKey : dots,
                    copyAction: {
                        UIPasteboard.general.string = secretKey
                        self.toast = FancyToast(type: .info, title:"", message:  "copied successfully".localized())
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                            isSheetPresented = false
//                        }
                    },
                    toggleAction: { showSecretKey.toggle() },
                    showValue: showSecretKey
                )
                
                // Reset Codes Button
                ReusableButton(
                    buttonText: "reset_codes".localized(),
                    isEnabled: true
                ) {
                    viewModel.updateSecretKey()
                }
                .padding(.top, 8)
                .padding(.bottom, 20)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .background(Color.white)
            .cornerRadius(24)
            if viewModel.isLoading {
                ProgressView("Loading...".localized())
                    .foregroundColor(.white)
                    .progressViewStyle(WithBackgroundProgressViewStyle())
            } else if viewModel.isFailed {
                ProgressView()
                    .hidden()
            }
        }.onReceive(viewModel.$_isSuccess){ isSuccess in
            isSuccess ?
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isSheetPresented = false
            }: ()}
        .toastView(toast: $toast)
        .toastView(toast: $viewModel.toast)


    }
    
    private func keySection(title: String, value: String, copyAction: @escaping () -> Void, toggleAction: @escaping () -> Void, showValue: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .textModifier(.plain, 13, .black222222)
            
            HStack(spacing: 10) {
                Text(value)
                    .textModifier(.plain, 15, .grayB5B5B5)
                    
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color.grayFAFAFA)
                    .cornerRadius(5)
                
                Button(action: copyAction) {
                    HStack(spacing: 8) {
                        Image(.copy)
                            .resizable()
                            .frame(width: 32, height: 32)
                        Text("copy".localized())
                            .textModifier(.plain, 15, .black222222)
                    }
                   
                }.frame(width: 100, height: 48)
                .border(Color.black.opacity(0.1))
                .cornerRadius(5)
               
            }.frame( height: 48)
                .frame(maxWidth: .infinity)
            
            Button(action: toggleAction) {
                HStack(spacing: 10){
                    Image(showValue ? .eye : .eyeSlash)
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text(showValue ? "hide_code".localized() : "show_code".localized())
                        .textModifier(.plain, 12, .grayBDBDBD)
                }
            }
        }
       
    }
}

#Preview {
    DeveloperKeyBottomSheet(isSheetPresented: .constant(true))
}
