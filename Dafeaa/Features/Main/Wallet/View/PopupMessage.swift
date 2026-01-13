//
//  PopupMessage.swift
//  Dafeaa
//
//  Created by AMNY on 13/01/2026.
//

import SwiftUICore
import SwiftUI


// MARK: - Popup View Model
struct PopupMessage: Equatable {
    enum PopupType {
        case success
        case failure
    }
    
    let type: PopupType
    let title: String
    let message: String
}

// MARK: - Custom Popup View
struct CustomPopupView: View {
    let popup: PopupMessage
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                        .frame(width: 24, height: 24)
                }
            }
            
            Image(systemName: popup.type == .success ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(popup.type == .success ? .green : .red)
            
            VStack(spacing: 8) {
                Text(popup.title)
                    .textModifier(.extraBold, 18, .black222222)
                
                Text(popup.message)
                    .textModifier(.plain, 14, .black222222.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(24)
        .frame(maxWidth: 300)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Popup Modifier
struct PopupModifier: ViewModifier {
    @Binding var popup: PopupMessage?
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if popup != nil {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3)) {
                            popup = nil
                        }
                    }
                
                CustomPopupView(popup: popup!) {
                    withAnimation(.spring(response: 0.3)) {
                        popup = nil
                    }
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onChange(of: popup) { _, newValue in
            if newValue != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.spring(response: 0.3)) {
                        popup = nil
                    }
                }
            }
        }
    }
}

extension View {
    func popupView(popup: Binding<PopupMessage?>) -> some View {
        modifier(PopupModifier(popup: popup))
    }
}
