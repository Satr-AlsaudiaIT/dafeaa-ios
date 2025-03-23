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
    case gray
    
    // Function to return the correct color from assets
    func color() -> Color {
        switch self {
        case .black:
            return Color(.black222222)
        case .yellow:
            return Color(.primary)
        case .transparent:
            return Color.clear
        case .gray:
            return Color(.grayDADADA)
        }
    }
}

  
import SwiftUI

struct ReusableButton: View {
    var buttonText: String
    var isEnabled: Bool = true
    var image : UIImage?
    @State var buttonColor: ButtonColors = .black
    var cornerRadius: CGFloat = 32
    var action: () -> Void

    
    var body: some View {
        Button(action: {
            if isEnabled {
                action()
            }
        }) {
            Text(buttonText.localized())
                .textModifier(.plain, 15,.white)
                .frame(maxWidth: .infinity, minHeight: 51)
                .background(isEnabled ? Color(buttonColor.color()) : Color(.grayDADADA))
                .cornerRadius(cornerRadius)
            if let image = image {
                Image(uiImage: image)
            }
        }
        .disabled(!isEnabled)
        .shadow(color: isEnabled ? Color(.dropShadow2B2D3333).opacity(0.2) : .clear, radius: 5)
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
