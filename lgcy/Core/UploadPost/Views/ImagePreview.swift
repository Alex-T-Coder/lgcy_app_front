//
//  ImagePreview.swift
//  lgcy
//
//  Created by Evan Boymel on 6/11/24.
//

import SwiftUI

struct ImagePreview: View {
    @EnvironmentObject private var galleryViewModel: GalleryViewModel
    var imageModel: CreatePostImageModel
    let toggleSelection: (CreatePostImageModel) -> Void
    
    var body: some View {
        if let image = imageModel.image {
            ZStack(alignment: .topTrailing) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width / 4, height: UIScreen.main.bounds.width / 4)
                    .clipShape(Rectangle())
                    .opacity(galleryViewModel.selectedImageIDs.contains(imageModel.id) ? 0.8 : 1.0)
                    .onTapGesture {
                        toggleSelection(imageModel)
                    }.zIndex(1)
                if let index = galleryViewModel.selectedImageIDs.firstIndex(of: imageModel.id) {
                    if galleryViewModel.photosLimit == 10 {
                        NumberBadge(number: index + 1)
                            .padding(4)
                            .zIndex(2)
                    }
                }
                if let duration = imageModel.videoLength {
                    Text(formatTime(time: duration))
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding([.bottom, .trailing], 6)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        .zIndex(2)
                }
            }
        }
    }
    
    private func formatTime(time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
