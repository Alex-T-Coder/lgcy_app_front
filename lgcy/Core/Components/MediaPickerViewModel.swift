import SwiftUI
import PhotosUI
import AVKit

struct MediaPicker: UIViewControllerRepresentable {
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: MediaPicker

        init(parent: MediaPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true, completion: nil)
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                    DispatchQueue.main.async {
                        self?.parent.selectedImage = image as? UIImage
                    }
                }
            }
            
            if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] (url, error) in
                    DispatchQueue.main.async {
                        if let url = url {
                            self?.parent.selectedVideoURL = url
                        }
                    }
                }
            }
        }
    }

    @Binding var selectedImage: UIImage?
    @Binding var selectedVideoURL: URL?
    @Environment(\.presentationMode) var presentationMode

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.filter = .any(of: [.images, .videos])
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
}
