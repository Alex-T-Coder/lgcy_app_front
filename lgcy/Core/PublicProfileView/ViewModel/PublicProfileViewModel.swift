//
//  PublicProfileViewModel.swift
//  lgcy
//
//  Created by Adnan Majeed on 26/02/2024.
//

import Foundation
import Combine
import AVFoundation
import SwiftUI

class PublicProfileViewModel:BaseViewModel {
    var userId:String
    @Published var timelines: [TimelineDTO]!
    @Published var posts: [FeedPostResponse]!
    @Published var postVideoThumbnails: Dictionary<String, UIImage> = Dictionary()
    @Published var isUserTimelineViewPresented = false
    @Published var selectedTimeLineID:String  = ""
    @Published var user:User = User(id: "", name: "", email: "", followers: [], phoneNumber: "", birthday: "", username: "", description: "", link: "", notification: false, directMessage: false, role: "", isEmailVerified: false, image: nil)
    init(userId: String) {
        self.userId = userId
        self.timelines = []
        super.init()
        self.fetchUserObject()
        self.getUserTimeLine()
    }
    
    func generateThumbnail(url: URL) async -> UIImage? {
        let asset = AVAsset(url: url)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImageGenerator.appliesPreferredTrackTransform = true

        let time = CMTime(seconds: 1, preferredTimescale: 60)
        do {
            let cgImage = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
            let uiImage = UIImage(cgImage: cgImage)
            return uiImage
        } catch {
            print("Failed to generate thumbnail: \(error.localizedDescription)")
            return nil
        }
    }

    func fetchUserObject() {
        self.showActivityIndicator = true
        apiService.getUser(id: userId, completionHandler: { response in
            DispatchQueue.main.async {
                switch response {
                    case .success(let user):
                        self.user = user
                    case .failure(let error):
                        print(error.localizedDescription)
                        break
                }
            }
        })
    }

    func getUserTimeLine() {
        self.showActivityIndicator = true
        apiService.getRequest(endPoint: "/timelines/ByUser", params: ["userId":userId], completionHandler: { (result:Result<ApiBasePaginationResponse<[TimelineDTO]>,Error>) in
            DispatchQueue.main.async {
                switch result{
                case .success(let timeLines):
                    self.timelines = timeLines.results
                case .failure(let error):
                    if let message = (error as? ErrorResponse)?.message {
                        self.validationText = message
                    }
                }
                self.showActivityIndicator = false
            }
        })
    }

    func getPrivatePosts(userId: String) {
        self.showActivityIndicator = true
        apiService.getRequest(endPoint: "/posts/private/\(userId)", params: ["sortBy":"createdAt:desc", "limit":"100"], completionHandler: {
            (result: Result<ApiBasePaginationResponse<[FeedPostResponse]>, Error>) in
            DispatchQueue.main.async {
                switch result{
                case .success(let res):
                    self.posts = res.results
                    for post in self.posts {
                        if let file = post.files?.first, let url = URL(string: file.url ?? "") {
                            if file.isVideo {
                                Task {
                                    self.postVideoThumbnails[post.id] = await self.generateThumbnail(url: url)
                                }
                            }
                        }
                    }
                case .failure(let error):
                    if let message = (error as? ErrorResponse)?.message {
                        self.validationText = message
                    }
                }
                self.showActivityIndicator = false
            }
        })
    }
    

}
