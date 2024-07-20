//
//  User.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import Foundation

struct User: Codable, Identifiable, Hashable {
    var id = NSUUID().uuidString
    let fullname: String
    let username: String
    let email: String
    var profileImageUrl: String?
}

extension User {
    static let MOCK_USER = User(fullname: "Bruce Wayne", username: "brucewayne", email: "batman@gmail.com", profileImageUrl: "Cordus")

}
