import SwiftUI

struct ZoomableView: View {
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var lineCount: Int = 3
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var isScaledToHeight: Bool = true
    @State private var imageWidth: CGFloat = 0.0
    @State private var imageHeight: CGFloat = 0.0
    @EnvironmentObject var galleryViewModel: GalleryViewModel
    
    @State var modifyImage: ((UIImage) -> Void)? = nil

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                if let image = galleryViewModel.currentSelected, let showImage = image.image {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(uiImage: showImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .scaleEffect(scale)
                                .offset(offset)
                                .gesture(
                                    MagnificationGesture()
                                        .onChanged { value in
                                            self.scale = self.lastScale * value
                                        }
                                        .onEnded { value in
                                            self.scale = self.lastScale * value
                                            self.lastScale = self.scale
                                            
                                            // Reset to initial position if the scale is less than 1
                                            if self.scale < 1 {
                                                self.scale = 1
                                                self.lastScale = 1
                                                self.offset = .zero
                                                self.lastOffset = .zero
                                            } else {
                                                clampOffset(to: geometry.size)
                                                captureImage()
                                            }
                                        }
                                        .simultaneously(with: DragGesture()
                                            .onChanged { value in
                                                self.offset = CGSize(width: self.lastOffset.width + value.translation.width, height: self.lastOffset.height + value.translation.height)
                                            }
                                            .onEnded { value in
                                                clampOffset(to: geometry.size)
                                                captureImage()
                                                self.lastOffset = self.offset
                                            }
                                        )
                                )
                                .overlay(
                                    GeometryReader { imageGeometry in
                                       Color.clear.onAppear {
                                            self.imageWidth = imageGeometry.size.width
                                            self.imageHeight = imageGeometry.size.height
                                        }
                                        
                                        Path { path in
                                            for i in 1..<lineCount {
                                                let y = imageGeometry.size.height * CGFloat(i) / CGFloat(lineCount)
                                                path.move(to: CGPoint(x: 0, y: y))
                                                path.addLine(to: CGPoint(x: imageGeometry.size.width, y: y))
                                            }
                                            
                                            for i in 1..<lineCount {
                                                let x = imageGeometry.size.width * CGFloat(i) / CGFloat(lineCount)
                                                path.move(to: CGPoint(x: x, y: 0))
                                                path.addLine(to: CGPoint(x: x, y: imageGeometry.size.height))
                                            }
                                        }
                                        .stroke(Color.gray, lineWidth: 1)
                                        .scaleEffect(scale, anchor: .center)
                                        .offset(offset) // Apply the same offset to the grid lines
                                    }
                                )
                                .onChange(of: galleryViewModel.currentSelected) { _ in
                                    // Adjust the scale when the selected image changes
                                    withAnimation {
                                        resetScaleAndOffset()
                                    }
                                }
                            Spacer()
                        }
                        Spacer()
                    }
                } else {
                    Color.clear
                }
            }
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            withAnimation {
                                // Toggle between scaling to height and scaling to width
                                toggleScale()
                                captureImage()
                            }
                        }) {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                        .padding()
                        Spacer()
                    }
                }
            )
            .clipped()
        }
    }

    private func resetScaleAndOffset() {
        if (galleryViewModel.currentSelected?.image) != nil {
            self.scale = 1
            self.lastScale = self.scale
            self.offset = .zero
            self.lastOffset = .zero
        }
    }

    private func toggleScale() {
        let screenWidth = UIScreen.main.bounds.width

        if isScaledToHeight {
            self.scale = screenWidth / imageWidth
        } else {
            self.scale = 450 / imageHeight
        }

        self.lastScale = self.scale
        self.offset = .zero
        self.lastOffset = .zero
        self.isScaledToHeight.toggle()
    }
    
    private func clampOffset(to containerSize: CGSize) {
        let imageSize = CGSize(
            width: imageWidth * scale,
            height: imageHeight * scale
        )
        
        let horizontalOverflow = max(0, (imageSize.width - containerSize.width) / 2)
        let verticalOverflow = max(0, (imageSize.height - containerSize.height) / 2)
        
        let clampedX = min(max(offset.width, -horizontalOverflow), horizontalOverflow)
        let clampedY = min(max(offset.height, -verticalOverflow), verticalOverflow)
        
        offset = CGSize(width: clampedX, height: clampedY)
    }

    func captureImage() {
        guard let selectedImage = galleryViewModel.currentSelected?.image else {
            return
        }
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = CGFloat(450) // Adjust this as needed
        let imageViewWidth = imageWidth * scale
        let imageViewHeight = imageHeight * scale
        
        let visibleRect = CGRect(
            x: ((imageViewWidth - screenWidth) / 2 - offset.width) / scale,
            y: ((imageViewHeight - screenHeight) / 2 - offset.height) / scale,
            width: screenWidth * selectedImage.size.width / imageViewWidth,
            height: screenHeight * selectedImage.size.height / imageViewHeight
        )

        guard let cgImage = selectedImage.cgImage?.cropping(to: visibleRect) else {
            return
        }

        let croppedImage = UIImage(cgImage: cgImage, scale: selectedImage.scale, orientation: selectedImage.imageOrientation)
        
        self.modifyImage?(croppedImage)
    }

}

struct ZoomableViewWrapper: View {
    @StateObject private var galleryViewModel: GalleryViewModel = GalleryViewModel()
    var body: some View {
        ZoomableView().environmentObject(galleryViewModel)
    }
}

struct ZoomableView_preview: PreviewProvider {
    static var previews: some View {
        ZoomableViewWrapper()
    }
}
