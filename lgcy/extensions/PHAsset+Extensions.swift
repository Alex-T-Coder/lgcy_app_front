//
//  PHAsset.swift
//  lgcy
//
//  Created by Adnan Majeed on 29/02/2024.
//

import Foundation
import Photos
import UIKit
extension PHAsset {
    private func getImage() -> UIImage? {
        let manager = PHCachingImageManager.default
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        var img: UIImage? = nil
        manager().requestImage(for: self, targetSize: CGSize(width: self.pixelWidth, height: self.pixelHeight), contentMode: .aspectFit, options: nil, resultHandler: {(result, info) -> Void in
            img = result!
        })
        return img
    }
    func getData() -> (Data,String) {
        if self.mediaType == .image {
            return ((self.getImage()?.jpegData(compressionQuality: 0.9) ?? Data()),"image/jpeg")
        } else if self.mediaType == .video {
            var output = getVideo()
            return (output.0 ?? Data(),output.1)
        }
        return (Data(),"")
    }

    private func getVideo() -> (Data?,String) {
        let manager = PHCachingImageManager.default
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        var resultData: Data? = nil
        var extensionStr  = "video/mp4"
        manager().requestAVAsset(forVideo: self, options: nil) { (asset, audioMix, info) in

            if let asset = asset as? AVURLAsset, let data = try? Data(contentsOf: asset.url) {
                extensionStr = asset.url.pathExtension
                resultData = data
            }
        }
        return (resultData,extensionStr)
    }
}
