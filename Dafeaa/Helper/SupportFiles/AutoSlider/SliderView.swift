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
        
        ///  images with these names are placed  in my assets
        @Binding var images : [String]
        @Binding var isHiddenPageIndicator : Bool
        @Binding var isWebImage : Bool
        @Binding var isIndicatorSeparated : Bool

        init( images:Binding<[String]>,isHiddenPageIndicator:Binding<Bool>,isWebImage:Binding<Bool>,isIndicatorSeparated:Binding<Bool>) {
            UIPageControl.appearance().currentPageIndicatorTintColor = UIColor( .mainOrange)
            UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGray
            UIPageControl.appearance().backgroundColor = .clear
            self._images = images
            self._isHiddenPageIndicator = isHiddenPageIndicator
            self._isWebImage = isWebImage
            self._isIndicatorSeparated = isIndicatorSeparated
            UIPageControl.appearance().isHidden =  self.isIndicatorSeparated ? true: self.isHiddenPageIndicator
            
        }
        var body: some View {
            
            ZStack{
                VStack{
                    TabView(selection : $selection){
                        
                        ForEach(0 ..< images.count, id: \.self){ i in
                           if isWebImage {
                               WebImage(url: URL(string: images[i])).resizable()
                                   .frame(maxWidth: .infinity )
                                   .ignoresSafeArea().clipShape(.rect(cornerRadius: 12, style: .continuous))
                           }else{
                               Image(  images[i] ).resizable()
                                   .frame(maxWidth: .infinity )
                                   .ignoresSafeArea()
                               //  .foregroundColor(Color(Asset.secondColor.color))
                           }
                        }
                        
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
                    // Custom page control
                    if isIndicatorSeparated {
                        
                        HStack(spacing: 3) {
                            ForEach(0 ..< images.count, id: \.self) { index in
                                Circle()
                                    .fill(selection == index ? Color.orange : Color.gray)
                                    .frame(width: selection == index ?10:7, height: selection == index ?10:7)
                            }
                        }
                    }
                            
                }
                    
                .onReceive(timer, perform: { _ in
                        
                    withAnimation{
                        selection = selection < images.count - 1 ? selection + 1 : 0
                    }
                })
            }.ignoresSafeArea()
        }
    }

//
//struct SliderView_Previews: PreviewProvider {
//    static var previews: some View {
//        @State var isHidden = false
//        @State var images = [ Asset.slider1.name,Asset.slider2.name,Asset.slider3.name]
//        SliderView(images: $images, isHiddenPageIndicator: $isHidden)
//    }
//}
