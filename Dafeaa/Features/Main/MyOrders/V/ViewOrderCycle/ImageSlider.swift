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
    @State private var currentIndex: Int = 1 // Start at the first actual item
    @Binding var listOfPages: [ImageModel]
    
    private var timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    // Infinite carousel Properties
    /// Contains the first and last duplicate pages in front and back to create an infinite carousel
    @State private var fakedPages: [ImageModel] = []
    var onImageTap: ((String) -> Void)?
    
    init(listOfPages: Binding<[ImageModel]>, onImageTap: ((String) -> Void)? = nil) {
        self._listOfPages = listOfPages
        self.onImageTap = onImageTap
    }
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            VStack(spacing: 10) {
                if listOfPages.count != 0 {
                    if listOfPages.count > 1 {
                        TabView(selection: $currentIndex) {
                            ForEach(fakedPages.indices, id: \.self) { index in
                                //                            Button {
                                //
                                //                            } label: {
                                ZStack {
                                    Color(.black010202)
                                    WebImage(url: URL(string: fakedPages[index].file ?? "")) { image in
                                        HStack {
                                            Spacer()
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                .tag(index)
                                                .opacity(currentIndex == index ? 1.0 : 0.5)
                                                .scaleEffect(currentIndex == index ? 1 : 0.8)
                                                .onAppear {
                                                    handleIndexTransition(index: index)
                                                }
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
                                                onImageTap?(fakedPages[index].file ?? "")
                                                //                                                isPasswordVisible.toggle()
                                            }) {
                                                Image(systemName: "viewfinder.rectangular")
                                                    .resizable()
                                                    .frame(width: 15, height: 15)
                                                    .foregroundColor(.white)
                                                    .padding([.top,.trailing],20)
                                            }
                                            
                                        }
                                        Spacer()
                                    }
                                }
                                //                            }
                                //                            .buttonStyle(PlainButtonStyle())
                            }
                            .animation(.easeIn, value: currentIndex)
                        }
                        .frame(width: size.width, height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .tabViewStyle(.page(indexDisplayMode: .never))
                    }
                    else if let singlePage = listOfPages.first {
                        Button(action: {
                            onImageTap?(singlePage.file ?? "")
                        }) {
                            // Show a single page without scrolling
                            ZStack {
                                Color(.black010202)
                                WebImage(url: URL(string: singlePage.file ?? ""))
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: size.width - 50, height: 250)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            Spacer()
                            
                            //                        }
                            //                        placeholder: {
                            //                            Image(.banner)
                            //                                .resizable()
                            //                                .scaledToFill()
                            //                                .frame(width: size.width - 100, height: 150)
                            //                                .clipped()
                            //                        }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    if listOfPages.count > 1 {
                        HStack {
                            ForEach(0..<(listOfPages.count), id: \.self) { index in
                                Capsule()
                                    .fill(originalIndex(currentIndex) == index ? .primaryF9CE29 : .grayDADADA)
                                    .frame(width: 17, height: 5)
                                    .onTapGesture {
                                        currentIndex = index
                                    }
                            }
                        }
                    }
                }
                else {
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
        }
        .frame(height: 270)
        .onReceive(timer) { _ in
            withAnimation {
                moveToNextPage()
            }
        }
        .onAppear {
            setupPages()
        }
    }
    
    ///duplicates the first and last pages to create the illusion of infinite scrolling.
    func setupPages() {
        guard fakedPages.isEmpty else { return }
        
        fakedPages.append(contentsOf: listOfPages)
        
        if listOfPages.count > 0 {
            if let firstPage = listOfPages.first,
               let lastPage = listOfPages.last {
                // For ImageModel, since it's a value type, we can just append copies
                fakedPages.insert(lastPage, at: 0) // Insert duplicate last at the start
                fakedPages.append(firstPage) // Append duplicate first at the end
                currentIndex = 1 // Start at the actual first page
            }
        }
    }
    
    func moveToNextPage() {
        if currentIndex < fakedPages.count - 1 {
            currentIndex += 1
        } else {
            currentIndex = 1
        }
    }
    
    ///ensures smooth transitions when reaching the end or beginning of the carousel.
    func handleIndexTransition(index: Int) {
        if index == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                currentIndex = fakedPages.count - 2
            }
        } else if index == fakedPages.count - 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                currentIndex = 1
            }
        }
    }
    
    func originalIndex(_ index: Int) -> Int {
        guard listOfPages.count > 0 else { return 0 }
        let pageIndex = index - 1
        return pageIndex < 0 ? listOfPages.count - 1 : pageIndex % listOfPages.count
    }
}

#Preview {
    InfiniteCarouselView(listOfPages: .constant([
        ImageModel(file: "https://example.com/image1.jpg"),
        ImageModel(file: "https://example.com/image2.jpg"),
        ImageModel(file: "https://example.com/image3.jpg")
    ]))
}
