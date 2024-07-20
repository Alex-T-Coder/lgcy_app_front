//
//  TimeLineListView.swift
//  lgcy
//
//  Created by Adnan Majeed on 21/02/2024.
//

import Foundation
// MARK: - TimeLineListModel
class TimeLineListModel: Codable, Equatable, Identifiable {
    static func == (lhs: TimeLineListModel, rhs: TimeLineListModel) -> Bool {
        lhs.id == rhs.id
    }
    var coverImage: ImageDTO?
    var status: Status
    var followers: [Creator]
    var creator:Creator
    var title, description: String
    var createdAt, id: String

    init(coverImage: ImageDTO, status: Status, followers: [Creator], title: String, description: String, creator: Creator, createdAt: String, id: String) {
        self.coverImage = coverImage
        self.status = status
        self.followers = followers
        self.title = title
        self.description = description
        self.creator = creator
        self.createdAt = createdAt
        self.id = id
    }
}


    // MARK: - Status
class Status: Codable {
    var value: String
    var followerShown: Bool
    var inviters: [String]

    init(value: String, followerShown: Bool, inviters: [String]) {
        self.value = value
        self.followerShown = followerShown
        self.inviters = inviters
    }
}

