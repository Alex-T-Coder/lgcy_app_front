//
//  AuthViewModel.swift
//  lgcy
//
//  Created by Adnan Majeed on 19/02/2024.
//

import Foundation
class AuthViewModel:BaseViewModel {
    
    @Published var email:String = ""
    @Published var name:String = ""
    @Published var userName:String = ""
    @Published var password:String = ""
    @Published var phoneNumber:String = ""
    
    @Published var isLoggedinSuccess = false
    @Published var isRegisterSuccess = false
    @Published var isEmailAvailable = false
    @Published var isNameAvailable = false
    @Published var isVerificationCodeSent = false
    @Published var isPhoneVerified = false

    func login(email: String, password: String)  {
        showActivityIndicator = true
        apiService.postRequest(endPoint: "/auth/login", params: ["email": email, "password": password]) { (result:Result<LoginResponse,Error>) in
            DispatchQueue.main.async{
                switch result {
                    case .success(let loginResponse):
                    UserDefaults.standard.setValue(loginResponse.tokens.access.token, forKey: UserDefaultsKeys.access_token.rawValue)
                    UserDefaults.standard.setValue(loginResponse.tokens.refresh.token, forKey: UserDefaultsKeys.refresh_token.rawValue)
                        self.getUser()
                    case .failure(let error):
                        self.validationText = (error as? ErrorResponse)?.message ?? ""
                        self.showActivityIndicator = false
                }
            }
        }
    }

    func checkAvailabilityOf(params:[String:String]) {
        showActivityIndicator = true
        apiService.postRequest(endPoint: "/auth/availability", params: params) { (result:Result<CheckAvailabilityResponse,Error>) in
            DispatchQueue.main.async{
                switch result {
                case .success(let loginResponse):
                    self.showActivityIndicator = false
                    self.isEmailAvailable = loginResponse.isAvailable
                    if !loginResponse.isAvailable {
                        self.validationText = "\(params.keys.first!.capitalized) Already Taken"
                        if params.keys.first != "email" {
                            self.showValidationAlertForUsername = true
                        }
                    }
                case .failure(let error):
                    if let message = (error as? ErrorResponse)?.message {
                        self.validationText = message
                    }
                    if params.keys.first != "email" {
                        self.showValidationAlertForUsername = true
                    }
                    self.showActivityIndicator = false
                }
            }
        }
    }

    func registerUser(params:[String:String]) {
        showActivityIndicator = true
        apiService.postRequest(endPoint: "/auth/register", params: params) { (result:Result<LoginResponse,Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let loginResponse):
                    UserDefaults.standard.setValue(loginResponse.tokens.access.token, forKey: UserDefaultsKeys.access_token.rawValue)
                    UserDefaults.standard.setValue(loginResponse.tokens.refresh.token, forKey: UserDefaultsKeys.refresh_token.rawValue)
                    self.isRegisterSuccess = true
                    self.getUser()
                case .failure(let error):
                    DispatchQueue.main.async {
                        if let message = (error as? ErrorResponse)?.message {
                            self.validationText = message
                        }
                    }
                    self.showActivityIndicator = false
                }
            }
        }
    }
    
    func getUser() {
        showActivityIndicator = true
        apiService.getUser{ (result:Result<User,Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let loginResponse):
                    UserDefaultsManager.shared.loginUser = loginResponse
                    self.registerupdateRegisterToken()
                case .failure(let error):
                    if let message = (error as? ErrorResponse)?.message {
                        self.validationText = message
                    }
                    self.showActivityIndicator = false
                }
            }
        }
    }

    func registerupdateRegisterToken() {
        if let token = UserDefaultsManager.shared.notificationToken,let userId = UserDefaultsManager.shared.loginUser?.id {
            apiService.postRequest(endPoint: "/users/\(userId)/updateAPNS", params: ["token":token]) { (result:Result<User,Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let loginResponse):
                        self.showActivityIndicator = false
                        self.isLoggedinSuccess = true
                        print(loginResponse)
                    case .failure(let error):
                        if let message = (error as? ErrorResponse)?.message {
                            self.validationText = message
                        }
                        self.showActivityIndicator = false
                    }
                }
            }
        }
    }

    func sendVerificationCode(phoneNumber:String) {
        showActivityIndicator = true
        
        self.isVerificationCodeSent = true
        self.showActivityIndicator = false
//        apiService.postRequest(endPoint: "/auth/sendOtpToPhone", params: [ "phoneNumber":phoneNumber]) { (result:Result<CheckAvailabilityResponse,Error>) in
//            DispatchQueue.main.async {
//                switch result {
//                    case .success(let loginResponse):
//                        self.isVerificationCodeSent = true
//                        self.showActivityIndicator = false
//                    case .failure(let error):
//                        self.validationText = error.localizedDescription
//                        self.showActivityIndicator = false
//                }
//            }
//        }
    }


    func verifyCode(phoneNumber:String,otp:String) {
        showActivityIndicator = true
        self.isPhoneVerified = true
        self.showActivityIndicator = false
//        apiService.postRequest(endPoint: "/auth/verifyOTP", params: [ "phoneNumber":phoneNumber,"otp":otp]) { (result:Result<CheckAvailabilityResponse,Error>) in
//            DispatchQueue.main.async {
//                switch result {
//                    case .success(_):
//                        self.isPhoneVerified = true
//                        self.showActivityIndicator = false
//                    case .failure(let error):
//                        self.validationText = error.localizedDescription
//                        self.showActivityIndicator = false
//                }
//            }
//        }
    }

    struct CheckAvailabilityResponse: Codable {
        var isAvailable: Bool
        var id:String?
        var msg:String?
    }

}
