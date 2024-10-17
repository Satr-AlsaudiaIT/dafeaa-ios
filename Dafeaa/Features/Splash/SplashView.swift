//
//  OnBoardingView.swift
//  Dafeaa
//
//  Created by M.Magdy on 01/10/2024.
//

import SwiftUI

struct SplashView: View {
    @State private var isScaledDown = false
    @State private var isDisappearing: Bool = false
    var window: UIWindow?
    init(window: UIWindow?) {
           self.window = window
       }
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                ZStack {
                    Image(.splashLogoWithName)
                        .resizable()
                        .frame(width: 191,height: 81)
                        .scaleEffect(isScaledDown ? 1 : 1.6)
                        .offset(x: isScaledDown ? 0 : UIScreen.main.bounds.width / 2 - 106)
                        .padding(.leading,isScaledDown ? 0 : 8 )
                        .animation(.easeInOut(duration: 1.5))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                isScaledDown.toggle()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    goTo()
                                }
                            }
                        }
                    
                    Rectangle()
                        .fill(.white)
                        .frame(width: isScaledDown ? 0 : UIScreen.main.bounds.width / 2, height: 300)
                        .padding(.leading, (UIScreen.main.bounds.width / 2) + 132 )
                        .animation(.easeInOut(duration: 1.5))
                }
                Spacer()
            }
            VStack(alignment: .leading) {
                Spacer()
                HStack {
                    Image(.splashBottomCorner)
                    Spacer()
                }
                .frame(width: UIScreen.main.bounds.width)
                
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .onDisappear{
            isDisappearing = true
        }
        .environment(\.layoutDirection, .leftToRight)
        .animation(.easeInOut(duration: 0.3), value: isDisappearing)
    }
    
    private func goTo(){
        let onboarding = GenericUserDefault.shared.getValue(Constants.shared.onboarding) as? Bool ?? false
        let token = GenericUserDefault.shared.getValue(Constants.shared.token) as? String ?? ""
        
        print("token \(token)\(onboarding)")
        if onboarding != true {
            onboardingTransition()
        }else{
            token == "" ? authorizationTransition() : tabBarTransition()
            self.window?.makeKeyAndVisible()
            
        }
    }
    
    func tabBarTransition() {
        window?.rootViewController = UIHostingController(rootView: PendingView() .environment(\.locale, Locale(identifier: Constants.shared.isAR ? "ar":"en"))
        .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft:.leftToRight))
        

    }
    
    func onboardingTransition(){
        window?.rootViewController = UIHostingController(rootView: OnBoardingView() .environment(\.locale, Locale(identifier: Constants.shared.isAR ? "ar":"en"))
        .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft:.leftToRight))
    }
    
    func authorizationTransition() {
        window?.rootViewController = UIHostingController(rootView: LoginView() .environment(\.locale, Locale(identifier: Constants.shared.isAR ? "ar":"en"))
        .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft:.leftToRight))

    }
    
    //change rootview
    func changeRoot(_ vc:UIViewController) {
        UIView.transition(with: self.window!, duration: 0.5, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
            self.window?.rootViewController = vc
        }, completion: nil)
    }
    
}

//#Preview {
//    SplashView()
//}
