//
//  LottieAnimationView.swift
//  Dafeaa
//
//  Created by AMNY on 16/10/2024.
//

import SwiftUI
import Lottie

//struct LottieView: UIViewRepresentable {
//    
//    var animationFileName: String
//    let loopMode: LottieLoopMode
//    var width: CGFloat
//    var height: CGFloat
//    
//    func makeUIView(context: Context) -> LottieAnimationView {
//        let animationView = LottieAnimationView(name: animationFileName)
//        animationView.loopMode = loopMode
//        animationView.contentMode = .scaleAspectFit
//        animationView.translatesAutoresizingMaskIntoConstraints = false  // Important for SwiftUI layout
//
//        // Auto Layout Constraints to dynamically adjust to provided size
//        NSLayoutConstraint.activate([
//            animationView.widthAnchor.constraint(equalToConstant: width),
//            animationView.heightAnchor.constraint(equalToConstant: height)
//        ])
//
//        animationView.play()
//        return animationView
//    }
//
//    func updateUIView(_ uiView: LottieAnimationView, context: Context) {
//        // This can be used to update the view, if needed
//    }
//}
