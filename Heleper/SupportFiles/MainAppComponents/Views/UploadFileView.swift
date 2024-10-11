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
    @State var isShowFromEdit: Bool
    @State private var showFilePicker: Bool = false
    @State private var showFileTypeSelection: Bool = false
    @State private var pickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State var width : CGFloat = UIScreen.main.bounds.width - 40
    @State var height: CGFloat = 127
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(.mainOrange).opacity(0.1))
                .cornerRadius(10)
                .frame(width: width,height: height)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
                        .foregroundColor(Color(.lightGray))
                )
                .onTapGesture {
                    showFilePicker = true
                }
            
            VStack(spacing: 10) {
                if isShowFromEdit != true {
//                    if selectedFile != URL(fileURLWithPath: "") && selectedFile != nil {
//                        if let fileURL = selectedFile {
//                            
//                            if fileURL.pathExtension.lowercased() == "pdf" {
//                                // Show PDF preview
//                                
//                                if let pdfData = try? Data(contentsOf: fileURL) {
//                                    ZStack {
//                                        PDFKitView(data: pdfData)
//                                            .cornerRadius(10)
//                                        VStack {
//                                            HStack{
//                                                Spacer()
//                                                Button {
//                                                    selectedFile = URL(fileURLWithPath: "")
//                                                    selectedImage = UIImage()
//
//                                                } label: {
//                                                    Image.init(uiImage: Asset.multiplyDelete.image)
//                                                        .resizable()
//                                                        .foregroundColor(.black)
//                                                        .frame(width: 35,height: 35)
//                                                        .padding(.trailing,5)
//                                                        .padding(.top,0)
//                                                }
//                                            }
//                                            Spacer()
//                                        }
//                                    }
//                                    
//                                }
//                                else {
//                                    Text("PDF Preview not available".localized())
//                                }
//                            }
//                        }
//                    }
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
                                    Spacer()
                                }
                            }
                        }
                    }
                    else {
                        //MARK:- ToDo uplaod image
                        Image.init("uiImage: Asset.uploadFileIcon.image")
                            .resizable()
                            .frame(width: 28,height: 28)
                        Text(title ?? "")
                            .font(.custom(AppFonts.shared.name(AppFontsTypes.light), size: 12))
                            .foregroundColor(Color(.gray888888))
                        Text("Upload it in format \n PNG, JPG, JPEG".localized())
                            .multilineTextAlignment(.center)
                            .font(.custom(AppFonts.shared.name(AppFontsTypes.extraLight), size: 11))
                            .foregroundColor(Color(.lightGray))
                            .padding(.top,-10)
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
                                Spacer()
                            }

                        }
                    }
                }
            }
            .frame(height: 100)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                .frame(height: UIScreen.main.bounds.height)
        }
        
    }
}

