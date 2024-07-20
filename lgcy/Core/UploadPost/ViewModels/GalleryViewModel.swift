//
//  GalleryViewModel.swift
//  lgcy
//
//  Created by Evan Boymel on 6/6/24.
//

import Photos
import SwiftUI
import AVFoundation

class GalleryViewModel: ObservableObject {
    @Published var images: [CreatePostImageModel] = []
    @Published var selectedImageIDs: [UUID] = []
    @Published var selectedImages: [CreatePostImageModel] = []
    @Published var currentSelected: CreatePostImageModel? = nil
    @Published var limit: Int = 10
    @Published var photosLimit: Int = 1
    
    private var photoFetchResult: PHFetchResult<PHAsset>?
    private var videoFetchResult: PHFetchResult<PHAsset>?
    private var photoFetchIndex = 0
    private var videoFetchIndex = 0
    init() {
        self.requestAuthorization()
    }
    
    func requestAuthorization() {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                self.fetchMedia()
            } else {
                print("Permission denied")
            }
        }
    }
    
    private func fetchMedia() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.photoFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            self.videoFetchResult = {
                let videoOptions = PHFetchOptions()
                videoOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
                videoOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                return PHAsset.fetchAssets(with: videoOptions)
            }()
            
            DispatchQueue.main.async {
                self.loadMorePhotos()
                self.loadMoreVideos()
            }
        }
    }
    
    func loadMorePhotos() {
        guard let fetchResult = self.photoFetchResult else { return }
        
        let endIndex = min(photoFetchIndex + limit, fetchResult.count)
        guard photoFetchIndex < endIndex else { return }
        
        let assets = fetchResult.objects(at: IndexSet(photoFetchIndex..<endIndex))
        photoFetchIndex = endIndex
        
        for asset in assets {
            self.requestImage(for: asset)
        }
    }
    
    func loadMoreVideos() {
        guard let fetchResult = self.videoFetchResult else { return }
        
        let endIndex = min(videoFetchIndex + limit, fetchResult.count)
        guard videoFetchIndex < endIndex else { return }
        
        let assets = fetchResult.objects(at: IndexSet(videoFetchIndex..<endIndex))
        videoFetchIndex = endIndex
        
        for asset in assets {
            self.generateThumbnail(asset: asset) { image in
                if let image = image {
                    DispatchQueue.main.async {
                        self.images.append(CreatePostImageModel(image: image, video: asset, videoLength: asset.duration, type: 1))
                    }
                }
            }
        }
    }
    
    private func requestImage(for asset: PHAsset) {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .current
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        
        manager.requestImage(for: asset, targetSize: CGSize(width: 240, height: 240), contentMode: .aspectFill, options: options) { image, _ in
            if let image = image {
                DispatchQueue.main.async {
                    let imageModel = CreatePostImageModel(image: image, video: asset, type: 0)
                    self.images.append(imageModel)
                    if self.currentSelected == nil {
                        self.currentSelected = imageModel
                        self.selectedImageIDs.insert(imageModel.id, at: 0)
                        self.selectedImages.insert(imageModel, at: 0)
                    }
                }
            }
        }
    }
    
    func requestFullSizeImage(for asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .current
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        
        let fullSize = CGSize(width: 1080, height: 1080)
        
        manager.requestImage(for: asset, targetSize: fullSize, contentMode: .aspectFill, options: options) { image, _ in
            completion(image)
        }
    }
    
    private func generateThumbnail(asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let imageManager = PHImageManager.default()
        let options = PHVideoRequestOptions()
        options.version = .current
        
        imageManager.requestAVAsset(forVideo: asset, options: options) { avAsset, _, _ in
            guard let avAsset = avAsset else {
                completion(nil)
                return
            }
            let assetGenerator = AVAssetImageGenerator(asset: avAsset)
            assetGenerator.appliesPreferredTrackTransform = true
            let time = CMTime(seconds: 0, preferredTimescale: 60)
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let imageRef = try assetGenerator.copyCGImage(at: time, actualTime: nil)
                    let thumbnail = UIImage(cgImage: imageRef)
                    DispatchQueue.main.async {
                        completion(thumbnail)
                    }
                } catch {
                    print("Error generating thumbnail: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
        }
    }
}
