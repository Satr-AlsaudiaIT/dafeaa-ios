//
//  InfiniteCarouselView.swift
//  Dafeaa
//
//  Created by AMNY on 19/04/2025.
//

import SwiftUI
import Combine
import SDWebImageSwiftUI

struct InfiniteCarouselView: View {
    // View Properties
    @State private var currentIndex: Int = 0
    @Binding var listOfPages: [ImageModel]
    
    private var timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    var onImageTap: ((String) -> Void)?

    init(listOfPages: Binding<[ImageModel]>, onImageTap: ((String) -> Void)? = nil) {
        self._listOfPages = listOfPages
        self.onImageTap = onImageTap
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // TabView with GeometryReader
            GeometryReader { proxy in
                let size = proxy.size
                
                if !listOfPages.isEmpty {
                    TabView(selection: $currentIndex) {
                        ForEach(listOfPages.indices, id: \.self) { index in
                            ZStack {
                                WebImage(url: URL(string: listOfPages[index].file ?? "")) { image in
                                    HStack {
                                        Spacer()
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            .scaleEffect(currentIndex == index ? 1 : 0.8)
                                        Spacer()
                                    }
                                } placeholder: {
                                    Image(.process)
                                        .resizable()
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                
                                VStack {
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            onImageTap?(listOfPages[index].file ?? "")
                                        }) {
                                            Image(systemName: "viewfinder.rectangular")
                                                .resizable()
                                                .frame(width: 15, height: 15)
                                                .foregroundColor(.white)
                                                .padding([.top, .trailing], 20)
                                        }
                                    }
                                    Spacer()
                                }
                            }
                            .background(Color(.grayADADAD))
                            .tag(index)
                        }
                    }
                    .frame(width: size.width, height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .tabViewStyle(.page(indexDisplayMode: .never))
                } else {
                    HStack {
                        Spacer()
                        Image(.process)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        Spacer()
                    }
                }
            }
            .frame(height: 250)
            
            // Page indicators - OUTSIDE GeometryReader
            if listOfPages.count > 1 {
                HStack(spacing: 8) {
                    ForEach(listOfPages.indices, id: \.self) { index in
                        Capsule()
                            .fill(currentIndex == index ? Color.primaryF9CE29 : Color.grayDADADA)
                            .frame(width: 17, height: 5)
                            .onTapGesture {
                                withAnimation {
                                    currentIndex = index
                                }
                            }
                    }
                }
                .padding(.top, 8)
            }
        }
        .frame(height: 270)
        .onReceive(timer) { _ in
            withAnimation {
                moveToNextPage()
            }
        }
    }
    
    func moveToNextPage() {
        guard !listOfPages.isEmpty else { return }
        currentIndex = (currentIndex + 1) % listOfPages.count
    }
}

#Preview {
    InfiniteCarouselView(listOfPages: .constant([
        ImageModel(file: "https://example.com/image1.jpg"),
        ImageModel(file: "https://example.com/image2.jpg"),
        ImageModel(file: "https://example.com/image3.jpg")
    ]))
}
