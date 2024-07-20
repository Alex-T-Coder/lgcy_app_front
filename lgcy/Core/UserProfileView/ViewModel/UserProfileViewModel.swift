//
//  UserProfileViewModel.swift
//  lgcy
//
//  Created by Adnan Majeed on 20/02/2024.
//

import Foundation
import Combine
import AVFoundation
import SwiftUI
class UserProfileViewModel: BaseViewModel {
    @Published var isCreateTimelineViewPresented = false
    @Published var isEditProfileViewPresented = false
    @Published var isEditTimelineViewPresented = false
    @Published var isSettingsViewPresented = false
    @Published var isUserTimelineViewPresented = false
    @Published var userProfileImage: Image = Image("Cordus")
    @Published var selectedTimeline: TimelineDTO?
    @Published var selectedPost: FeedPostResponse?
    @Published var timelines: [TimelineDTO]!
    @Published var postVideoThumbnails: Dictionary<String, UIImage> = Dictionary()
    @Published var posts: [FeedPostResponse] = []
    @Published var isUpdated: Bool = false
    
    @Published var user:User = User(id: "", name: "", email: "", followers: [], phoneNumber: "", birthday: "", username: "", description: "", link: "", notification: false, directMessage: false, role: "", isEmailVerified: false, image: nil)
    
    override init() {
        self.timelines = []
        super.init()
        if let user = UserDefaultsManager.shared.loginUser {
            self.user = user
        } else {
            showActivityIndicator = true
            apiService.getUser(completionHandler: {result in
                DispatchQueue.main.async {
                    self.showActivityIndicator = false
                    switch result{
                    case .success(let user):
                        self.user = user
                        UserDefaultsManager.shared.loginUser = user
                    case .failure(let error):
                        if let message = (error as? ErrorResponse)?.message {
                            self.validationText = message
                        }
                        
                        print(error.localizedDescription)
                    }
                }
            })
        }
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

    func updateProfile(description: String, name: String, link: String, userProfileImage: UIImage?,success: @escaping (Bool) -> ()) {
        showActivityIndicator = true
        var files:[FileModel]  = []
        if let userProfileImage = userProfileImage?.jpegData(compressionQuality: 0.9) {
            files.append(FileModel(fileName: "userProfileImage", fileData: userProfileImage , fileMemeType: "image/jpeg", fildName: "myFile"))
        }
        apiService.patchRequest(endPoint: "/users/", bodyParams: ["description": description,"name": name,"link": link],files: files,isMultiPart: true, completionHandler: { (result:Result<User?,Error>) in
            DispatchQueue.main.async {
                self.showActivityIndicator = false
                switch result{
                case .success(let user):
                    if let user = user {
                        self.user = user
                        UserDefaultsManager.shared.loginUser = user
                        success(true)
                    }
                case .failure(let error):
                    if let message = (error as? ErrorResponse)?.message {
                        self.validationText = message
                    }
                    success(false)
                }
            }
        })
    }
    
    func getUserTimeLine() {
        self.showActivityIndicator = true
        apiService.getRequest(endPoint: "/timelines/ByCreator", params: [:], completionHandler: { (result:Result<ApiBasePaginationResponse<[TimelineDTO]>,Error>) in
            DispatchQueue.main.async {
                self.showActivityIndicator = false
                switch result{
                case .success(let timeLines):
                    self.timelines = timeLines.results
                case .failure(let error):
                    if let message = (error as? ErrorResponse)?.message {
                        self.validationText = message
                    }
                }
            }
        })
    }
    
    func  updateTimeLine(timelineId: String, link: String,title: String, description: String, statusFollowerShow: Bool, timeLineImage: UIImage?, completion: @escaping (TimelineDTO?) -> ()) {
        showActivityIndicator = true
        var files:[FileModel]  = []
        if let userProfileImage = timeLineImage?.jpegData(compressionQuality: 0.9) {
            files.append(FileModel(fileName: "timelineImage", fileData: userProfileImage , fileMemeType: "image/jpeg", fildName: "myFile"))
        }
        apiService.patchRequest(endPoint: "/timelines/\(timelineId)", bodyParams: ["description": description,"title": title,"link": link,"status[followerShown]":String(statusFollowerShow)],files: files,isMultiPart: true, completionHandler: { (result:Result<TimelineDTO1?, Error>) in
            DispatchQueue.main.async {
                self.showActivityIndicator = false
                switch result{
                case .success(let timeline):
                    self.getUserTimeLine()
                    if let timeline = timeline {
                        let updatedTimeline = TimelineDTO(id: timeline.id, title: timeline.title, description: timeline.description, link: timeline.link, coverImage: timeline.coverImage, status: timeline.status, creator: Creator(id: timeline.creator, name: "", description: "", image: nil, username: ""), followers: timeline.followers)
                        if let index =  self.timelines.firstIndex(where: { t in
                            t.id == timelineId
                        }) {
                            self.timelines[index] = updatedTimeline
                        }
                        self.selectedTimeline = nil
                        //                        self.isUpdated = true
                        completion(updatedTimeline)
                    }
                case .failure(let error):
                    if let message = (error as? ErrorResponse)?.message {
                        self.validationText = message
                    }
                    completion(nil)
                }
            }
        })
    }
    
    func deleteTimeLine(timelineId: String, completion: @escaping (Bool) -> ()) {
        showActivityIndicator = true
        apiService.deleteRequest(endPoint: "/timelines/\(timelineId)", completionHandler: { (result:Result<User?,Error>) in
            DispatchQueue.main.async {
                self.showActivityIndicator = false
                switch result{
                case .success(let obj):
                    self.timelines.removeAll(where: { t in
                        t.id == timelineId
                    })
                    self.selectedTimeline = nil
                    self.isUpdated = true
                    completion(true)
                case .failure(let error):
                    if let message = (error as? ErrorResponse)?.message {
                        self.validationText = message
                    }
                    completion(false)
                }
            }
        })
    }
    func addTimeLine(link: String,title: String, description: String, statusFollowerShow: Bool, timeLineImage: UIImage?, imageType: String, completion: @escaping ([TimelineDTO]) -> ()) {
        showActivityIndicator = true
        var files:[FileModel]  = []
        if let userProfileImage = timeLineImage?.jpegData(compressionQuality: 0.9) {
            files.append(FileModel(fileName: "timelineImage", fileData: userProfileImage , fileMemeType: "image/jpeg", fildName: "myFile"))
        }
        apiService.postRequest(endPoint: "/timelines/", params: ["description": description,"title": title,"link": link,"status[followerShown]":String(statusFollowerShow), "imageType": imageType],files: files,isMultiPart: true, completionHandler: { (result:Result<TimelineDTO1,Error>) in
            DispatchQueue.main.async {
                self.showActivityIndicator = false
                switch result{
                case .success(let timeline):
                    self.timelines.append(TimelineDTO(id: timeline.id, title: timeline.title, description: timeline.description, link: timeline.link, coverImage: timeline.coverImage, imageType: timeline.imageType, status: timeline.status, creator: Creator(id: timeline.creator, name: "", description: "", image: nil, username: ""), followers: timeline.followers))
                    self.selectedTimeline = nil
                    self.isUpdated = true
                    completion(self.timelines)
                case .failure(let error):
                    if let message = (error as? ErrorResponse)?.message {
                        self.validationText = message
                    }
                    completion(self.timelines)
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
}
