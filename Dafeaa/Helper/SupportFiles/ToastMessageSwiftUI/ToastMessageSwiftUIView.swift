//
//  ToastMessageSwiftUIView.swift
//  
//
//  Created by AMN on 3/8/23.
//  Copyright © 2023 AppsSquare.com. All rights reserved.
//

import SwiftUI

struct FancyToastView: View {
    var type: FancyToastStyle
    var title: String
    var message: String
    var onCancelTapped: (() -> Void)
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                
                VStack(alignment: .center) {
                    Text(message)
                        .font(.custom(AppFonts.shared.name(AppFontsTypes.plain), size: 13))
                        .foregroundColor(.white)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading) 
                }
            }
            .padding(10)
        }
        .background(Color.black010202)
        .cornerRadius(8)
        .frame(minWidth: 0, maxWidth: .infinity)
        .shadow(color: Color.white.opacity(0.25), radius: 4, x: 0, y: 1)
        .padding(.horizontal, 16)
    }
}


enum FancyToastStyle {
    case error
    case warning
    case success
    case info
}

extension FancyToastStyle {
    var themeColor: Color {
        switch self {
        case .error: return Color.black010202
        case .warning: return Color.orange
        case .info: return Color.blue
        case .success: return Color.green
        }
    }
}

struct FancyToast: Equatable {
    var type: FancyToastStyle
    var title: String
    var message: String
    var duration: Double = 3
}

struct FancyToastView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
        FancyToastView(
            type: .error,
            title: "Error",
            message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. ") {}
        
        FancyToastView(
            type: .info,
            title: "Info",
            message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. ") {}
    }
  }
}

struct FancyToastModifier: ViewModifier {
    @Binding var toast: FancyToast?
    @State private var workItem: DispatchWorkItem?
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                ZStack {
                    mainToastView()
                        .offset(y: -30)
                }.animation(.spring(), value: toast)
            )
            .onChange(of: toast) {
                showToast()
            }
    }
    
    @ViewBuilder func mainToastView() -> some View {
        if let toast = toast {
            VStack {
                Spacer()
                FancyToastView(
                    type: toast.type,
                    title: toast.title,
                    message: toast.message) {
                        dismissToast()
                    }
            }.padding(.bottom,70)
            .transition(.move(edge: .bottom))
        }
    }
    
    private func showToast() {
        guard let toast = toast else { return }
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        if toast.duration > 0 {
            workItem?.cancel()
            
            let task = DispatchWorkItem {
               dismissToast()
            }
            
            workItem = task
            DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration, execute: task)
        }
    }
    
    private func dismissToast() {
        withAnimation {
            toast = nil
        }
        
        workItem?.cancel()
        workItem = nil
    }
}

extension View {
    func toastView(toast: Binding<FancyToast?>) -> some View {
        self.modifier(FancyToastModifier(toast: toast))
    }
}
