//
//  UserDefaultsManager.swift
//  lgcy
//
//  Created by Adnan Majeed on 19/02/2024.
//

import Foundation
enum UserDefaultsKeys: String {
    case access_token = "access_token"
    case refresh_token = "refresh_token"
    case notification_token = "notification_token"
    case notificationEnabled = "_User_Notification_State_"
    case loginUser = "_loginUser_"

}

class UserDefaultsManager: ObservableObject {
    static let shared = UserDefaultsManager()
    let userDefaults = UserDefaults.standard
    var isTransferApiNeed = true
    var needResetFilter = false
    var transferSusses = false
    
    var loginUser:User? {
        didSet {
            if let loginUser = loginUser  {
                let encode = JSONEncoder()
                userDefaults.set(try? encode.encode(loginUser),forKey: UserDefaultsKeys.loginUser.rawValue)
            }
        }
    }
    
    var notificationToken: String? {
        set {
            if newValue == nil {
                userDefaults.removeObject(forKey: UserDefaultsKeys.notification_token.rawValue)
            }
            else {
                userDefaults.set(newValue, forKey: UserDefaultsKeys.notification_token.rawValue)
            }
        }
        get {
            userDefaults.string(forKey: UserDefaultsKeys.notification_token.rawValue)
        }
    }

    var notificationEnabled: Bool? {
        set {
            if newValue == nil {
                userDefaults.removeObject(forKey: UserDefaultsKeys.notificationEnabled.rawValue)
            }
            else {
                userDefaults.set(newValue, forKey: UserDefaultsKeys.notificationEnabled.rawValue)
            }
        }
        get {
            userDefaults.bool(forKey: UserDefaultsKeys.notificationEnabled.rawValue)
        }
    }
    
    func clearUserData() {
        loginUser = nil
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.access_token.rawValue)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.refresh_token.rawValue)
        UserDefaults.standard.setValue(nil, forKey: UserDefaultsKeys.access_token.rawValue)
        UserDefaults.standard.setValue(nil, forKey: UserDefaultsKeys.refresh_token.rawValue)
    }

    init() {
        if let data = userDefaults.data(forKey: UserDefaultsKeys.loginUser.rawValue) {
            let encode = JSONDecoder()
            loginUser = try? encode.decode(User.self, from: data)
        }
    }
}
