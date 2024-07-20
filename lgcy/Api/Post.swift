//
//  Post.swift
//  lgcy
//
//  Created by Vlad on 7.02.24.
//

import Foundation

struct CreatePostRequest: Codable {
    let location: String
    let description: String
    let scheduleDate: String
    let liking: Bool
    let commenting: Bool
    let share: ShareDTO
}

struct ShareDTO: Codable {
    let users: [String]
    let timelines: [String]
}


