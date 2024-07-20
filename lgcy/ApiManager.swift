//
//  ApiManager.swift
//  lgcy
//
//  Created by Vlad on 31.01.24.
//

import Foundation

struct ErrorResponse: Codable, Error {
    let code: Int
    let message: String
    let stack: String?
}

struct ApiBasePaginationResponse<T:Codable>:Codable {
    let results: T
    let page, limit, totalPages, totalResults: Int
}

struct SearchResult: Codable {
    let users: ApiBasePaginationResponse<[User]>
    let timelines: ApiBasePaginationResponse<[TimeLineListModel]>
}

class ApiManager {
    static let  shared = ApiManager()
    
    private var backendURL = Constants.baseURLApi
    init() {
    }

    func patchRequest<T:Codable>(endPoint:String,bodyParams:[String:String],files:[FileModel] = [],isMultiPart:Bool = false,completionHandler: @escaping (Result<T?,Error>)->Void){
        getToken(){[weak self] token in
            guard let self = self else {return }
            let url = URL(string: backendURL + endPoint)!
            var request = URLRequest(url: url)
            request.httpMethod = "PATCH"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let token = UserDefaults.standard.string(forKey: UserDefaultsKeys.access_token.rawValue) {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            if isMultiPart {
                var multipart = MultipartRequest()
                bodyParams.forEach{
                    multipart.add(key: $0.key, value: $0.value)
                }
                files.forEach{
                    multipart.add(key: $0.fildName, fileName: $0.fileName, fileMimeType: $0.fileMemeType, fileData: $0.fileData)
                }
                request.httpBody = multipart.httpBody
                request.setValue(multipart.httpContentTypeHeadeValue, forHTTPHeaderField: "Content-Type")
            }else {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = try? JSONSerialization.data(withJSONObject: bodyParams)
            }
            let task = URLSession.shared.dataTask(with: request) { responseData, response,error in
                guard let response = response as? HTTPURLResponse else {
                    completionHandler(.failure(ErrorResponse.init(code: 500, message: "internal server Error", stack: nil)))
                    return
                }
                do {
                    if response.statusCode >= 400 && response.statusCode <= 500 {
                        let objec = try JSONDecoder().decode(ErrorResponse.self, from: responseData ?? Data())
                        completionHandler(.failure(objec))
                    } else {
                        if let responseData = responseData, !responseData.isEmpty {
                            let objec = try JSONDecoder().decode(T.self, from: responseData)
                            completionHandler(.success(objec))
                            
                        } else {
                            completionHandler(.success(nil))
                        }
                    }
                } catch let error {
                    completionHandler(.failure(error))
                }
            }
            task.resume()
        }
    }

    func postRequest<T:Codable>(endPoint:String,params:[String:Any],files:[FileModel] = [],isMultiPart:Bool = false,completionHandler: @escaping (Result<T,Error>)->Void){
        getToken(){[weak self] token in


            guard let self = self else {return }
            let url = URL(string: backendURL + endPoint)!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"



            if let token = UserDefaults.standard.string(forKey: UserDefaultsKeys.access_token.rawValue) {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            if isMultiPart {


                var multipart = MultipartRequest()
                params.forEach{ param in
                    if let arr = param.value as? Set<String> {
                        for (index, timeline) in arr.enumerated() {
                            multipart.add(key: param.key+"[\(index)]", value: timeline)
                        }
                    } else {
                        multipart.add(key: param.key, value: param.value as! String)
                    }
                }

                files.forEach{
                    multipart.add(key: $0.fildName, fileName: $0.fileName, fileMimeType: $0.fileMemeType, fileData: $0.fileData)
                }

                request.httpBody = multipart.httpBody
                request.setValue(multipart.httpContentTypeHeadeValue, forHTTPHeaderField: "Content-Type")
            }else {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = try? JSONSerialization.data(withJSONObject: params)
            }

            let task = URLSession.shared.dataTask(with: request) { responseData, response,error in
//#if DEBUG
                print("==========URL===============")
                print(request.url)
                print("===========RESPONSE==============")
                print((response as? HTTPURLResponse)?.statusCode)
                print("===========Data==============")
                print(String(data: responseData ?? Data(), encoding: .utf8))
                print("===========END==============")
//#endif
                guard let response = response as? HTTPURLResponse else {
                    completionHandler(.failure(ErrorResponse.init(code: 500, message: "internal server Error", stack: nil)))
                    return
                }
                do {
                    if response.statusCode >= 400 && response.statusCode <= 500 {
                        let objec = try JSONDecoder().decode(ErrorResponse.self, from: responseData ?? Data())
                        completionHandler(.failure(objec))
                    } else {
                        let objec = try JSONDecoder().decode(T.self, from: responseData ?? Data())
                        completionHandler(.success(objec))
                    }
                } catch let error {
                    completionHandler(.failure(error))
                }
            }
            task.resume()
        }
    }

    func getRequest<T:Codable>(endPoint:String,params:[String:String],completionHandler: @escaping (Result<T,Error>)->Void) {
        getToken(){[weak self] token in
            guard let self = self else {return }
            var url = URL(string: backendURL + endPoint)!
            if !params.isEmpty {
                url.append(queryItems: params.map{URLQueryItem(name: $0.key, value: $0.value)})
            }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let token = token {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }

            let task = URLSession.shared.dataTask(with: request) { responseData, response,error in

                #if DEBUG
                print("==========URL===============")
                print(request.url)
                print("===========RESPONSE OF \(endPoint)==============")
                print((response as? HTTPURLResponse)?.statusCode)
                print("===========Data==============")
                print(String(data: responseData ?? Data(), encoding: .utf8))
                print("===========END==============")
                #endif

                guard let response = response as? HTTPURLResponse else {
                    completionHandler(.failure(ErrorResponse.init(code: 500, message: "internal server Error", stack: nil)))
                    return
                }
                do {
                    if response.statusCode >= 400 && response.statusCode <= 500 {
                        let objec = try JSONDecoder().decode(ErrorResponse.self, from: responseData ?? Data())
                        completionHandler(.failure(objec))
                    } else {
                        let objec = try JSONDecoder().decode(T.self, from: responseData ?? Data())
                        completionHandler(.success(objec))
                    }
                } catch let error {
                    completionHandler(.failure(error))
                }
            }
            task.resume()
        }
    }

    func deleteRequest<T:Codable>(endPoint:String,completionHandler: @escaping (Result<T?,Error>)->Void) {
        getToken(){[weak self] token in
            guard let self = self else {return }
            var url = URL(string: backendURL + endPoint)!
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let token = token {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            let task = URLSession.shared.dataTask(with: request) { responseData, response,error in
                guard let response = response as? HTTPURLResponse else {
                    completionHandler(.failure(ErrorResponse.init(code: 500, message: "internal server Error", stack: nil)))
                    return
                }
                do {
                    if response.statusCode >= 400 && response.statusCode <= 500 {
                        let objec = try JSONDecoder().decode(ErrorResponse.self, from: responseData ?? Data())
                        completionHandler(.failure(objec))
                    } else {
                        if let responseData = responseData, !responseData.isEmpty {
                            let objec = try JSONDecoder().decode(T.self, from: responseData)
                            completionHandler(.success(objec))
                            
                        } else {
                            completionHandler(.success(nil))
                        }
                    }
                } catch let error {
                    completionHandler(.failure(error))
                }
            }
            task.resume()
        }
    }

    func getToken(completionHandler:@escaping (String?)->Void) {
        if let token = UserDefaults.standard.string(forKey: UserDefaultsKeys.access_token.rawValue) {
            if isExpired(token: token) {
                refreshAuthTokens(completionHandler: { toke in
                    completionHandler(toke)
                })
            } else {
                completionHandler(token)
            }
        } else {
            completionHandler(nil)
        }
    }

    private func isExpired(token: String) -> Bool {
        var isTokenExpired = false
        if  let payload = try? decodeJWT(jwt: token) {
            if let exp = payload["exp"] as? Int {
                let expDate = Date(timeIntervalSince1970: TimeInterval(exp))
                
                let utcDateFormatter = DateFormatter()
                utcDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                utcDateFormatter.timeZone = TimeZone(identifier: "UTC")
                
                let currentUTCTimeString = utcDateFormatter.string(from: Date())
                let currentUTCTime = utcDateFormatter.date(from: currentUTCTimeString) ?? Date()
                isTokenExpired = expDate < currentUTCTime
            }
            return isTokenExpired
        } else {
            return isTokenExpired
        }
    }

    private func refreshAuthTokens(completionHandler:@escaping (String?)->Void){
       if let token  = UserDefaults.standard.string(forKey: UserDefaultsKeys.refresh_token.rawValue) {
           UserDefaultsManager.shared.clearUserData()
           postRequest(endPoint: "/auth/refresh-tokens", params: ["refreshToken" : token], completionHandler: { (result:Result<RefreshTokenResponse,Error>)in
               switch result {
                   case .success(let refreshResponse):
                   UserDefaults.standard.setValue(refreshResponse.access.token, forKey: UserDefaultsKeys.access_token.rawValue)
                   UserDefaults.standard.setValue(refreshResponse.refresh.token, forKey: UserDefaultsKeys.refresh_token.rawValue)
                       completionHandler(refreshResponse.access.token)
                   case .failure(let failure):
                       print(failure)
                       AppManager.Authenticated.send(false)
                       completionHandler(nil)
               }
           })
       } else {
           completionHandler(nil)
       }
    }

    func getUser(id:String? = nil,completionHandler: @escaping (Result<User,Error>)->Void) {
        var userId = id
        if userId == nil {
            if let token = UserDefaults.standard.string(forKey: UserDefaultsKeys.access_token.rawValue), let payload = try? decodeJWT(jwt: token),let subId = payload["sub"] as? String {
                userId = subId
            }
        }
        if let userId = userId {
            getRequest(endPoint: "/users/\(userId)", params: [:]) { (result:Result<User,Error>) in
                DispatchQueue.main.async {
                    switch result {
                        case .success(let loginResponse):
                            completionHandler(.success(loginResponse))

                        case .failure(let error):
                            completionHandler(.failure(error))
                    }
                }
            }
        } else {
            completionHandler(.failure(ErrorResponse.init(code: 500, message: "internal server Error", stack: nil)))
        }
    }
}

struct FileModel {
    var fileName:String
    var fileData:Data
    var fileMemeType:String
    var fildName:String
}
