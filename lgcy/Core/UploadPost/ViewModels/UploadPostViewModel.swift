//
//  UploadPostViewModel.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import Foundation
import PhotosUI
import SwiftUI
import CoreLocation
import Photos
import Contacts

struct ImageModel:Identifiable, Equatable{
    var id: String
    var image: UIImage? = nil
    var isSelected: Bool = false
    var exten:String = ""
    var memeType:String = ""
    var fileData:Data = Data()
    var assetURL = ""
}
class UploadPostViewModel: BaseViewModel {

    @Published var postImage: Image?
    @Published var selectedLocation: Place?
    @Published var turnOffComments = false
    @Published var turnOffLikes = false
    @Published var caption = ""
    @Published var filePathSelected = ""
    @Published var selectedDate = Date()
    @Published var locationText: String = ""
    @Published var timelines: [TimelineDTO] = []
    @Published var tabIndex:Int = 0
    @Published var arrImage: [ImageModel] = []
    @Published var selectedImages: [ImageModel] = []
    @Published var selectedImage = UIImage()
    @Published var selectedImageFromCamera: Bool = false
    @Published var isPostCreated = false
    @Published var isPostCreatedFromFeedView = false
    @Published var moveToNextAvailable = false
    @ObservedObject var feedViewModel: FeedViewModel
    @Published var users:[User] = []
    
    func syncingContacts(contact:[String]) {
        
        apiService.postRequest(endPoint: "/chats/getAllUserWithPhone/", params: ["phoneNumbers":contact],isMultiPart: false)
        { (result:Result<[User],Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let respo):
                    self.users = respo
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
                        self.syncingContacts(contact: Array(phoneNumbers))
                        
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

    init(feedsViewModel: FeedViewModel) {
        self.feedViewModel = feedsViewModel
        super.init()
        self.getUserTimeLine()
        self.fetchContacts()
    }

    func getUserTimeLine() {
        self.showActivityIndicator = true
        apiService.getRequest(endPoint: "/timelines/ByCreator", params: [:], completionHandler: { (result:Result<ApiBasePaginationResponse<[TimelineDTO]>,Error>) in
            DispatchQueue.main.async {
                self.showActivityIndicator = false
                switch result{
                case .success(let timeLines):
                    self.timelines = timeLines.results
                case .failure(let error):
                    if let message = (error as? ErrorResponse)?.message {
                        self.validationText = message
                    }
                }
            }
        })
    }

    func sharePost(params:[String:Any], completion: @escaping (Bool) -> Void) {

        self.showActivityIndicator = true
        var files = [FileModel]()
        self.selectedImages.enumerated().forEach{index,img in
            let fileName = "\(Int64(Date().timeIntervalSince1970.rounded())).\(img.exten)"
            files.append(
                FileModel(fileName: fileName, fileData: img.fileData, fileMemeType: img.memeType, fildName: "myFiles"))}
        files.swapAt(0, files.count - 1)
        apiService.postRequest(endPoint:  "/posts", params: params,files:files,isMultiPart: true, completionHandler: {
            (result:Result<PostDTO,Error>) in
            DispatchQueue.main.async {
                self.showActivityIndicator = false
                switch result{
                case .success(let timeLines):
                    self.isPostCreated = true
                    self.feedViewModel.fetchPostDetails(postId: timeLines.id)
                    self.turnOffLikes = false
                    self.turnOffComments = false
                    completion(true)
                case .failure(let error):
                    if let message = (error as? ErrorResponse)?.message {
                        if message.contains("\"location\" is not allowed to be empty") {
                            self.validationText = "Please enter location to share the feed."
                        } else {
                            self.validationText = message
                        }
                    }
                    completion(false)
                }
            }
        })

    }
    
    func sharePostFromFeedView(files: [FileModel], params:[String:Any]) {

        self.showActivityIndicator = true
        apiService.postRequest(endPoint:  "/posts", params: params,files:files,isMultiPart: true, completionHandler: {
            (result:Result<PostDTO,Error>) in
            DispatchQueue.main.async {
                self.showActivityIndicator = false
                switch result{
                case .success(_):
                    self.isPostCreatedFromFeedView = true
                case .failure(let error):
                    if let message = (error as? ErrorResponse)?.message {
                        self.validationText = message
                    }
                    self.isPostCreatedFromFeedView = true
                }
            }
        })

    }
}
//cartervincent684@gmail.com
//cartervincent684
