//
//  NotificationViewModel.swift
//  lgcy
//
//  Created by Adnan Majeed on 21/02/2024.
//

import Foundation
class NotificationViewModel:BaseViewModel {
    var currentPage = 0
    private var totalPages = 1
    private var pageOffSet = 4
    @Published var notification:[NotificationModel] = []

    override init() {
        super.init()
        getNotifications()
    }
    
    func shouldLoadData(id: String) -> Bool {
        let lastIndex = notification.count - pageOffSet
        if notification.isEmpty || lastIndex <= 0 {
            return true
        }
        return id == notification[lastIndex].id
    }

    func getNotifications(isRefreshFromPullToRefresh: Bool = false) {
        if isRefreshFromPullToRefresh {
            totalPages = 1
            notification.removeAll()
        }
        guard currentPage <= totalPages else {return}
        showActivityIndicator = true
        apiService.getRequest(endPoint: "/notifications", params: ["page":"\(currentPage)", "sortBy":"createdAt:desc", "limit": "15"], completionHandler: {(result:Result<ApiBasePaginationResponse<[NotificationModel]>,Error>) in
            DispatchQueue.main.async {
                self.showActivityIndicator = false
                switch result{
                case .success(let timeLines):
                    self.notification.append(contentsOf: timeLines.results)
                    self.notification = self.removeDuplicates(from: self.notification)
                    self.totalPages = timeLines.totalPages
                case .failure(let error):
                    if let message = (error as? ErrorResponse)?.message {
                        self.validationText = message
                    }
                }
            }
        })
    }
    
    private func removeDuplicates(from notifications: [NotificationModel]) -> [NotificationModel] {
        var uniqueNotifications = [NotificationModel]()
        var seenIds = Set<String>()
        
        for notification in notifications {
            if !seenIds.contains(notification.id) {
                uniqueNotifications.append(notification)
                seenIds.insert(notification.id)
            }
        }
        
        return uniqueNotifications
    }
    
    func makeReadAll() {
        apiService.postRequest(endPoint: "/notifications/markReadAll", params: [:], completionHandler: {(result:Result<Bool,Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let res):
                    break
                case .failure(_):
                    break
                }
            }
        })
    }
    
    func makeRead(notificationId: String, read: Bool) {
        apiService.postRequest(endPoint: "/notifications/markRead/\(notificationId)", params: ["read": read], completionHandler: {(result:Result<Bool,Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let res):
                    self.getNotifications()
                    break
                case .failure(_):
                    break
                }
            }
        })
    }
}
