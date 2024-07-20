//
//  FeedViewModel.swift
//  lgcy
//
//  Created by Adnan Majeed on 16/02/2024.
//

import Foundation
import SwiftUI
import Contacts
class FeedViewModel:BaseViewModel {
    @Published var posts:[FeedPostResponse] = []
    var currentPage = 0
    private var totalPages = 1
    private var pageOffSet = 4
    var profileId:String?
    var timelineId:String?
    @Published var isUserPorfileSelected:Bool = false
    @Published var users:[User] = []
    @Published var postComments: [GetCommentResponse] = []
    @Published var unreadCounts: Int = 0

    func fetchPosts(isRefreshFromPullToRefresh: Bool = false) {
        if isRefreshFromPullToRefresh {
            totalPages = 1
            posts.removeAll()
        }
        guard currentPage <= totalPages else {return}
        ApiManager.shared.getRequest(endPoint: "/posts/home", params: ["page":"\(currentPage)","populate":"share,likes","sortBy":"createdAt:desc,"]) {
            (result:Result<ApiBasePaginationResponse<[FeedPostResponse]>,Error>) in
            DispatchQueue.main.async{
                switch result {
                case .success(let respo):
                    self.posts.append(contentsOf: respo.results)
                    self.posts = self.removeDuplicates(from: self.posts)
                    self.totalPages = respo.totalPages
                case .failure(let error):
                    if let message = (error as? ErrorResponse)?.message {
                        self.validationText = message
                    }
                    
                }
            }
        }
    }
    
    private func removeDuplicates(from posts: [FeedPostResponse]) -> [FeedPostResponse] {
        var uniquePosts = [FeedPostResponse]()
        var seenIds = Set<String>()
        
        for post in posts {
            if !seenIds.contains(post.id) {
                uniquePosts.append(post)
                seenIds.insert(post.id)
            }
        }
        
        return uniquePosts
    }

    func fetchPostDetails(postId:String) {
        showActivityIndicator = true
        ApiManager.shared.getRequest(endPoint: "/posts/\(postId)", params: [:]) {
            (result:Result<PostDetailsResponse,Error>) in
            DispatchQueue.main.async{
                switch result {
                case .success(let respo):
                    print(respo)
                    self.posts.insert(
                        FeedPostResponse(
                            share: Share(
                                users: respo.share.users,
                                timelines: respo.share.timelines
                            ),
                            likes: respo.likes ?? [],
                            liking: respo.liking,
                            commenting: respo.commenting,
                            twitter: respo.twitter,
                            files: respo.files,
                            location: respo.location,
                            description: respo.description,
                            scheduleDate: respo.scheduleDate,
                            creator: respo.creator,
                            createdAt: respo.createdAt,
                            id: respo.id
                        ), at: 0
                    )
                    
                case .failure(let error):
                    if let message = (error as? ErrorResponse)?.message {
                        self.validationText = message
                    }
                }
                self.showActivityIndicator = false
            }
        }
    }

    func shouldLoadData(id: String) -> Bool {
        let lastIndex = posts.count - pageOffSet
        if posts.isEmpty || lastIndex <= 0 {
            return true
        }
        return id == posts[lastIndex].id
    }
    
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
    
    func fetchUnreadCounts () {
        apiService.getRequest(endPoint: "/notifications/unreadCounts", params: [:]) { (result:Result<Int,Error>) in
            DispatchQueue.main.async{ [self] in
                switch result {
                case .success(let count):
                    unreadCounts = count
                    break;
                case .failure(_):
                    break;
                }
            }
        }
    }

}
