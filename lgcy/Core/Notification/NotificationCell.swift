//
//  NotificationCell.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI
import NukeUI

extension String {
    func formatDateWithOneLetter() -> String {
        var formattedString = self
        
        // Define replacements
        let replacements: [String: String] = [
            " week ago": "w",
            " weeks ago": "w",
            " day ago": "d",
            " days ago": "d",
            " hour ago": "h",
            " hours ago": "h",
            " minute ago": "m",
            " minutes ago": "m",
            " second ago": "s",
            " seconds ago": "s"
        ]
        
        // Replace the strings
        for (key, value) in replacements {
            formattedString = formattedString.replacingOccurrences(of: key, with: value)
        }
        
        // Remove the word "ago"
        formattedString = formattedString.replacingOccurrences(of: " ago", with: "")
        
        return formattedString
    }
}


struct NotificationCell: View {
    @Binding var notification:NotificationModel
    @State private var isShowingProfile: Bool = false
    @State private var isShowingDetail: Bool = false
    var body: some View {
        HStack {
            CircularProfileImageView(imagePath: notification.from?.image?.url ?? "",height: 32, width: 32)
//            Text("\(notification.from?.username.count ?? 0) \(notification.getText.count)")
//            if ((notification.from?.username.count ?? 0) + (notification.getText.count ?? 0)) <= 28 {
                HStack(spacing: 0) {
                    Text(notification.from?.username ?? "")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .onTapGesture {
                            isShowingProfile = true
                        }
                        .fullScreenCover(isPresented: $isShowingProfile) {
                            PublicProfileView(profileId: notification.from?.id ?? "")
                        }
                    
                    Text("\(notification.getText) ")
                        .font(.footnote)
                    
                    Text("\(notification.createdAt.agoFormatString.formatDateWithOneLetter())")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                }
//            } else {
//                VStack(alignment: .leading) {
//                    HStack {
//                        Text("")
//                        Spacer()
//                    }
//                    HStack {
//                        Text(notification.from?.username ?? "")
//                            .font(.footnote)
//                            .fontWeight(.semibold)
//                            .onTapGesture {
//                                isShowingProfile = true
//                            }
//                            .fullScreenCover(isPresented: $isShowingProfile) {
//                                PublicProfileView(profileId: notification.from?.id ?? "")
//                            }
//                            .padding(.leading, 4)
//
//                        Text("\(notification.getText) ")
//                            .font(.footnote)
//                    }
//                    
//                    HStack {
//                        Spacer()
//                        Text("\(notification.createdAt.agoFormatString)")
//                            .font(.footnote)
//                            .foregroundStyle(.gray)
//                            .padding(.trailing, 10)
//                    }
//                }
//            }
            
            Spacer()
            let url = notification.getImage
            LazyImage(url: URL(string: url)) { state in
                if let image = state.image {
                    image.resizable()
                }  else {
                    Image("Cordus")
                        .resizable()
                }
            }
            .scaledToFill()
            .frame(width: 45, height: 45)
            .clipShape(RoundedCorner(radius: 8))
            .onTapGesture {
                isShowingDetail = true
            }
            .fullScreenCover(isPresented: $isShowingDetail) {
                    switch  (notification.type) {
                    case .COMMENT, .LIKE, .POST, .LIKECOMMENT:
                        if let post = notification.data.posts.first {
                            PublicTimelinePostView(post: post)
                        }
                    case .TIMELINE:
                        if let timeline = notification.data.timelines.first {
                            PublicTimelineView(timelineId: timeline.id)
                        }
                    case .MSG:
                        if let user = notification.data.users.first {
                            PublicProfileView(profileId: user.id)
                        }
                    }
            }
        }
        .padding(.horizontal)
    }
}
