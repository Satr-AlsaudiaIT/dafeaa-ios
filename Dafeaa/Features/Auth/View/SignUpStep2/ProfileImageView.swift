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
    @Binding var imageURL: String?
    @State var isShowFromEdit: Bool
    @State var height: CGFloat = 85
    @State var editHeight: CGFloat = 20
    @State private var showFilePicker: Bool = false
    @State private var showFileTypeSelection: Bool = false
    @State private var pickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var isEdited: Bool = false
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack(alignment: .center) {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: height, height: height)

                if let selectedImage = selectedImage {
                    // If the user has selected an image, show it
                    Image(uiImage: selectedImage)
                        .resizable()
                        .frame(width: height, height: height)
                        .scaledToFill()
                        .clipShape(Circle())
                        .onAppear{
                            isEdited = true
                        }
                    
                } else if let imageURL = imageURL, isShowFromEdit {
                    // If editing from a URL, show the image from the URL
                    WebImage(url: URL(string: imageURL))
                        .resizable()
                        .frame(width: height, height: height)
                        .scaledToFill()
                        .clipShape(Circle())
                        .onAppear{
                            isEdited = true
                        }
                } else {
                    // Show the default "edit" icon when no image is available
                    Image(systemName: "person.fill")
                        .resizable()
                        .frame(width: height * 0.7, height: height * 0.7)
                        .scaledToFit()
                        .clipShape(Circle())
                        .foregroundColor(.gray)
                }
            }
            
            // Edit icon that allows to change the image
            Circle()
                .fill(Color.white)
                .frame(width: editHeight, height: editHeight)
                .overlay(
                    Image(isEdited ? .edit : .camera)
                        .foregroundColor(.primary)
                        .shadow(color:.grayFAFAFA,radius: 5)
                )
                .onTapGesture {
                    showFileTypeSelection = true
                }
        }
        .actionSheet(isPresented: $showFileTypeSelection) {
            ActionSheet(title: Text("chooseUploadImage".localized()), buttons: [
                .default(Text("PhotoLibrary".localized())) {
                    pickerSourceType = .photoLibrary
                    showFilePicker = true
                },
                .default(Text("cameraUpload".localized())) {
                    pickerSourceType = .camera
                    showFilePicker = true
                },
                .cancel()
            ])
        }
        .sheet(isPresented: $showFilePicker) {
            ImagePickerView(selectedImage: $selectedImage, sourceType: pickerSourceType)
        }
    }
}

