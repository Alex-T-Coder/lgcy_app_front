import SwiftUI
import Photos

struct PopupView: View {
    @Binding var showPopover: Bool
    @EnvironmentObject var galleryViewModel: GalleryViewModel
    @EnvironmentObject var viewModel: UploadPostViewModel
    @State var moveToNextView: Bool = false
    @State var showAlertForNoImageSelected: Bool = false
    @State private var player: AVPlayer?
    @State private var modifiedImage: UIImage? = nil
    let onClose: () -> Void
    var body: some View {
            VStack {
                HStack {
                    Button(action: {
                        onClose()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                    }
                    Spacer()
                    Text("New Post")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        Task {
                            if self.galleryViewModel.selectedImages.count > 0 {
                                var imageModels: [ImageModel] = []
                                for createPostImageModel in galleryViewModel.selectedImages {
                                    let data: Data
                                    var isVideo: Bool = false
                                    if createPostImageModel.type == 1 {
                                        isVideo = true
                                        do {
                                            data = try await createPostImageModel.convertVideoToData()
                                        } catch {
                                            data = Data()
                                        }
                                    } else {
                                        data = createPostImageModel.image?.pngData() ?? Data()
                                    }
                                    let imageModel = ImageModel(id: "\(createPostImageModel.id)", image: createPostImageModel.image, memeType: isVideo ? "video/mp4": "image/jpeg", fileData: data)
                                    imageModels.append(imageModel)
                                }
                                self.viewModel.selectedImages = imageModels
                                if let modifiedImage = modifiedImage {
                                    print(modifiedImage)
                                    let count = galleryViewModel.selectedImages.count
                                    galleryViewModel.selectedImages[count - 1].image = modifiedImage
                                }
                                viewModel.moveToNextAvailable = true
                                player?.pause()
                            } else {
                                showAlertForNoImageSelected = true	
                            }
                        }
                    }, label: {
                        Text("Next")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    })
                    .fullScreenCover(isPresented: $viewModel.moveToNextAvailable, content: {
                        NewPostStyleView(viewModel: viewModel, galleryViewModel: galleryViewModel)
                    })
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
                .background(.black)
                .zIndex(/*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
                if galleryViewModel.currentSelected?.type == 0 {
                    ZoomableView(modifyImage: { modifiedImage in
                        self.modifiedImage = modifiedImage
                    })
                } else {
                    if let videoAsset = galleryViewModel.currentSelected?.video {
                        VideoPlayerView(asset: videoAsset, player: $player)
                    }
                }
            }
            .alert("Please select at least one image to continue.", isPresented: $showAlertForNoImageSelected, actions: {
                Button("OK", role: .cancel) { }
            })
            .frame(width: UIScreen.main.bounds.width, height: 450)
    }
}

struct PopupView_preview: PreviewProvider {
    static var previews: some View {
        PopupViewWrapper()
    }
}

struct PopupViewWrapper: View {
    @StateObject private var galleryViewModel: GalleryViewModel = GalleryViewModel()
    @State private var showPopover: Bool = true;
    var body: some View {
        PopupView(showPopover: $showPopover, onClose: {}).environmentObject(galleryViewModel)
    }
}
