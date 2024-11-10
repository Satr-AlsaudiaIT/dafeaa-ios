//
//  PopUpComponent.swift
//  Dafeaa
//
//  Created by AMNY on 06/11/2024.
//

import SwiftUI

struct PopUpComponent: View {
    var title : String = ""
    var question : String = ""
    @Binding var isShowing: Bool
    var action: () -> Void
    
    
    var body: some View {
        ZStack {
            Color(.gray888888).opacity(0.4)
            VStack {
                Spacer()
                ZStack {
                    VStack(spacing: 0) {
                        Text(title.localized())
                            .textModifier(.bold, 22, .black010202)
                        Text(question.localized())
                            .textModifier(.plain, 15,.black222222)
                            .multilineTextAlignment(.center)
                            .padding([.horizontal,.bottom],24)
                            .padding(.top,16)
                        HStack {
                            ReusableButton(buttonText: "Cancel",buttonColor: .gray) {
                                isShowing = false
                            }
                            ReusableButton(buttonText: "Confirm",buttonColor: .black) {
                                action()
                            }
                        }
                        .padding(.horizontal,24)
                    }
                    .padding(.all,24)
                }
                .background(Color.white)
                .cornerRadius(10)
                .padding(.horizontal,24)
                .shadow(color: Color(.dropShadow2B2D3333).opacity(0.2) , radius: 24, x: 0, y: 10)
                
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}


#Preview {
    PopUpComponent( title: "Cancel order", question: "Are you sure you want to cancel this order?".localized(), isShowing: .constant(true), action: {
        
    })
}
