//
//  StaticPagesList.swift
//  Dafeaa
//
//  Created by AMNY on 13/03/2025.
//


import SwiftUI

struct StaticPagesList: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
 
    
    var body: some View {
        ZStack{
            VStack {
                NavigationBarView(title: "About Dafeaa"){
                    self.presentationMode.wrappedValue.dismiss()
                }

                VStack() {
                    VStack(spacing: 16) {
                        NavigationLinkComponent(
                            destination: StaticPagesView(type: .constant(.termsAndCondition)),
                            label: "Terms&Conditions",
                            image: Image(.iconProfile)
                        )
                        
                        NavigationLinkComponent(
                            destination: StaticPagesView(type: .constant(.privacyPolicy)) ,
                            label: "privacy",
                            image: Image(.iconAddress)
                        )
                        
                    }
                    Spacer()
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
    }
    
}

#Preview {
    StaticPagesList()
}
