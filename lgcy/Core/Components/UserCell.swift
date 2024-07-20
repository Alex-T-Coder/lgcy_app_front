//
//  UserCell.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI

struct UserCell: View {
    @State private var isFollowing = false
    @State private var user:User
    @ObservedObject var viewModel:TimeLineSearchViewModel = TimeLineSearchViewModel()
    @State private var isInFollowing = false
    @State private var isShowingProfile = false
    
    init(user: User, viewModel:TimeLineSearchViewModel) {
        self.user = user
        self.viewModel = viewModel
    }

    var body: some View {
        HStack {
            CircularProfileImageView(imagePath: user.image?.url,height: 40, width: 40)
            VStack(alignment: .leading) {
                Text("\(user.name ?? "")")
                    .fontWeight(.semibold)
                    .onTapGesture {
                        isShowingProfile = true
                    }
                    .fullScreenCover(isPresented: $isShowingProfile) {
                        PublicProfileView(profileId: user.id)
                    }
                
                Text("\(user.username)")
            }
            .font(.footnote)
            
            Spacer()

//            if (isInFollowing == false) {
//                Text(isFollowing ? "Following" : "Follow")
//                    .font(.subheadline)
//                    .fontWeight(.semibold)
//                    .frame(width: 100, height:32)
//                    .foregroundColor(.black)
//                    .overlay {
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(Color(.systemGray4), lineWidth: 1)
//                            .frame(width: isFollowing ? 100 : 100, height: 32)
//                    }
//                    .onTapGesture {
//                        isInFollowing = true
//                        Task{
//                            viewModel.followUser(userID: user.id, isFollowing:!isFollowing, completion:{ success in
//                                isFollowing.toggle()
//                                isInFollowing = false
//                            })
//                        }
//                    }
//            } else {
//                ProgressView()
//                    .progressViewStyle(CircularProgressViewStyle())
//                    .scaleEffect(1)
//                    .font(.subheadline)
//                    .fontWeight(.semibold)
//                    .frame(width: 100, height:32)
//                    .foregroundColor(.black)
//                    .overlay {
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(Color(.systemGray4), lineWidth: 1)
//                            .frame(width: isFollowing ? 100 : 100, height: 32)
//                    }
//            }
        }.onAppear {
            isFollowing = user.followers?.contains(where: {$0 == UserDefaultsManager.shared.loginUser!.id}) ?? false
        }
        .padding(.horizontal)
        
    }
}
    
