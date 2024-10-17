//
//  LottieAnimationView.swift
//  Dafeaa
//
//  Created by AMNY on 16/10/2024.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    
    var animationFileName: String
    let loopMode: LottieLoopMode
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    func makeUIView(context: Context) -> Lottie.LottieAnimationView {
        let animationView = LottieAnimationView(name: animationFileName)
        animationView.loopMode = loopMode
        animationView.play()
//        animationView.frame.size = view_animation.frame.size
        animationView.contentMode = .scaleAspectFit
        return animationView
    }
}
