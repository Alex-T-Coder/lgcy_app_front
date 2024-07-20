import SwiftUI
import Photos

struct ImageCollectionView: View {
    @EnvironmentObject private var galleryViewModel: GalleryViewModel
    @EnvironmentObject private var viewModel: UploadPostViewModel
    let action: (Bool) -> Void

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 3) {
            ForEach(galleryViewModel.images.filter{$0.videoLength ?? 0 < 45}) { imageModel in
                ImagePreview(imageModel: imageModel, toggleSelection: {imageModel in
                    if imageModel.type == 0 {
                        galleryViewModel.requestFullSizeImage(for: imageModel.video ?? PHAsset()) { fullSizeImage in
                            guard let fullSizeImage = fullSizeImage else { return }
                            let updatedImageModel = CreatePostImageModel(id: imageModel.id, image: fullSizeImage, video: nil, type: 0)
                            self.toggleSelection(for: updatedImageModel)
                        }
                    } else {
                        self.toggleSelection(for: imageModel)
                    }
                })
                .onAppear {
                    if imageModel == galleryViewModel.images.last {
                        galleryViewModel.loadMorePhotos()
                        galleryViewModel.loadMoreVideos()
                    }
                }
            }
            .padding(.horizontal, 2)
        }
        .background(Color.black)
        
    }

    private func toggleSelection(for imageModel: CreatePostImageModel) {
        if galleryViewModel.selectedImageIDs.contains(imageModel.id) {
            if let imageIndex = galleryViewModel.selectedImageIDs.firstIndex(of: imageModel.id) {
                
                galleryViewModel.selectedImageIDs.remove(at: imageIndex)
                galleryViewModel.selectedImages.remove(at: imageIndex)
            }
            let imageArray = Array(galleryViewModel.selectedImageIDs)
            if !imageArray.isEmpty {
                if let foundImage = galleryViewModel.images.first(where: {
                    $0.id == imageArray[imageArray.count - 1]
                }) {
                    galleryViewModel.currentSelected = foundImage;
                    action(true)
                } else {
                    galleryViewModel.currentSelected = nil;
                    action(false)
                }
            }
        } else {
            if galleryViewModel.selectedImageIDs.count == galleryViewModel.photosLimit {
                if galleryViewModel.photosLimit == 1 {
                    galleryViewModel.selectedImageIDs.removeAll()
                    galleryViewModel.selectedImageIDs.insert(imageModel.id, at: 0)
                    galleryViewModel.selectedImages.removeAll()
                    galleryViewModel.selectedImages.insert(imageModel, at: 0)
                    galleryViewModel.currentSelected = imageModel
                }
                
                return
            }
            galleryViewModel.selectedImageIDs.insert(imageModel.id, at: galleryViewModel.selectedImageIDs.count)
            galleryViewModel.selectedImages.insert(imageModel, at: galleryViewModel.selectedImageIDs.count - 1)
            galleryViewModel.currentSelected = imageModel
            action(true)
        }
    }
}

struct ImageCollectionViewWrapper: View {
    @StateObject private var galleryViewModel: GalleryViewModel = GalleryViewModel()
    var body: some View {
        ImageCollectionView(action:{_ in }).environmentObject(galleryViewModel)
    }
}

#Preview {
    ImageCollectionViewWrapper()
}
