//
//  CommentsViewCell.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI
import NukeUI

struct CommentsViewCell: View {
    @State private var isHeartFilled = false
    @State private var likesNumber = 0
    @Binding var comment: GetCommentResponse
    @State private var isShowingProfile: Bool = false
    
    var likedComment: ((Bool) -> Void)?
    
    var body: some View {
        HStack(alignment: .top) {
            
            LazyImage(url: URL(string: comment.user.image?.url ?? "")) { state in
                if let image = state.image {
                    image.resizable()
                } else if state.error != nil  {
                    Image("Cordus")
                        .resizable()
                } else {
                    ProgressView()
                }
            }
            .frame(width: 32, height: 32)
            .clipShape(Circle())
            
            VStack(alignment: .leading) {
                HStack {
                    Text(comment.user.username + " ")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .onTapGesture {
                            isShowingProfile = true
                        }
                        .fullScreenCover(isPresented: $isShowingProfile) {
                            PublicProfileView(profileId: comment.user.id)
                        }
                    Text(comment.createdAt.agoFormatString.formatDateWithOneLetter())
                        .font(.footnote)
                        .foregroundStyle(.gray)
                }
                Text(comment.content)
                    .font(.footnote)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 7) {
                Button(action: {
                    isHeartFilled.toggle()
                    if isHeartFilled {
                        likesNumber += 1
                    } else {
                        likesNumber -= 1
                    }
                    likedComment?(isHeartFilled)
                }) {
                    Image(systemName: isHeartFilled ? "heart.fill" : "heart")
                        .font(.subheadline)
                        .foregroundColor(isHeartFilled ? Color.black : Color.primary)
                        .fontWeight(.semibold)
                }
                
                Text("\(likesNumber)")
                    .padding(.trailing, 6)
                    .font(.footnote)
            }
            .onAppear {
                isHeartFilled = (comment.likes ?? []).map{ $0.id }.contains(UserDefaultsManager.shared.loginUser?.id ?? "")
                likesNumber = comment.likes?.count ?? 0
            }
            .frame(width: 35)
        }
        .padding(.horizontal, 5)
    }
}
