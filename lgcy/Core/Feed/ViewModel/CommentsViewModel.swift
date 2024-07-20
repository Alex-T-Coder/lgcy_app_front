//
//  CommentsViewModel.swift
//  lgcy
//
//  Created by Evan Boymel on 7/3/24.
//

import Foundation

class CommentsViewModel: BaseViewModel {
    @Published var postComments: [GetCommentResponse] = []
    
    func fetchComments(postId:String) {
        showActivityIndicator = true
        ApiManager.shared.getRequest(endPoint: "/comments/getComments/\(postId)", params: [:]) { (result:Result<[GetCommentResponse],Error>) in
            DispatchQueue.main.async{
                switch result {
                case .success(let respo):
                    self.postComments = respo
                case .failure(let error):
                    if let message = (error as? ErrorResponse)?.message {
                        self.validationText = message
                    }
                }
                self.showActivityIndicator = false
            }
        }
    }
    
    func addedCommentToPost(postId: String, message: String) {
        showActivityIndicator = true
        ApiManager.shared.postRequest(endPoint: "/comments/addComment/\(postId)", params: ["content": message]) {
            (result:Result<CommentResponse,Error>) in
            DispatchQueue.main.async{
                switch result {
                case .success(let respo):
                    print(respo)
                case .failure(let error):
                    if let message = (error as? ErrorResponse)?.message {
                        self.validationText = message
                    }
                }
                self.showActivityIndicator = false
                self.fetchComments(postId: postId)
            }
        }
    }

    func likeUnLikeComment(commentId:String,status:Bool = true, completion: @escaping (LikeCommentResponse) -> Void) {
        showActivityIndicator = true
        ApiManager.shared.postRequest(endPoint: "/comments/like-toggle/\(commentId)", params: [:]) {
            (result:Result<LikeCommentResponse,Error>) in
            DispatchQueue.main.async{
                switch result {
                case .success(let respo):
                    completion(respo)
                case .failure(let error):
                    if let message = (error as? ErrorResponse)?.message {
                        self.validationText = message
                    }
                }
                self.showActivityIndicator = false
            }
        }
    }
}
