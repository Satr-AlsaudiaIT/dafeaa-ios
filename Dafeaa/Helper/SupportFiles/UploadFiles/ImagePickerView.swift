//
//  ImagePickerView.swift
//
//  Created by M.Magdy on 06/09/2023.
//  Copyright © 2023 Nura. All rights reserved.
//

import SwiftUI
import MobileCoreServices
import UniformTypeIdentifiers
import PhotosUI
import AVFoundation

// MARK: - Single Image Picker
struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var sourceType: UIImagePickerController.SourceType
    @Binding var showPermissionAlert: Bool
    @Binding var permissionAlertMessage: String
    
    init(selectedImage: Binding<UIImage?>,
         sourceType: UIImagePickerController.SourceType,
         showPermissionAlert: Binding<Bool> = .constant(false),
         permissionAlertMessage: Binding<String> = .constant("")) {
        self._selectedImage = selectedImage
        self.sourceType = sourceType
        self._showPermissionAlert = showPermissionAlert
        self._permissionAlertMessage = permissionAlertMessage
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerView>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        imagePicker.modalPresentationStyle = .overFullScreen
        checkPermissions()
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePickerView>) {
        if uiViewController.sourceType != sourceType {
            uiViewController.sourceType = sourceType
        }
    }

    func checkPermissions() {
        switch sourceType {
        case .camera:
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            switch status {
            case .authorized:
                break
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    DispatchQueue.main.async {
                        if !granted {
                            self.showPermissionAlert = true
                            self.permissionAlertMessage = "Camera access is required to take photos. Please enable it in Settings."
                        }
                    }
                }
            case .denied, .restricted:
                DispatchQueue.main.async {
                    self.showPermissionAlert = true
                    self.permissionAlertMessage = "Camera access is required to take photos. Please enable it in Settings."
                }
            @unknown default:
                break
            }
            
        case .photoLibrary, .savedPhotosAlbum:
            let status = PHPhotoLibrary.authorizationStatus()
            switch status {
            case .authorized, .limited:
                break
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { newStatus in
                    DispatchQueue.main.async {
                        if newStatus == .denied || newStatus == .restricted {
                            self.showPermissionAlert = true
                            self.permissionAlertMessage = "Photo library access is required to select photos. Please enable it in Settings."
                        }
                    }
                }
            case .denied, .restricted:
                DispatchQueue.main.async {
                    self.showPermissionAlert = true
                    self.permissionAlertMessage = "Photo library access is required to select photos. Please enable it in Settings."
                }
            @unknown default:
                break
            }
            
        default:
            break
        }
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePickerView

        init(_ imagePicker: ImagePickerView) {
            self.parent = imagePicker
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                parent.selectedImage = selectedImage
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - Multi-Image Picker
struct ImagePickerMultiSelection: UIViewControllerRepresentable {
    typealias UIViewControllerType = PHPickerViewController

    let sourceType: UIImagePickerController.SourceType
    let isMultiSelection: Bool
    @Binding var selectedImages: [UIImage]
    @State var selectionNumber: Int
    @Binding var showPermissionAlert: Bool
    @Binding var permissionAlertMessage: String
    
    init(sourceType: UIImagePickerController.SourceType = .photoLibrary,
         isMultiSelection: Bool,
         selectedImages: Binding<[UIImage]>,
         selectionNumber: Int = 10,
         showPermissionAlert: Binding<Bool> = .constant(false),
         permissionAlertMessage: Binding<String> = .constant("")) {
        self.sourceType = sourceType
        self.isMultiSelection = isMultiSelection
        self._selectedImages = selectedImages
        self.selectionNumber = selectionNumber
        self._showPermissionAlert = showPermissionAlert
        self._permissionAlertMessage = permissionAlertMessage
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        checkPermissions()
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = isMultiSelection ? selectionNumber : 1
        configuration.filter = .images

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func checkPermissions() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .limited:
            break
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .denied || newStatus == .restricted {
                        self.showPermissionAlert = true
                        self.permissionAlertMessage = "Photo library access is required to select photos. Please enable it in Settings."
                    }
                }
            }
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.showPermissionAlert = true
                self.permissionAlertMessage = "Photo library access is required to select photos. Please enable it in Settings."
            }
        @unknown default:
            fatalError("Unknown status for photo library access")
        }
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePickerMultiSelection

        init(_ parent: ImagePickerMultiSelection) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard !results.isEmpty else {
                picker.dismiss(animated: true)
                return
            }
            
            let group = DispatchGroup()
            var selectedImages: [UIImage] = []
            
            for result in results {
                group.enter()
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                        defer { group.leave() }
                        if let image = image as? UIImage {
                            selectedImages.append(image)
                        } else if let error = error {
                            print("Error loading image: \(error.localizedDescription)")
                        }
                    }
                } else {
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self.parent.selectedImages = selectedImages
                picker.dismiss(animated: true)
            }
        }
    }
}

// MARK: - Permission Alert Helper
struct PermissionAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    
    func body(content: Content) -> some View {
        content
            .alert("Permission Required", isPresented: $isPresented) {
                Button("Cancel", role: .cancel) { }
                Button("Open Settings") {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
            } message: {
                Text(message)
            }
    }
}

extension View {
    func permissionAlert(isPresented: Binding<Bool>, message: String) -> some View {
        modifier(PermissionAlertModifier(isPresented: isPresented, message: message))
    }
}

// MARK: - Usage Example
/*
struct ContentView: View {
    @State private var selectedImage: UIImage?
    @State private var selectedImages: [UIImage] = []
    @State private var showImagePicker = false
    @State private var showMultiImagePicker = false
    @State private var showPermissionAlert = false
    @State private var permissionAlertMessage = ""
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        VStack {
            // Single image picker button
            Button("Select Image") {
                sourceType = .photoLibrary
                showImagePicker = true
            }
            
            // Camera button
            Button("Take Photo") {
                sourceType = .camera
                showImagePicker = true
            }
            
            // Multi-select button
            Button("Select Multiple Images") {
                showMultiImagePicker = true
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(
                selectedImage: $selectedImage,
                sourceType: sourceType,
                showPermissionAlert: $showPermissionAlert,
                permissionAlertMessage: $permissionAlertMessage
            )
        }
        .sheet(isPresented: $showMultiImagePicker) {
            ImagePickerMultiSelection(
                isMultiSelection: true,
                selectedImages: $selectedImages,
                showPermissionAlert: $showPermissionAlert,
                permissionAlertMessage: $permissionAlertMessage
            )
        }
        .permissionAlert(isPresented: $showPermissionAlert, message: permissionAlertMessage)
    }
}
*/
