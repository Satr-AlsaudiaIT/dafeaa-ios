//
//  WalletButton.swift
//  Dafeaa
//
//  Created by AMNY on 25/10/2024.
//

import SwiftUI

struct WalletButton: View {
    var buttonText: String
    var image : UIImage?
    var action: () -> Void

    
    var body: some View {
        Button(action: {
                action()
            
        }) {
            VStack(spacing: 0) {
                if let image = image {
                    Image(uiImage: image)
                }
                Text(buttonText.localized())
                    .textModifier(.plain, 12,.gray8B8C86)
//                    .minimumScaleFactor(0.7)
//                    .lineLimit(2)
                    .frame(maxWidth: .infinity)
            }
        }
        
    }
}

//#Preview {
//    WalletButton()
//}

