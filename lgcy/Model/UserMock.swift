//
//  User.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import Foundation

struct UserMock: Codable, Identifiable, Hashable {
    var id = NSUUID().uuidString
    let fullname: String
    let username: String
    let email: String
    var profileImageUrl: String?
}

extension UserMock {
    static let MOCK_USER = UserMock(fullname: "Bruce Wayne", username: "brucewayne", email: "batman@gmail.com", profileImageUrl: "Cordus")

}

struct ImageDTO: Codable {
    var memeType:String?
    var real: String?
    var key: String?
    var url: String?
    var isVideo:Bool {
        return memeType?.contains("video") ?? false
    }
    func toDict() -> [String:Any]{
        return ["real":real,"key":key,"url":url,"isVideo":isVideo ]
    }
}


struct UsersResponse: Codable {
    let users:[User]
}

struct User: Codable, Equatable, Identifiable  {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: String
    let name: String?
    let email: String
    let followers: [String]?
    let phoneNumber: String
    let birthday: String?
    let username: String
    let description: String?
    let link: String?
    let notification: Bool
    let directMessage: Bool
    let role: String
    let isEmailVerified: Bool
    let image: ImageDTO?
    static func getFakeUser()->User {
        return  User(id: "1", name: "Chirstian Bale", email: "Chirstianbale@gmail.com", followers: [], phoneNumber: "12939123123", birthday: "10-12-1997", username: "Chirstianbale", description: "Chirstianbale Chirstianbale Chirstianbale", link: nil, notification: true, directMessage: true, role: "user", isEmailVerified: true, image: nil)
    }
}

struct PatchUserRequest: Codable {
    let description: String
    let name: String
    let link: String
}

