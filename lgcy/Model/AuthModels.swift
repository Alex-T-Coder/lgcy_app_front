//
//  AuthModels.swift
//  lgcy
//
//  Created by Adnan Majeed on 16/02/2024.
//

import Foundation

struct RefreshTokenRequest: Codable {
    let refreshToken: String
}

struct RefreshTokenResponse: Codable {
    let access, refresh: Token
}

struct Login: Codable {
    var email: String
    var password: String
}

struct LoginResponse: Codable {
    let tokens: Tokens
    let user: User
}

struct Tokens: Codable {
    let access, refresh: Token
}

struct Token: Codable {
    let token, expires: String
}
