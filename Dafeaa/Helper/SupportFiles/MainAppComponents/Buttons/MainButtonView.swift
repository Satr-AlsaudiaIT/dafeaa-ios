//
//  YellowButtonView.swift
//  Proffer
//
//  Created by M.Magdy on 07/10/2024.
//

import SwiftUI
enum ButtonColors {
    case black
    case yellow
    case transparent
    
    // Function to return the correct color from assets
    func color() -> Color {
        switch self {
        case .black:
            return Color(.black222222)
        case .yellow:
            return Color(.primary)
        case .transparent:
            return Color.clear
        }
    }
}

  
//struct MainButtonView: View {
//    @State var buttonTitle:String
//    @State var buttonColor: ButtonColors
//    @State var titleSize: CGFloat = 18
//    @State var width: CGFloat = 220
//    @State var height: CGFloat = 48
//    @State var radius: CGFloat = 24
//    var body: some View {
//            HStack {
//                Spacer()
//                Text(buttonTitle)
//                    .font(.custom(AppFonts.shared.name(AppFontsTypes.plain), size: titleSize))
//                    .foregroundStyle(buttonColor == .transparent ? Color(Asset.mainOrangeColor.name): Color(.white))
//                    .frame(height: height)
//                Spacer()
//            }
//            .frame(height: height)
//            .background(Color(buttonColor == .orange ? (Asset.mainOrangeColor.name) : (buttonColor == .blue ? Asset.secondBlueColor.name : Asset.white.name) ))
//            .overlay(RoundedRectangle(cornerRadius: radius)
//                .stroke(Color.init(buttonColor == .blue ? (Asset.secondBlueColor.name) : (Asset.mainOrangeColor.name)), lineWidth: 1))
//            .frame(width: width)
//            .cornerRadius(radius)
//            
//        
//    }
//}
//
//#Preview {
//    MainButtonView(buttonTitle: "Ttile", buttonColor: .transparent)
//}

import SwiftUI

struct ReusableButton: View {
    var buttonText: String
    var isEnabled: Bool = true
    var action: () -> Void
    @State var buttonColor: ButtonColors = .black

    
    var body: some View {
        Button(action: {
            if isEnabled {
                action()
            }
        }) {
            Text(buttonText)
                .font(.system(size: 15, weight: .bold))
                .textModifier(.plain, 15,.white)
                .frame(maxWidth: .infinity, minHeight: 51)
                .background(isEnabled ? Color(buttonColor.color()) : Color(.grayDADADA))
                .cornerRadius(32)
        }
        .disabled(!isEnabled)
        .shadow(color: isEnabled ? Color(.dropShadow2B2D3333).opacity(0.2) : .clear, radius: 24, x: 0, y: 10)
    }
}

#Preview {
    VStack {
        ReusableButton(buttonText: "الاستمرار",isEnabled: false) {
            print("Button Pressed")
        }
        
        ReusableButton(buttonText: "الاستمرار") {
            print("Button Pressed")
        }
    }
}
