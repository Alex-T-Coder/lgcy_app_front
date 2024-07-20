//
//  SettingsViewModel.swift
//  lgcy
//
//  Created by Adnan Majeed on 26/02/2024.
//

import Foundation
import UserNotifications

enum PushNotificationStatus{
    case notDetermined
    case denied
    case authorized
}

class SettingsViewModel:BaseViewModel {
    @Published  var isUserPassword:Bool = false
    @Published  var isUserPhone:Bool = false
    @Published  var notificationsEnabled: Bool =  false
    @Published  var showSettingPage: Bool =  false
    
    @Published var pushNotificationsOn = false
    @Published var isLogoutAlertPresented = false
    @Published var isDeleteAccountAlertPresented = false
    @Published var isPasswordViewPresented = false
    @Published var isMobileNumberViewPresented = false
    @Published var isPrivacyPolicyViewPresented = false
    
    
    @Published var isShowAlert = false
    
    
    func updateUserPassword(currentPassword: String, newPassword: String) {
        showActivityIndicator = true
        apiService.postRequest(endPoint: "/users/updatePassword", params: ["currentPassword":currentPassword,"newPassword":newPassword], completionHandler: {(result:Result<User,Error>) in
            DispatchQueue.main.async {
                self.showActivityIndicator = false
                switch result {
                case .success(_):
                    self.isUserPassword = true
                case .failure(let error):
                    if let message = (error as? ErrorResponse)?.message {
                        self.validationText = message
                    }
                }
            }
        })
    }
    
    
    func updateUserPhone(currentPhone: String, newPhone: String) {
        showActivityIndicator = true
        apiService.postRequest(endPoint: "/users/updatePhone/", params: ["currentPhone":currentPhone,"newPhone":newPhone], completionHandler: {(result:Result<User,Error>) in
            DispatchQueue.main.async {
                self.showActivityIndicator = false
                switch result {
                case .success(_):
                    self.isUserPassword = true
                case .failure(let error):
                    if let message = (error as? ErrorResponse)?.message {
                        self.validationText = message
                    }
                }
            }
        })
        
    }
    
    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                self.showSettingPage = false
                self.notificationsEnabled = true
                print("Notification authorization granted")
            } else if let error = error {
                self.validationText =  error.localizedDescription
                print("Notification authorization denied")
            }
        }
    }
    
    func checkNotificationAuthorization(completion : @escaping (PushNotificationStatus) -> ()) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    completion(.notDetermined)
                    self.pushNotificationsOn = false
//                    self.notificationsEnabled = false
//                    self.pushNotificationsOn = false
                case .denied:
                    completion(.denied)
                    self.pushNotificationsOn = false
//                    self.notificationsEnabled = false
//                    self.pushNotificationsOn = false
                case .authorized:
                    completion(.authorized)
                    self.pushNotificationsOn = true
//                    self.notificationsEnabled = true
//                    self.pushNotificationsOn = true
                default:
                    completion(.notDetermined)
                    self.pushNotificationsOn = false
//                    self.notificationsEnabled = false
//                    self.pushNotificationsOn = false
                }
            }
        }
    }
    
    func deleteAccount(id: String) {
        apiService.deleteRequest(endPoint: "/users/\(id)",completionHandler: {(result:Result<Optional<String>,Error>) in
            DispatchQueue.main.async {
                AppManager.Authenticated.send(false)
            }
        })
    }
}
