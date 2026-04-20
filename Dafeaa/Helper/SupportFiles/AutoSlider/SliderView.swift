//
//  AutoSlider.swift
//
//
//  Created by AMN on 4/18/23.
//  Copyright © 2023  Nura. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct SliderView: View {
    public let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    @State private var selection = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging: Bool = false
    @State private var lastInteractionTime: Date = .distantPast
    private let autoScrollDelay: TimeInterval = 3.0

    @Binding var images: [String]
    @Binding var isHiddenPageIndicator: Bool
    @Binding var isWebImage: Bool
    @Binding var isIndicatorSeparated: Bool
    var widthFraction: CGFloat
    var itemAspectRatio: CGFloat

    init(images: Binding<[String]>,
         isHiddenPageIndicator: Binding<Bool>,
         isWebImage: Binding<Bool>,
         isIndicatorSeparated: Binding<Bool>,
         widthFraction: CGFloat = 0.8,
         itemAspectRatio: CGFloat = 2.0) {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(.primaryF9CE29)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(.garyD9D9D9)
        UIPageControl.appearance().backgroundColor = .clear
        self._images = images
        self._isHiddenPageIndicator = isHiddenPageIndicator
        self._isWebImage = isWebImage
        self._isIndicatorSeparated = isIndicatorSeparated
        self.widthFraction = widthFraction
        self.itemAspectRatio = itemAspectRatio
        UIPageControl.appearance().isHidden = self.isIndicatorSeparated ? true : self.isHiddenPageIndicator
    }

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width * widthFraction
            let height = width / itemAspectRatio
            let horizontalPadding = (geo.size.width - width) / 2

            VStack(spacing: 0) {
                ZStack {
                    TabView(selection: $selection) {
                        ForEach(0..<images.count, id: \.self) { i in
                            Group {
                                if isWebImage {
                                    WebImage(url: URL(string:images[i]))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: width, height: height)
                                        .clipped()
                                } else {
                                    Image("banner" + images[i])
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: width, height: height)
                                        .clipped()
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .tag(i)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
                    .frame(width: width, height: height)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .gesture(
                        DragGesture(minimumDistance: 20)
                            .onChanged { value in
                                isDragging = true
                                dragOffset = value.translation.width
                                lastInteractionTime = Date()
                            }
                            .onEnded { value in
                                isDragging = false
                                dragOffset = 0
                                lastInteractionTime = Date()
                                let threshold: CGFloat = 50
                                let drag = value.translation.width
                                guard images.count > 1 else { return }
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    if drag < -threshold {
                                        selection = selection < images.count - 1 ? selection + 1 : 0
                                    } else if drag > threshold {
                                        selection = selection > 0 ? selection - 1 : images.count - 1
                                    }
                                }
                            }
                    )
                }
                .frame(width: width, height: height)
                .padding(.horizontal, horizontalPadding)

                if isIndicatorSeparated {
                    HStack(spacing: 3) {
                        ForEach(0..<images.count, id: \.self) { index in
                            Circle()
                                .fill(selection == index ? Color(.primaryF9CE29) : Color(.garyD9D9D9))
                                .frame(
                                    width: selection == index ? 10 : 7,
                                    height: selection == index ? 10 : 7
                                )
                                .animation(.easeInOut, value: selection)
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .onReceive(timer) { _ in
                guard images.count > 1 else { return }
                guard Date().timeIntervalSince(lastInteractionTime) >= autoScrollDelay else { return }
                withAnimation(.easeInOut(duration: 0.5)) {
                    selection = selection < images.count - 1 ? selection + 1 : 0
                }
            }
        }
        .aspectRatio(itemAspectRatio + (1 / widthFraction - 1) * itemAspectRatio * 0.5, contentMode: .fit)
    }
}
