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
