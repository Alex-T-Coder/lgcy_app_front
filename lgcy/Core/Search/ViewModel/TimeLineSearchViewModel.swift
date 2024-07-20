//
//  TimeLineSearchViewModel.swift
//  lgcy
//
//  Created by Adnan Majeed on 21/02/2024.
//

import Foundation
class TimeLineSearchViewModel:BaseViewModel {
    @Published var timeLines:[TimeLineListModel] = []
    @Published var users: [User] = []
    var currentPage = 0
    private var totalPages = 1
    private var pageOffSet = 4
    func getUserTimeLine() {
        currentPage += 1
        guard currentPage <= totalPages else {return}
        self.showActivityIndicator = true
        apiService.getRequest(endPoint: "/timelines/", params: ["page":"\(currentPage)"], completionHandler: { (result:Result<SearchResult,Error>) in
            DispatchQueue.main.async {
                self.showActivityIndicator = false
                switch result{
                case .success(let searchResult):
                    self.timeLines.append(contentsOf: searchResult.timelines.results)
                    self.users.append(contentsOf: searchResult.users.results)
                    self.totalPages = searchResult.timelines.totalPages
                    self.users = self.removeUserDuplicates(from: self.users)
                    self.timeLines = self.removeDuplicates(from: self.timeLines)
                case .failure(let error):
                    if let message = (error as? ErrorResponse)?.message {
                        self.validationText = message
                    }
                }
            }
        })
    }
    
    func performSearch(with searchText: String) {
        currentPage = 0
        totalPages = 1
        self.showActivityIndicator = true
        
        apiService.getRequest(endPoint: "/timelines/", params: ["search": searchText, "page": "\(currentPage + 1)"], completionHandler: { (result: Result<SearchResult, Error>) in
            DispatchQueue.main.async {
                self.showActivityIndicator = false
                switch result {
                case .success(let searchResult):
                    if self.currentPage == 0 {
                        self.timeLines = searchResult.timelines.results
                        self.users = searchResult.users.results
                    } else {
                        self.timeLines.append(contentsOf: searchResult.timelines.results)
                        self.users.append(contentsOf: searchResult.users.results)
                    }
                    self.timeLines = self.removeDuplicates(from: self.timeLines)
                    self.users = self.removeUserDuplicates(from: self.users)
                    self.totalPages = searchResult.timelines.totalPages
                case .failure(let error):
                    if let message = (error as? ErrorResponse)?.message {
                        print(message)
                    }
                }
            }
        })
    }

    private func removeDuplicates(from timeLines: [TimeLineListModel]) -> [TimeLineListModel] {
        var uniqueTimeLines = [TimeLineListModel]()
        var seenIds = Set<String>()
        
        for timeLine in timeLines {
            if !seenIds.contains(timeLine.id) {
                uniqueTimeLines.append(timeLine)
                seenIds.insert(timeLine.id)
            }
        }
        
        return uniqueTimeLines
    }
    
    private func removeUserDuplicates(from users: [User]) -> [User] {
        var uniqueUsers = [User]()
        var seenIds = Set<String>()
        
        for user in users {
            if !seenIds.contains(user.id) {
                uniqueUsers.append(user)
                seenIds.insert(user.id)
            }
        }
        
        return uniqueUsers
    }
    
    func shouldLoadData(id: String) -> Bool {
        let lastIndex = timeLines.count - pageOffSet
        if timeLines.isEmpty || lastIndex <= 0 {
            return true
        }
        return id == timeLines[lastIndex].id
    }

    func followTimeLine(timeLineID:String, isFollowing:Bool, completion: @escaping (Bool) -> ()) {
        self.showActivityIndicator = true
        apiService.postRequest(endPoint: "/timelines/\(timeLineID)/\(isFollowing ? "unfollow" : "follow")", params: [:], completionHandler: { (result:Result<ApiBasePaginationResponse<[TimeLineListModel]>,Error>) in
            DispatchQueue.main.async {
                self.showActivityIndicator = false
                switch result{
                    case .success(let timeLines):
                        self.timeLines = timeLines.results
                        completion(true)
                    case .failure(_):
                        completion(false)
//                        self.validationText = error.localizedDescription //?? "Something went wrong. Please try later"
                }
            }
        })
    }
    
    func followUser(userID:String, isFollowing:Bool, completion: @escaping (Bool) -> ()) {
        self.showActivityIndicator = true
        apiService.postRequest(endPoint: "/users/\(userID)/follower", params: ["isFollowing": isFollowing], completionHandler: { (result:Result<ApiBasePaginationResponse<[User]>,Error>) in
            DispatchQueue.main.async {
                self.showActivityIndicator = false
                switch result{
                    case .success(let users):
                        self.users = users.results
                        completion(true)
                    case .failure(_):
                        completion(false)
                }
            }
        })
    }
    
    func resetSearchResults() {
        self.timeLines = []
        self.currentPage = 0
        self.totalPages = 1
        getUserTimeLine()
    }
}
