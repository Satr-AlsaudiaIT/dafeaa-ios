//
//  UploadFileView.swift
//  Proffer
//
//  Created by M.Magdy on 27/02/2024.
//  Copyright © 2024 Nura. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct UploadFileView: View {
    @Binding var selectedImage: UIImage?
    @Binding var imageURL: String?
    @State var title: String?
    @State var isShowFromEdit: Bool = false
    @State private var showFilePicker: Bool = false
    @State private var showFileTypeSelection: Bool = false
    @State private var pickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State var width : CGFloat = UIScreen.main.bounds.width - 40
    @State var height: CGFloat = 127
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(.grayF6F6F6))
                .cornerRadius(10)
                .frame(width: width,height: height)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 10)
//                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
//                        .foregroundColor(Color(.lightGray))
//                )
                .onTapGesture {
                    showFilePicker = true
                }
            
            VStack(spacing: 10) {
                if isShowFromEdit != true {
                     if selectedImage != UIImage() && selectedImage != nil {
                        if let image = selectedImage {
                            ZStack {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: width,height: height)
                                    .aspectRatio(2, contentMode: .fit)
                                    .cornerRadius(10)
                                VStack {
                                    HStack{
                                        Spacer()
                                        Button {
                                            selectedImage = UIImage()
//                                            selectedFile = URL(fileURLWithPath: "")

                                        } label: {
                                            //MARK:- toDo upload image
                                            Image( "Asset.multiplyDelete.image")
                                                .resizable()
                                                .foregroundColor(.black)
                                                .frame(width: 20,height: 20)
                                                .padding(.trailing,5)
                                                .padding(.top,0)
                                        }
                                    }
//                                    Spacer()
                                }
                            }
                        }
                    }
                    else {
                        //MARK:- ToDo uplaod image
                        Image(.uplaodFile)
                            .resizable()
                            .frame(width: 28,height: 28)
                        Text("uploadFileHere".localized())
                            .multilineTextAlignment(.center)
                            .font(.custom(AppFonts.shared.name(AppFontsTypes.plain), size: 15))
                            .foregroundColor(Color(.grayB5B5B5))
//                            .padding(.top,-10)
                    }
                    }
                else  {
                    if let fileImage = imageURL {
                        ZStack {
     
                            WebImage(url: URL(string: fileImage) )
                                .resizable()
                                .frame(width: width,height: height)
                                .aspectRatio(2, contentMode: .fit)
                                .cornerRadius(10)
//                            }
                            VStack {
                                HStack{
                                    Spacer()
                                    Button {
                                        isShowFromEdit = false
                                        selectedImage = UIImage()
                                    } label: {
                                        //MARK: - ToDo multiplyDelete image
                                        Image( "Asset.multiplyDelete.image")
                                            .resizable()
                                            .foregroundColor(.black)
                                            .frame(width: 35,height: 35)
                                            .padding(.trailing,5)
                                            .padding(.top,0)
                                    }
                                }
//                                Spacer()
                            }

                        }
                    }
                }
            }
            .frame(height: 100)
        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .actionSheet(isPresented: $showFileTypeSelection) {
//            ActionSheet(title: Text("Select file type".localized()), message: Text("Choose the file type you want to upload".localized()), buttons: [
//                .default(Text("Image".localized()), action: {
//                    pickerSourceType = .photoLibrary
//                    showFilePicker = true
//                }),
//                .default(Text("PDF"), action: {
//                    pickerSourceType = .camera
//                    showFilePicker = true
//                }),
//                .cancel()
//            ])
//        }
        .sheet(isPresented: $showFilePicker) {
            ImagePickerView(selectedImage: $selectedImage, sourceType: pickerSourceType)
                //.frame(height: UIScreen.main.bounds.height)
        }
        
    }
}

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var selectedImage: UIImage
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {

        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator

        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
            }

            parent.presentationMode.wrappedValue.dismiss()
        }

    }
}

 

