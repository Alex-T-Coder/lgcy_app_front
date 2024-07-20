//
//  PublicTimelineViewModel.swift
//  lgcy
//
//  Created by Adnan Majeed on 28/02/2024.
//

import Foundation
import Combine
import AVFoundation
import SwiftUI
class PublicTimelineViewModel:BaseViewModel {

    var timeLineId:String
    @Published var posts: [FeedPostResponse] = []
    @Published var postVideoThumbnails: Dictionary<String, UIImage> = Dictionary()
    @Published var selectedTimeline: TimelineDTO?
    @Published var selectedPost: FeedPostResponse?
    init(timeLineId: String) {
        self.timeLineId = timeLineId
        super.init()
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


    func getTimeLine(timelineId: String, completion: @escaping (TimelineDTO) -> Void) {
        showActivityIndicator = true
        apiService.getRequest(endPoint: "/timelines/\(timelineId)", params: [:], completionHandler: {  (result:Result<TimelineDTO,Error>) in
            DispatchQueue.main.async {
                self.showActivityIndicator = false
                switch result{
                case .success(let timeline):
                    self.selectedTimeline = timeline
                    completion(timeline)
                case .failure(let error):
                    if let message = (error as? ErrorResponse)?.message {
                        self.validationText = message
                    }
                }
            }

        })
    }

    func  getTimeLinePosts(timelineId: String) {
        showActivityIndicator = true
        apiService.getRequest(endPoint: "/posts?timeline=\(timelineId)", params: ["sortBy":"scheduleDate:desc"],completionHandler: { (result:Result<PostsResponse,Error>) in
            DispatchQueue.main.async {
                self.showActivityIndicator = false
                switch result{
                case .success(let timeline):
                    self.posts = timeline.results
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

    func  getPostDetails(postId: String) {
        showActivityIndicator = true
        apiService.getRequest(endPoint: "/posts/\(postId)", params: [:],completionHandler: { (result:Result<FeedPostResponse,Error>) in
            DispatchQueue.main.async {
                self.showActivityIndicator = false
                switch result{
                case .success(let timeline):
                    self.selectedPost = timeline
                case .failure(let error):
                    if let message = (error as? ErrorResponse)?.message {
                        self.validationText = message
                    }
                }
                self.showActivityIndicator = false
            }
        })
    }
    
    func followTimeLine(timeLineID:String, isFollowing:Bool, completion: @escaping (Bool) -> ()) {
        self.showActivityIndicator = true
        apiService.postRequest(endPoint: "/timelines/\(timeLineID)/\(isFollowing ? "unfollow" : "follow")", params: [:], completionHandler: { (result:Result<ApiBasePaginationResponse<[TimeLineListModel]>,Error>) in
            DispatchQueue.main.async {
                self.showActivityIndicator = false
                switch result{
                    case .success(let timeLines):
                        completion(true)
                    case .failure(_):
                        completion(false)
//                        self.validationText = error.localizedDescription //?? "Something went wrong. Please try later"
                }
            }
        })
    }
}
