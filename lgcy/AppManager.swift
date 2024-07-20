//
//  AppManager.swift
//  lgcy
//
//  Created by Vlad on 25.01.24.
//

import Foundation
import Combine
import SwiftUI

struct AppManager {
    static let Authenticated = PassthroughSubject<Bool, Never>()
    static let TabIndex = PassthroughSubject<Int, Never>()
    static let isNewMessage = PassthroughSubject<Bool, Never>()
    static func IsAuthenticated() -> Bool {
        return UserDefaults.standard.string(forKey: UserDefaultsKeys.access_token.rawValue) != nil
    }
}
