//
//  CameraView.swift
//  lgcy
//
//  Created by Himanshu Joshi on 17/06/24.
//

import SwiftUI
import PhotosUI

struct CameraView: View {
    @ObservedObject var viewModel: UploadPostViewModel
    @ObservedObject var galleryViewModel: GalleryViewModel
    var body: some View {
        VStack {
            accessCameraView(viewModel: viewModel, galleryViewModel: galleryViewModel)
        }
        .edgesIgnoringSafeArea(.all)
    }
}


struct accessCameraView: UIViewControllerRepresentable {
    
    @ObservedObject var viewModel: UploadPostViewModel
    @ObservedObject var galleryViewModel: GalleryViewModel
    @Environment(\.presentationMode) var isPresented
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(picker: self)
    }
}

class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var picker: accessCameraView
    
    init(picker: accessCameraView) {
        self.picker = picker
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        let resizedImage = selectedImage.resize(toWidth: 512)
        let createPostImageModel = CreatePostImageModel(image: resizedImage, video: nil, type: 0)
        self.picker.galleryViewModel.selectedImages = [createPostImageModel]
        self.picker.galleryViewModel.currentSelected = createPostImageModel
        self.picker.viewModel.selectedImages = [ImageModel(id: "\(createPostImageModel.id)", image: resizedImage, fileData: resizedImage.pngData() ?? Data())]
        self.picker.viewModel.selectedImageFromCamera = true
        
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: selectedImage)
                }) { success, error in
                    if let error = error {
                        print("Error saving image to camera roll: \(error.localizedDescription)")
                    }
                }
            } else {
                print("Permission to save photos denied")
            }
        }
        self.picker.isPresented.wrappedValue.dismiss()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.picker.isPresented.wrappedValue.dismiss()
    }
}
