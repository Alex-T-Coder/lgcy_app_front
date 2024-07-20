//
//  FeedCellModel.swift
//  lgcy
//
//  Created by Evan Boymel on 7/3/24.
//
import Foundation

class FeedCellModel: BaseViewModel {
    func likeUnLikePost(postId:String,status:Bool = true, completion: @escaping (LikePostResponse) -> Void) {
        showActivityIndicator = true
        ApiManager.shared.postRequest(endPoint: "/posts/like-toggle/\(postId)", params: [:]) {
            (result:Result<LikePostResponse,Error>) in
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
    
    func removePost(postId: String, completion: @escaping (Bool) -> Void) {
        showActivityIndicator = true
        ApiManager.shared.deleteRequest(endPoint: "/posts/\(postId)") {(result: Result<Bool?, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    completion(true)
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
