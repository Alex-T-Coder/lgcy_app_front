//
//  NotificationModel.swift
//  lgcy
//
//  Created by Adnan Majeed on 22/02/2024.
//

import Foundation

enum NotificationType: String,Codable {
    case COMMENT = "comment"
    case LIKE = "like"
    case MSG =  "message"
    case POST = "post"
    case TIMELINE = "timeline"
    case LIKECOMMENT = "likecomment"
}

// MARK: - NotificationModel
class NotificationModel: Codable,Identifiable, ObservableObject {
    let data: NotificationTarget
    var status: Bool
    let from, to: User?
    let createdAt: String
    let type:NotificationType
    let id: String

    var getText:String {
        switch  (self.type) {
            case .COMMENT:
                return " commented on your post"
            case .LIKE:
                return " liked your post"
            case .MSG:
                return " message you. "
            case .POST:
                return " share a post. "
            case .TIMELINE:
                return " followed your timeline"
            case .LIKECOMMENT:
                return " liked your comment"
        }
    }
    
    var getImage: String {
        switch  (self.type) {
        case .COMMENT, .LIKECOMMENT, .LIKE, .POST:
            return self.data.posts.first?.files?.first?.url ?? ""
        case .TIMELINE:
            return self.data.timelines.first?.coverImage?.url ?? ""
        case .MSG:
            return self.data.users.first?.image?.url ?? ""
        }
    }
    
    var getId: String {
        switch  (self.type) {
        case .COMMENT, .LIKECOMMENT:
            return self.data.posts.first?.id ?? ""
        case .LIKE:
            return self.data.posts.first?.id ?? ""
        case .TIMELINE:
            return self.data.timelines.first?.id ?? ""
        case .MSG:
            return self.data.users.first?.id ?? ""
        case .POST:
            return self.data.posts.first?.id ?? ""
        }
    }
}

// MARK: - DataClass
class NotificationTarget: Codable {
    let users: [User]
    let timelines: [TimelineDTO]
    let posts: [FeedPostResponse]
}
