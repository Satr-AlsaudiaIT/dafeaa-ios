//
//  SuccessView.swift
//  Dafeaa
//
//  Created by AMNY on 16/10/2024.
//

import SwiftUI
import Lottie

struct PendingView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var phoneNumber: String = ""
    @State private var selectedCountryCode: String = ""
    @State private var isSendSuccess: Bool = false
    @StateObject var viewModel = AuthVM()

    
    var body: some View {
        ZStack{
            VStack {
                NavigationBarView(title: "PendingViewNavTitle")
                            
                    VStack(spacing: 0){        
                        Spacer()

                        LottieView(animation:  .named("pending"))
                            .playing(loopMode: .playOnce)
                            .frame(width: 144, height: 144)
                        HStack {
                            Spacer()
                            Text("pendingViewTitle".localized())
                                .textModifier(.plain, 19, .black222222)
                                .frame(maxWidth: .infinity)
                                .padding(.top,24)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        Text("pendingViewSubTitle".localized())
                            .frame(maxWidth: .infinity,alignment: .leading)
                            .textModifier(.plain, 15, .gray666666)
                            .padding(.top,5)
                            .multilineTextAlignment(.center)
                        Spacer()
                        ReusableButton(buttonText: "send",image: .loading, buttonColor: .gray){
                            viewModel.validateForgetPasswordPhone(phone:phoneNumber)
                        }.padding(.top,16)
                            .navigationDestination(isPresented: $isSendSuccess) {
                                OTPConfirmationView()
                            }
                    }.padding(24)
            }.navigationDestination(isPresented: $viewModel._isSendCodeSuccess) {
                OTPConfirmationView(phone: phoneNumber,isForgetPassword: true)
            }
            if viewModel.isLoading {
                ProgressView("Loading...".localized())
                    .foregroundColor(.white)
                    .progressViewStyle(WithBackgroundProgressViewStyle())
            } else if viewModel.isFailed {
                ProgressView()
                    .hidden()
            }
        }
        .navigationBarHidden(true)
        .toastView(toast: $viewModel.toast)

    }
}

#Preview {
    PendingView()
}
