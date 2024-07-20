//
//  TimelineDTO.swift
//  lgcy
//
//  Created by Adnan Majeed on 16/02/2024.
//

import Foundation
struct TimelineDTO: Codable, Identifiable {
    var id: String
    var title: String
    var description: String
    var link: String?
    var coverImage: ImageDTO?
    var imageType: String?
    var status: TimelineStatus
    var creator: Creator
    var followers: [User]
    var isUserFollower:Bool {
        return followers.contains(where: { $0.id == UserDefaultsManager.shared.loginUser?.id ?? ""})
    }
}

struct TimelineDTO1: Codable, Identifiable {
    var id: String
    var title: String
    var description: String
    var link: String?
    var coverImage: ImageDTO?
    var imageType: String?
    var status: TimelineStatus
    var creator: String
    var followers: [User]
    var isUserFollower:Bool {
        return followers.contains(where: { $0.id == UserDefaultsManager.shared.loginUser?.id ?? ""})
    }
}

struct TimelineDTO2: Codable, Identifiable {
    var id: String
    var title: String
    var description: String
    var link: String?
    var coverImage: ImageDTO?
    var imageType: String?
    var status: TimelineStatus
    var creator: String
    var followers: [String]
    var isUserFollower:Bool {
        return followers.contains(where: { $0 == UserDefaultsManager.shared.loginUser?.id ?? ""})
    }
}

struct TimelineStatus: Codable {
    let value: String?
    let followerShown: Bool
    let inviters: [String]?
}


struct CreateTimelineRequest: Codable {
    let title: String
    let link: String
    let description: String
    let followerShown: Bool
}

struct PostDTO: Codable, Identifiable {
    let id: String
    let location: String?
    let description: String?
    let scheduleDate: String?
    let liking: Bool
    let commenting: Bool
    let twitter: Bool
    let creator: String
    let files: [ImageDTO]
}

struct PostDetails: Codable, Identifiable {
    let id: String
    let location: String?
    let description: String?
    let scheduleDate: String?
    let liking: Bool
    let commenting: Bool
    let twitter: Bool
    let creator: Creator
    let files: [ImageDTO]
}

struct PostsResponse: Codable {
    let results: [FeedPostResponse]
}

