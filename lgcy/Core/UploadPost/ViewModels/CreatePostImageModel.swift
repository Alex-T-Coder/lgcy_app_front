//
//  ImageModel.swift
//  lgcy
//
//  Created by Evan Boymel on 6/6/24.
//

import SwiftUI
import Photos

struct CreatePostImageModel: Identifiable, Equatable
{
    var id = UUID()
    var image: UIImage?
    var video: PHAsset?
    var videoData: Data?
    var videoLength: Double?
    var type: Int
    
    // Wrapper function to convert callback-based API to async
    func requestAVAsset(forVideo asset: PHAsset) async throws -> AVAsset {
        return try await withCheckedThrowingContinuation { continuation in
            let options = PHVideoRequestOptions()
            options.version = .original
            
            PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, _, error in
                if let avAsset = avAsset {
                    continuation.resume(returning: avAsset)
                } else {
                    continuation.resume(throwing: NSError(domain: "com.example.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch AVAsset"]))
                }
            }
        }
    }
    
    // Convert video to Data using async/await
    func convertVideoToData() async throws -> Data {
        if let asset = self.video {
            let avAsset = try await requestAVAsset(forVideo: asset)
            
            if let avURLAsset = avAsset as? AVURLAsset {
                do {
                    let videoData = try Data(contentsOf: avURLAsset.url)
                    return videoData
                } catch {
                    throw error
                }
            } else {
                throw NSError(domain: "com.example.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "AVAsset is not AVURLAsset"])
            }
        } else {
            return Data()
        }
    }
}
