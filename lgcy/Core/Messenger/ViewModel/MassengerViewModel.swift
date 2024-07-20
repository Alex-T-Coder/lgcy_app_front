//
//  MassengerViewModel.swift
//  lgcy
//
//  Created by Adnan Majeed on 21/02/2024.
//

import Foundation
import UIKit
import Photos
import Contacts
class MassengerViewModel: BaseViewModel {
    @Published var chatList:[ChatListResponse] = []
    @Published var selectedChat:ChatListResponse?
    @Published var selectedChatIndex:Int = 0
    @Published var users:[User] = []
    
    func getLastReceivedMessage(messages: [Message], userID: String) -> Message? {
        if let lastReceivedMessage = messages.last(where: { $0.sender.id == userID }) {
            print(lastReceivedMessage.isSeen)
            return lastReceivedMessage
        } else {
            return nil
        }
    }
    
    func getAllChats() {
        self.showActivityIndicator = true
        apiService.getRequest(endPoint: "/chats/", params: [:]) { (result:Result<[ChatListResponse],Error>) in
            DispatchQueue.main.async{
                switch result {
                case .success(let respo):
                    self.chatList = respo
                case .failure(let error):
                    if let message = (error as? ErrorResponse)?.message {
                        self.validationText = message
                    }
                }
                self.showActivityIndicator = false
            }
        }
    }

    
    func getChatAgainst(userId:String, name: String, desc: String, image: ImageDTO?, username: String) {
        self.showActivityIndicator = true
        apiService.getRequest(endPoint: "/chats/against", params: ["userId":userId]) { (result:Result<ChatListResponse,Error>) in
            DispatchQueue.main.async{
                switch result {
                case .success(let respo):
                    self.selectedChat = respo
                case .failure(let error):
                    
                    if (error as? ErrorResponse)?.message.contains("Chat not found") ?? false == false {
                        self.validationText = (error as? ErrorResponse)?.message ?? ""
                    } else {
                        self.selectedChat = ChatListResponse(messages: [], receiver: Creator(id: userId, name: name, description: desc, image: image, username: username), sender: Creator(id: UserDefaultsManager.shared.loginUser?.id ?? "", name: UserDefaultsManager.shared.loginUser?.name ?? "", description: UserDefaultsManager.shared.loginUser?.description ?? "", image: UserDefaultsManager.shared.loginUser?.image, username: UserDefaultsManager.shared.loginUser?.username ?? ""), createdAt: "\(Date.now)", id: UUID().uuidString, blocker: "")
                    }
                }
                self.showActivityIndicator = false
            }
        }
    }
    
    func updateMessageToSeen(chatId: String, messageId: String, completion: @escaping (Bool?) -> Void) {
        self.showActivityIndicator = true
        apiService.patchRequest(endPoint: "/chats/\(chatId)", bodyParams: ["messageId": messageId]) {
            (result: Result<Bool?, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    if let index = self.chatList.firstIndex(where: { $0.id == chatId }) {
                        if let messageIndex = self.chatList[index].messages.firstIndex(where: { $0.id == messageId }) {
                            self.chatList[index].messages[messageIndex].isSeen = true
                        }
                    }
                    completion(true)
                    break
                case .failure(_):
                    completion(false)
                    break
                }
            }
        }
    }
    
    func createPrivatePost(userId: String, files: [FileModel], completion: @escaping (PostDTO?) -> Void) {
        apiService.postRequest(endPoint:  "/posts", params: ["share[users]":[userId] as Set<String>],files:files,isMultiPart: true, completionHandler: {
            (result:Result<PostDTO,Error>) in
            DispatchQueue.main.async {
                self.showActivityIndicator = false
                switch result{
                case .success(let res):
                    completion(res)
                case .failure(let error):
                    if let message = (error as? ErrorResponse)?.message {
                        self.validationText = message
                    }
                    completion(nil)
                }
            }
        })
    }

    
//    func uploadChatFile(fileSelected:ImageModel?,completionHandler: @escaping (ImageDTO?)->Void) {
//        if fileSelected == nil {
//            completionHandler(nil)
//            return
//        }
//        let isVideo = fileSelected?.file.mediaType == .video
//        _ = fileSelected?.file
//        var (data,ext) =  fileSelected!.file.getData()
//
//        let file = FileModel(fileName: "\(Int64(Date().timeIntervalSince1970.rounded()))", fileData:data,
//                             fileMemeType: ext  ,
//                             fildName: "file")
//        apiService.postRequest(endPoint: "/chats/uploadFile/", params: [:],files: [file],isMultiPart: true)
//        { (result:Result<ImageDTO,Error>) in
//            switch result {
//                case .success(let respo):
//                    completionHandler(respo)
//                case .failure(let error):
//                    print(error.localizedDescription)
//                    completionHandler(nil)
//            }
//        }
//    }


    func syncingContacts(contact:[String], complete: @escaping ([User]) -> Void) {
        apiService.postRequest(endPoint: "/chats/getAllUserWithPhone/", params: ["phoneNumbers":contact],isMultiPart: false)
        { (result:Result<[User],Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let respo):
                    var tempUsers = [User]()
                    for res in respo {
                        if res.id != UserDefaultsManager.shared.loginUser?.id ?? "" {
                            tempUsers.append(res)
                        }
                    }
                    complete(tempUsers)
                case .failure(let error):
                    if let message = (error as? ErrorResponse)?.message {
                        self.validationText = "Error fetching contacts: \(message)"
                    }
                }
                self.showActivityIndicator = false
            }
        }

    }

    func fetchContacts() {
        self.showActivityIndicator = true
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            if granted {
                    // Fetch all contacts
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey,CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                DispatchQueue.global(qos: .background).async {
                    do {

                        var localContacts:[CNContact] = []
                        try store.enumerateContacts(with: request) { contact, _ in
                            localContacts.append(contact)
                        }
                        let phoneNumbers = Set(localContacts.compactMap{
                            $0.phoneNumbers
                                .first?
                                .value
                                .stringValue
                                .replacingOccurrences(of: "-", with: "")
                                .replacingOccurrences(of: "(", with: "")
                                .replacingOccurrences(of: ")", with: "")
                                .replacingOccurrences(of: " ", with: "")
                        })
                        self.syncingContacts(contact: Array(phoneNumbers), complete: { users in
                            self.users = users
                        })

                    } catch {
                        self.showActivityIndicator = false
                        self.validationText = "Error fetching contacts: \(error.localizedDescription)"
                        print("Error fetching contacts: \(error.localizedDescription)")
                    }
                }
            } else {
                self.showActivityIndicator = false
                self.validationText = "Access to contacts not granted"
                print("Access to contacts not granted")
            }
        }
    }
    
    func blockChat(chatId: String) {
        self.showActivityIndicator = true
        apiService.postRequest(endPoint: "/chats/block/\(chatId)", params: [:]) {
            (result:Result<Blocker,Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let respo):
                    self.selectedChat?.blocker = respo.blocker
                case .failure(let error):
                    if let message = (error as? ErrorResponse)?.message {
                        self.validationText = "Error fetching contacts: \(message)"
                    }
                }
                self.showActivityIndicator = false
            }
        }
    }
}


