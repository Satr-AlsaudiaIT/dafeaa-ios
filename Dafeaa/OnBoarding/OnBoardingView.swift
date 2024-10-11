//
//  OnBoardingView.swift
//  Dafeaa
//
//  Created by M.Magdy on 01/10/2024.
//

import SwiftUI

struct OnBoardingView: View {
    @Namespace var namespace
    @State private var isScaledDown = false
    @State private var currentIndex = 0
    @State private var isAppearing = true
    @State private var viewAppear = false
    let onboardingData = [
        ("onboarding1", "onboardingTitle1".localized(),"onboardingDesc1".localized()),
        ("onboarding2", "onboardingTitle2".localized(),"onboardingDesc2".localized()),
        ("onboarding3", "onboardingTitle3".localized(),"onboardingDesc3".localized())
    ]
    init() {
           UIPageControl.appearance().isHidden = true
       }
    var body: some View {
        ZStack {
            TabView(selection: $currentIndex) {
                ForEach(0..<onboardingData.count, id: \.self) { index in
                        VStack(alignment: .center, spacing: 0) {
                            if currentIndex == 0 {
                                Image(.splashLogoWithoutName)
                                    .resizable()
                                    .frame(width: isScaledDown ? 57 : 71 ,height: isScaledDown ?  65 : 81)
                                    .safeAreaPadding(.top,isScaledDown ? 24 : (UIScreen.main.bounds.height - 81) / 2)
                                    .padding(.leading, isScaledDown ? 0 : -100)
                                    .onAppear{
                                        isScaledDown.toggle()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                                            viewAppear = true
                                        }
                                    }
                                    .animation(.easeInOut(duration: 1))
                                    .environment(\.layoutDirection, .leftToRight)
                                Spacer(minLength: 15)
                            }else {
                                Image(.splashLogoWithoutName)
                                    .resizable()
                                    .frame(width:  57  ,height:  65 )
                                    .safeAreaPadding(.top,24 )
                                    .padding(.leading,  0  )
                                    
                                Spacer(minLength: 15)
                            }
                            if viewAppear {
                                VStack {
                                    Image(onboardingData[index].0)
                                        .resizable()
                                        .aspectRatio(375 / 385, contentMode: .fit)
                                    
                                    VStack(spacing: 16) {
                                        
                                        HStack(spacing: 8) {
                                            ForEach(0..<onboardingData.count, id: \.self) { dotIndex in
                                                Circle()
                                                    .fill(dotIndex == currentIndex ? Color(.primary) : Color(.grayE7E7E7))
                                                    .frame(width: 12, height: 12)
                                            }
                                        }
                                        .padding(.top, 7)
                                        
                                        
                                        VStack(spacing: 10){
                                            Text(onboardingData[index].1)
                                                .textModifier(.plain, 22, .blackTitles)
                                                .multilineTextAlignment(.center)
                                               
                                            Text(onboardingData[index].2)
                                                .textModifier(.plain, 15, Color(.gray8B8C86))
                                                .multilineTextAlignment(.center)
                                                .padding(.horizontal)
                                                .frame(height:70 )
                                        }
                                        
                                        Button(action: {
                                            if currentIndex < onboardingData.count - 1 {
                                                currentIndex += 1
                                            } else {
                                                onboardingTransition()                                        }
                                        }, label: {
                                            Text( currentIndex == 2 ? "Start Now".localized() : "Next".localized())
                                                .textModifier(.plain, 15, currentIndex == 2 ? .blackTitles : .white)
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .background(Color( currentIndex == 2 ? .primary : .blackTitles))
                                                .frame(height: 50)
                                                .cornerRadius(25)
                                                .multilineTextAlignment(.center)
                                        }).padding(.vertical, 16)
                                            .shadow(color: Color(.dropShadow2B2D3333).opacity(0.2), radius: 24, x: 0, y: 10)
                                    }
                                    .padding(24)
                                    .background(Color(.grayF6F6F6))
                                    .clipShape(RoundedCorner(radius: 40, corners: [.topLeft, .topRight]))
                                    .overlay(
                                        RoundedCorner(radius: 40, corners: [.topLeft, .topRight])
                                            .stroke(Color(.black).opacity(0.10), lineWidth: 1))
                                }
                            }
                            
                    }
                    .tag(index)

                }
                .edgesIgnoringSafeArea(.bottom)

            }
            .tabViewStyle(PageTabViewStyle())
        }
        .edgesIgnoringSafeArea(.bottom)
        .environment(\.layoutDirection, .rightToLeft)
        .animation(.easeInOut(duration: 0.3), value: isAppearing)


    }
    
    private func onboardingTransition(){
        GenericUserDefault.shared.setValue(true, Constants.shared.onboarding)
               
               if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                 
                   appDelegate.window?.rootViewController = UIHostingController(rootView: LoginView()
                       .environment(\.locale, Locale(identifier: Constants.shared.isAR ? "ar":"en"))
                       .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft:.leftToRight))
                   appDelegate.window?.makeKeyAndVisible()
               }
    }
    
   
}


#Preview {
    OnBoardingView()
}
