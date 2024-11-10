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
            if let image = image {
                Image(uiImage: image)
            }
            Text(buttonText.localized())
                .font(.system(size: 15, weight: .bold))
                .textModifier(.plain, 16,.gray8B8C86)
                .frame(maxWidth: .infinity)
                
            
        }
        
    }
}

//#Preview {
//    WalletButton()
//}

