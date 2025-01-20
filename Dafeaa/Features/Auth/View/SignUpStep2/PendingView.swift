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
    @StateObject var viewModel = MoreVM()

    
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
                        ReusableButton(buttonText: "checkAgain",isEnabled: true, image: .loading, buttonColor: .black){
                            viewModel.profile()
                        }.padding(.top,16)
                            
                    }.padding(24)
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
        .onAppear{viewModel.profile()}
        .onReceive(viewModel.$_isActive){ isActive in
            isActive ? tabBarTransition(): ()}
    }
    
    func tabBarTransition() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let window = appDelegate.window {
            window.rootViewController = UIHostingController(
                rootView: TabBarView()
                    .environment(\.locale, Locale(identifier: Constants.shared.isAR ? "ar" : "en"))
                    .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft : .leftToRight)
            )
            
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil)
            
            window.makeKeyAndVisible()
        }
    }
}

#Preview {
    PendingView()
}
