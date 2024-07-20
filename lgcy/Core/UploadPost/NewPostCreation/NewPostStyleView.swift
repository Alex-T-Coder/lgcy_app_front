//
//  NewPostStyleView.swift
//  galleryDemo


import SwiftUI
import Photos

struct NewPostStyleView: View {
    var arrGrideItem = Array(repeating: GridItem(.adaptive(minimum: UIScreen.main.bounds.width / 20)), count: 1)
    var arrEnumForStyle: [EnumForStyle] = [.normal, .clarendon, .gingham, .moon, .lark, .reyes]
    @State var selectedStyle: EnumForStyle = .normal
    @State var isShowingPicker = false
    @State var movedToNext = false
    @ObservedObject var viewModel: UploadPostViewModel
    @ObservedObject var galleryViewModel: GalleryViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showImageIndex: Int = -1
    @State private var keys: [String] = ["Paris", "Los Angeles", "Oslo", "Melbourne", "Tokyo", "New York"]
    private let context = CIContext()

    func generateFilteredImages(to image: UIImage) -> [UIImage] {
        let context = CIContext()
        let ciImage = CIImage(image: image)
        
        let filters: [CIFilter] = [
            CIFilter(name: "CIPhotoEffectMono")!,
            CIFilter(name: "CIPhotoEffectProcess")!,
            CIFilter(name: "CIPhotoEffectTransfer")!,
            CIFilter(name: "CIPhotoEffectInstant")!,
            CIFilter(name: "CIPhotoEffectNoir")!,
            CIFilter(name: "CIPhotoEffectFade")!
        ]
        
        var filteredImages: [UIImage] = []
        
        for filter in filters {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            if let outputImage = filter.outputImage,
               let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                let filteredUIImage = UIImage(cgImage: cgImage)
                filteredImages.append(filteredUIImage)
            }
        }
        
        return filteredImages
    }
    init(viewModel: UploadPostViewModel, galleryViewModel: GalleryViewModel) {
        self.viewModel = viewModel
        self.galleryViewModel = galleryViewModel
    }
    
    func applyFilter(to images: [CreatePostImageModel], filterIndex: Int) -> [CreatePostImageModel] {
        guard filterIndex != -1 else { return images }
        return images.map { imageModel in
            let filteredImages = generateFilteredImages(to: imageModel.image ?? UIImage())
            return CreatePostImageModel(id: imageModel.id, image: filteredImages[filterIndex], video: imageModel.video, videoLength: imageModel.videoLength, type: imageModel.type)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack{
                HStack(content: {
                    Button(action: {
//                        isShowingPicker.toggle()
                        dismiss()
                    },label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                    })
                    Spacer()
                })
                .padding(.horizontal,15)
                .padding(.top)
                
                
                GeometryReader { proxy in
                    VStack {
                        if let originalImage = galleryViewModel.selectedImages.last?.image {
                            let lastImageFilteredImages = generateFilteredImages(to: originalImage)
                            let showImage = showImageIndex == -1 ? originalImage : lastImageFilteredImages[showImageIndex]
                            Image(uiImage: showImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: UIScreen.main.bounds.width - 30)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    VStack {
                                        Text("Normal").foregroundColor(.white)
                                        Image(uiImage: originalImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 150)
                                            .onTapGesture {
                                                showImageIndex = -1
                                                self.viewModel.selectedImages = galleryViewModel.selectedImages.map({ createPostImageModel in
                                                    return ImageModel(id: "\(createPostImageModel.id)", image: createPostImageModel.image, fileData: createPostImageModel.image?.pngData() ?? Data())
                                                })
                                            }
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                    ForEach(Array(lastImageFilteredImages.enumerated()), id: \.element) {index, filteredImage in
                                        VStack {
                                            Text(keys[index]).foregroundColor(.white)
                                            Image(uiImage: filteredImage)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 150)
                                                .onTapGesture {
                                                    showImageIndex = index
                                                    
                                                    let testArray = galleryViewModel.selectedImages
                                                    let newArray = testArray.map { imageModel in
                                                        let filteredImages = generateFilteredImages(to: imageModel.image ?? UIImage())
                                                        return CreatePostImageModel(id: imageModel.id, image: filteredImages[showImageIndex], video: imageModel.video, videoLength: imageModel.videoLength, type: imageModel.type)
                                                    }
                                                    self.viewModel.selectedImages = newArray.map({ createPostImageModel in
                                                        return ImageModel(id: "\(createPostImageModel.id)", image: createPostImageModel.image, fileData: createPostImageModel.image?.pngData() ?? Data())
                                                    })
                                                }
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                        }
                                    }
                                }
                            }.padding()
                        }
                    }
                    .padding(15)
                    .navigationBarHidden(true)
                    .actionSheet(isPresented: $isShowingPicker) { () -> ActionSheet in
                        ActionSheet(title: Text("If you go back now, your edits will be discarded."), buttons: [ActionSheet.Button.default(Text("Discard"), action: {
                            viewModel.selectedImages = []
                            galleryViewModel.selectedImages = []
                            galleryViewModel.selectedImageIDs = []
                            dismiss()
                        }), ActionSheet.Button.default(Text("Save Draft"), action: {

                        }), ActionSheet.Button.cancel()])
                    }

                }
                HStack {
                    Spacer()
                    NavigationLink(destination: {
                        UploadPostView(viewModel: viewModel)
                    }, label: {
                        HStack {
                            Text("Next")
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                            Image(systemName: "arrow.right")
                                .foregroundColor(.black)
                                .fontWeight(.semibold)

                        }
                        .padding(8)
                        .background(Color.white)
                        .cornerRadius(20)
                    }).isDetailLink(false)
                        .padding([.bottom, .trailing], 10)
                }
            }
            .background(.black)
        } .navigationBarHidden(true)
    }
}

//#Preview {
//    NewPostStyleView()
//}
