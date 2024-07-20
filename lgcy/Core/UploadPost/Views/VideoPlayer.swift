import SwiftUI
import Photos
import AVKit

struct VideoPlayerView: View {
    var asset: PHAsset

    @Binding var player: AVPlayer?
    @State private var playerObserver: Any?
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var isScaledToHeight: Bool = true
    @State private var imageWidth: CGFloat = 0.0
    @State private var imageHeight: CGFloat = 0.0

    func getVideoURL(from asset: PHAsset, completion: @escaping (URL?) -> Void) {
        let options = PHVideoRequestOptions()
        options.version = .original
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { (avAsset, _, _) in
            if let urlAsset = avAsset as? AVURLAsset {
                completion(urlAsset.url)
            } else {
                completion(nil)
            }
        }
    }

    func createPlayer(from url: URL) -> AVPlayer {
        return AVPlayer(url: url)
    }

    var body: some View {
        VStack {
            if let player = player {
                VideoPlayer(player: player)
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
                                }
                            }
                            .simultaneously(with: DragGesture()
                                .onChanged { value in
                                    self.offset = CGSize(width: self.lastOffset.width + value.translation.width, height: self.lastOffset.height + value.translation.height)
                                }
                                .onEnded { value in
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
                        }
                    )
                    .onAppear {
                        player.play()
                        addPlaybackObserver()
                    }
                    .onDisappear {
                        removePlaybackObserver()
                        player.pause()
                    }.overlay{
                        
                        VStack {
                            Spacer()
                            HStack {
                                Button(action: {
                                    withAnimation {
                                        // Toggle between scaling to height and scaling to width
                                        toggleScale(imageWidth: imageWidth, imageHeight: imageHeight)
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
                    }
            } else {
                Text("Loading video...")
                    .onAppear {
                        getVideoURL(from: asset) { url in
                            if let url = url {
                                player = createPlayer(from: url)
                                player?.play()
                                addPlaybackObserver()
                            }
                        }
                    }
            }
        }
    }

    func addPlaybackObserver() {
        guard let player = player else { return }
        
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        playerObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak player] time in
            if time.seconds >= 45 {
                player?.pause()
                player?.seek(to: .zero)
            }
        }
    }

    func removePlaybackObserver() {
        if let playerObserver = playerObserver, let player = player {
            player.removeTimeObserver(playerObserver)
            self.playerObserver = nil
        }
    }
    
    private func toggleScale(imageWidth: CGFloat, imageHeight: CGFloat) {
        let screenWidth = UIScreen.main.bounds.width

        if isScaledToHeight {
            self.scale = screenWidth / imageWidth
        } else {
            self.scale = 400 / imageHeight
        }

        self.lastScale = self.scale
        self.offset = .zero
        self.lastOffset = .zero
        self.isScaledToHeight.toggle()
    }
}

struct VideoPlayerWrapper: View {
    @State private var player: AVPlayer? = nil
    var asset: PHAsset

    var body: some View {
        VideoPlayerView(asset: asset, player: $player)
    }
}

// You can add a preview for testing purposes
struct VideoPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayerWrapper(asset: PHAsset())
    }
}
