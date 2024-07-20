//
//  NewPostView.swift
//  lgcy
//
//  Created by Adnan Majeed on 22/02/2024.
//

import SwiftUI
import Photos
import AVKit

struct NewPostView: View {
    @EnvironmentObject var tabStateManager: TabStateManager
    var arrGrideItem = Array(repeating: GridItem(.adaptive(minimum: UIScreen.main.bounds.width / 4)), count: 4)
    @State var isShowDurationAlert : Bool = false
    @Binding var tabIndex: Int
    @State var avPlayer = AVPlayer()
    @StateObject var viewModel:UploadPostViewModel
    @State var showCameraView: Bool = false
    @State private var showPopover = true
    @State private var popoverPosition: CGPoint = .zero
    @StateObject private var galleryViewModel: GalleryViewModel = GalleryViewModel()
    var body: some View {
        NavigationView(content: {
            VStack(spacing: 16) {
                PopupView(showPopover: $showPopover, onClose: {
                    tabStateManager.selectedTab = 0
                    tabStateManager.selectedTab = tabStateManager.prevSelectedTab
                })
                
                HStack{
                    Text("Recents")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.leading, 12)
                    
                    Image(systemName: "square.on.square")
                        .resizable()
                        .frame(width: 21, height: 21)
                        .foregroundColor(.white)
                        .padding(4)
                        .background(
                                galleryViewModel.photosLimit != 1 ?
                                    Circle().fill(Color.blue) : nil
                        )
                        .overlay(
                            galleryViewModel.photosLimit != 1 ?
                                Circle().stroke(Color.blue, lineWidth: 1) : nil
                        )
                        .onTapGesture {
                            galleryViewModel.photosLimit = 11 - galleryViewModel.photosLimit
                            if galleryViewModel.photosLimit == 1 {
                                if let id = galleryViewModel.selectedImageIDs.first {
                                    galleryViewModel.selectedImageIDs.removeAll()
                                    galleryViewModel.selectedImageIDs.append(id)
                                    
                                }
                                if let image = galleryViewModel.selectedImages.first {
                                    galleryViewModel.selectedImages.removeAll()
                                    galleryViewModel.selectedImages.append(image)
                                    galleryViewModel.currentSelected = image
                                }
                            }
                    }
                    
                    
                    Image(systemName: "camera")
                        .resizable()
                        .frame(width: 23, height: 19)
                        .foregroundColor(.white)
                        .onTapGesture {
                            showCameraView = true
                        }
                    .padding(.trailing, 12)
                }
                ScrollView {
                    ImageCollectionView(action: { _ in })
                }
            }
            .background(Color.black)
        })
        .environmentObject(galleryViewModel)
        .environmentObject(viewModel)
        .onChange(of: viewModel.tabIndex, {
            tabIndex = viewModel.tabIndex
        }).onAppear {
            viewModel.validationText = ""
        }
        .onChange(of: viewModel.selectedImages, {
            if viewModel.selectedImages.count > 0 && viewModel.selectedImageFromCamera {
                viewModel.moveToNextAvailable = true
            }
        })
        .onChange(of: viewModel.moveToNextAvailable, {
            if !viewModel.moveToNextAvailable {
                tabIndex = 0
            }
        })
        .fullScreenCover(isPresented: $showCameraView, content: {
            CameraView(viewModel: viewModel, galleryViewModel: galleryViewModel)
        })
    }
}

#Preview {
    NewPostView(tabIndex: Binding<Int>.constant(0), viewModel: UploadPostViewModel(feedsViewModel: FeedViewModel()))
}
