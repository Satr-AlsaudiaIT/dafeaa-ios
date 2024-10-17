//
//  GuardProfileImageView.swift
//  Dafeaa
//
//  Created by AMNY on 13/10/2024.
//


import SwiftUI
import SDWebImageSwiftUI

struct ProfileImageView: View {
    @Binding var selectedImage: UIImage?
    @State var title: String?
    @State var imageURL: String?
    @State var isShowFromEdit: Bool
    @State var height: CGFloat = 85
    @State var editHeight: CGFloat = 20
    @State private var showFilePicker: Bool = false
    @State private var showFileTypeSelection: Bool = false
    @State private var pickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack(alignment: .center) {
                Circle()
                    .fill(.grayF6F6F6)
                    .frame(width: height, height: height)
                   
                
                if isShowFromEdit != true {
                    if selectedImage != UIImage() && selectedImage != nil {
                       if let image = selectedImage {
                           ZStack {
                               Image(uiImage: image)
                                   .resizable()
                                   .frame(width: height, height: height)
                                   .scaledToFit()
                                   .clipShape(Circle())
                                   .cornerRadius(10)
                           }
                       } else {
                           Image(.camera)
                               .resizable()
                               .frame(width: 28,height: 28)
                       }
                   }
                } else {
                    if let fileImage = imageURL {
                        ZStack {
                            WebImage(url: URL(string: fileImage))
                                .resizable()
                                .frame(width: height, height: height)
                                .scaledToFit()
                                .cornerRadius(10)
                        }
                    }
                }
            }
            
            Circle()
                .fill(Color.white)
                .frame(width: editHeight, height: editHeight)
                .overlay(alignment: .center) {
                    Image(.camera)
                        .renderingMode(.template)
                        .foregroundColor(Color.primary)
                }
                .onTapGesture {
                    showFileTypeSelection = true
                }
        }
        .actionSheet(isPresented: $showFileTypeSelection) {
            ActionSheet(title: Text("Choose the file type you want to upload".localized()), buttons: [
                .default(Text("Image".localized())) {
                    pickerSourceType = .photoLibrary
                    showFilePicker = true
                },
                .default(Text("Camera".localized())) {
                    pickerSourceType = .camera
                    showFilePicker = true
                },
                .cancel()
            ])
        }
        .sheet(isPresented: $showFilePicker){
            
                ImagePickerView(selectedImage: $selectedImage,  sourceType: pickerSourceType)
            
        }
    }
}

//#Preview {
//    GuardProfileImageView(selectedImage: .constant(nil), isShowFromEdit: false)
//}

