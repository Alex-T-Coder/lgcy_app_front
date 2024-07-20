//
//  FeedPostResponse.swift
//  lgcy
//
//  Created by Adnan Majeed on 16/02/2024.
//

import Foundation

struct FeedPostResponse: Codable,Equatable,Identifiable {
    static func == (lhs: FeedPostResponse, rhs: FeedPostResponse) -> Bool {
        lhs.id == rhs.id
    }
    var share: Share
    var likes: [User]?
    var liking, commenting, twitter: Bool
    var files: [ImageDTO]?
    var location, description, scheduleDate: String?
    var creator: Creator
    var createdAt, id: String
    var comments: [String]?
    init(share: Share, likes: [User], liking: Bool, commenting: Bool, twitter: Bool, files: [ImageDTO]?, location: String?, description: String?, scheduleDate: String?, creator: Creator, createdAt: String, id: String) {
        self.share = share
        self.likes = likes
        self.liking = liking
        self.commenting = commenting
        self.twitter = twitter
        self.files = files
        self.location = location
        self.description = description
        self.scheduleDate = scheduleDate
        self.creator = creator
        self.createdAt = createdAt
        self.id = id
    }
}

struct LikePostResponse: Codable {
    var liked: Bool
}

struct LikeCommentResponse: Codable {
    var liked: Bool
}

//{\"content\":\"Hello \",\"user\":\"6662eb363156863b7867500d\",\"post\":\"6662ee272116733bf8371e67\",\"replies\":[],\"createdAt\":\"2024-06-07T11:58:13.904Z\",\"id\":\"6662f5d5d5d1b23c0b14f68a\"}
struct CommentResponse: Codable {
    var content, user, post, id, createdAt: String
    var replies: [String]?
}

struct GetCommentResponse: Codable {
    var content, post, id, createdAt: String
    var user: GetCommentUserResponse
    var replies: [String]?
    var likes: [User]?
}

struct GetCommentUserResponse: Codable {
    var username: String
    var id: String
    var image: ImageDataResponse?
}

struct ImageDataResponse: Codable {
    var id, real, url, key: String
    
    enum CodingKeys: String, CodingKey {
        case real, url, key
        case id = "_id"
    }
}

struct PostDetailsResponse: Codable,Equatable,Identifiable {
    static func == (lhs: PostDetailsResponse, rhs: PostDetailsResponse) -> Bool {
        lhs.id == rhs.id
    }
    var share: ShareCreator
    var likes: [User]?
    var liking, commenting, twitter: Bool
    var files: [ImageDTO]?
    var location, description, scheduleDate: String?
    var creator: Creator
    var createdAt, id: String
    init(share: ShareCreator, likes: [User], liking: Bool, commenting: Bool, twitter: Bool, files: [ImageDTO]?, location: String?, description: String?, scheduleDate: String?, creator: Creator, createdAt: String, id: String) {
        self.share = share
        self.likes = likes
        self.liking = liking
        self.commenting = commenting
        self.twitter = twitter
        self.files = files
        self.location = location
        self.description = description
        self.scheduleDate = scheduleDate
        self.creator = creator
        self.createdAt = createdAt
        self.id = id
    }
}

struct Creator: Codable,Equatable {
    static func == (lhs: Creator, rhs: Creator) -> Bool {
        lhs.id == rhs.id
    }
    let id: String
    let name: String?
    let description: String?
    let image: ImageDTO?
    let username: String?
}

struct MessageReceiver: Codable,Equatable {
    static func == (lhs: MessageReceiver, rhs: MessageReceiver) -> Bool {
        lhs.id == rhs.id
    }
    let id: String
}

struct ShareCreator: Codable {
    var users: [User]
    var timelines: [TimelineDTO2]
//    var users, timelines: [String]
    init(users: [User], timelines: [TimelineDTO2]) {
        self.users = users
        self.timelines = timelines
    }
}

    // MARK: - Share
struct Share: Codable {
    var users: [User]
    var timelines: [TimelineDTO2]
//    var users, timelines: [String]
    init(users: [User], timelines: [TimelineDTO2]) {
        self.users = users
        self.timelines = timelines
    }
}
