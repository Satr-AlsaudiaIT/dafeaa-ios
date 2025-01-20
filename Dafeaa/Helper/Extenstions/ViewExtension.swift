//
//  ViewExtension.swift
//  Movie App
//
//  Created by AMN on 4/5/23.
//  Copyright © 2023 Nura. All rights reserved.
//

import SwiftUI
extension View {
    func flipped(_ axis: Axis? = .horizontal, anchor: UnitPoint = .center) -> some View {
        switch axis {
        case .horizontal:
            return scaleEffect(CGSize(width: -1, height: 1), anchor: anchor)
        case .vertical:
            return scaleEffect(CGSize(width: 1, height: -1), anchor: anchor)
        case .none:
            return scaleEffect(CGSize(width: 1, height: 1), anchor: anchor)        }
    }
    // Subscribe to keyboard events
     func subscribeToKeyboardEvents(keyboardHeight: CGFloat = 0) {
      var keyboardHeightInternal : CGFloat = keyboardHeight

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
//               if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
////                   withAnimation {
////                       self.keyboardHeight = keyboardSize.height - 20
////                   }
//               }
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            withAnimation {
                keyboardHeightInternal = 0
            }
        }
    }
    
    // Unsubscribe from keyboard events
     func unsubscribeFromKeyboardEvents() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    
}

struct RoundedCornersShape: Shape {
    let corners: UIRectCorner
    let radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

//extension EnvironmentValues {
//    public var presentationMode: Binding<PresentationMode> {get}
//    
//}

extension View {
    func specificCornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( DefineRoundedCorner(radius: radius, corners: corners) )
    }
    
}
struct DefineRoundedCorner: Shape {
    let radius: CGFloat
    let corners: UIRectCorner

    init(radius: CGFloat = .infinity, corners: UIRectCorner = .allCorners) {
        self.radius = radius
        self.corners = corners
    }

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

class AnyGestureRecognizer: UIGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if let touchedView = touches.first?.view, touchedView is UIControl {
            state = .cancelled

        } else if let touchedView = touches.first?.view as? UITextView, touchedView.isEditable {
            state = .cancelled

        } else {
            state = .began
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
       state = .ended
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .cancelled
    }
}
struct GestureWrapperView<Content: View>: View {
    @EnvironmentObject var keyboardDismissManager: KeyboardDismissManager
    var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .background(
                Color.clear
                    .contentShape(Rectangle()) // Makes the whole view tappable
                    .gesture(
                        TapGesture()
                            .onEnded {
                                if keyboardDismissManager.shouldDismissKeyboard {
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                            }
                    )
            )
    }
}
import Combine

class KeyboardDismissManager: ObservableObject {
    @Published var shouldDismissKeyboard: Bool = true // Default is true
    var cancellables = Set<AnyCancellable>() // Store Combine subscriptions
}
