//
//  FeedCell.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI
import NukeUI
import AVKit
struct FeedCell: View {
    @State private var isReportPost = false
    @State private var isHeartFilled = false
    @State private var likesNumber = 0
    @State private var isLikesViewPresented = false
    @State private var isCommentsViewPresented = false
    @State private var isShareViewPresented = false
    @State private var isUserProfile = false
    @State private var isUserTimeline = false
    @State private var currentPage = 0
    @State var isPrivate = false
    @State var isInFeed: Bool = false
    @StateObject private var commentsViewModel: CommentsViewModel = CommentsViewModel()
    @StateObject private var viewModel: FeedCellModel = FeedCellModel()
    @Binding var post: FeedPostResponse
    let onRemovePost: ((Bool) -> Void)?
    var body: some View {
        VStack {
            HStack {
                var imageUrl: String {
                    if isPrivate {
                        return post.creator.image?.url ?? ""
                    } else {
                        return post.share.timelines.first?.coverImage?.url ?? ""
                    }
                }
                CircularProfileImageView(imagePath: imageUrl, height: 40, width: 40)
                VStack(alignment: .leading, spacing: 2) {
                    var name: String {
                        if isPrivate {
                            return post.creator.username ?? ""
                        } else {
                            return post.share.timelines.first?.title ?? ""
                        }
                    }
                    Text("\(name)")
                        .font(.headline)
                        .fontWeight(.semibold)
                    if let location = post.location {
                        if location.count > 0 {
                            Text(location)
                                .font(.footnote)
                                .foregroundColor(.black)
                        }
                    }
                }
                Spacer()
                Image(systemName: "ellipsis")
                    .foregroundColor(.black)
                    .padding(.horizontal, 15)
                    .frame(width: 50,height: 50)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isReportPost.toggle()
                    }
                    .alert(isPresented: $isReportPost) {
                        if post.creator.id == UserDefaultsManager.shared.loginUser?.id {
                            Alert(
                                title: Text("Delete Post"),
                                message: Text("Are you sure to delete your post?"),
                                primaryButton: .default(Text("Cancel").foregroundColor(.black)),
                                secondaryButton: .destructive(Text("Delete"), action: {
                                    viewModel.removePost(postId: post.id, completion: { success in
                                        if success {
                                            onRemovePost?(true)
                                        }
                                    })
                                })
                            )
                        } else {
                            Alert(
                                title: Text("Report Post"),
                                message: Text("Your report in anonymous. We will review the post to ensure it follows our Terms & Services."),
                                primaryButton: .default(Text("Cancel").foregroundColor(.black)),
                                secondaryButton: .destructive(Text("Report"), action: {
                                })
                            )
                        }
                    }
            }
            .padding(.horizontal, 8)
            .padding(.top, 10)
            .contentShape(Rectangle())
            .onTapGesture {
                isUserTimeline = true
            }
            if let files = post.files {
                VStack {
                    TabView(selection: $currentPage) {
                        ForEach(files.indices, id: \.self) { index in
                            if !files[index].isVideo {
                                if let urlString = files[index].url, let url = URL(string: urlString) {
                                    LazyImage(url: url) { state in
                                        if let image = state.image {
                                            image.resizable()
//                                                .aspectRatio(contentMode: .fit)
                                        } else if state.error != nil {
                                            Image("Cordus")
                                                .resizable()
//                                                .aspectRatio(contentMode: .fit)
                                        } else {
                                            ProgressView()
                                        }
                                    }
                                    .scaledToFill()
                                    .frame(width: UIScreen.main.bounds.width, height: 400)
                                    .clipped()
                                } else {
                                    Image("Cordus")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: UIScreen.main.bounds.width, height: 400)
                                        .clipped()
                                }
                            } else {
                                if let urlString = files[index].url, let videoURL = URL(string: urlString) {
                                    let avPlayer = AVPlayer(url: videoURL)
                                    VideoPlayer(player: avPlayer)
                                        .frame(width: UIScreen.main.bounds.width, height: 400)
                                        .clipped()
                                        .onAppear {
                                            avPlayer.play()
                                        }
                                } else {
                                    // Handle the case where the video URL is invalid or nil
                                    Text("Invalid video URL")
                                        .frame(width: UIScreen.main.bounds.width, height: 400)
                                }
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(height: 400)
                }
            }
            else if let description = post.description {
                Text(description)
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width, height: 400)
                    .clipShape(Rectangle())
            }
            ZStack(alignment: .top) {
                if let files = post.files {
                    if files.count > 1 {
                        Slider(numberOfPages: files.count, currentPage: $currentPage)
                            .padding(.top, 10)
                    }
                }
                HStack(alignment: .top, spacing: 2) {
                    if post.liking {
                        VStack {
                            Image(systemName: isHeartFilled ? "heart.fill" : "heart")
                                .imageScale(.large)
                                .foregroundColor(isHeartFilled ? Color.black : Color.primary)
                                .frame(height: 20)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    isHeartFilled.toggle()
                                    if isHeartFilled {
                                        likesNumber += 1
                                    } else {
                                        likesNumber -= 1
                                    }
                                    viewModel.likeUnLikePost(postId: post.id, completion: { _ in })
                                }
                            if likesNumber > 0 {
                                Text("\(likesNumber)")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                    .fontWeight(.semibold)
                                    .onTapGesture {
                                        isLikesViewPresented.toggle()
                                    }
                                .fullScreenCover(isPresented: $isLikesViewPresented) {
                                    // Must update likes view
                                    LikesView(title: "Likes", users: post.likes ?? [])
                                }
                            }
                        }
                    }
                    if post.commenting {
                        VStack {
                            Image(systemName: "bubble.right")
                                .imageScale(.large)
                                .padding(.leading, 4)
                                .frame(height: 20)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    isCommentsViewPresented = true
                                }
                            let count = commentsViewModel.postComments.count
                            if count != 0 {
                                Text("\(count)")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                    .fontWeight(.semibold)
                                    .padding(.leading, 4)
                            }
                        }
                    }
                    // Implement Later
                    //                Image(systemName: "paperplane")
                    //                    .imageScale(.medium)
                    //                    .padding(.leading, 4)
                    //                    .frame(width: 24,height: 24)
                    //                    .contentShape(Rectangle())
                    //                    .onTapGesture {
                    //                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    //                            self.isShareViewPresented = true
                    //                        })
                    //                    }
                    Spacer()
                }
                .padding(.top, 8)
            }
            .padding(.leading, 8)
            .foregroundColor(.black)
            .sheet(isPresented: $isCommentsViewPresented) {
                // Must change comments view
                CommentsView(viewModel: commentsViewModel, postId: post.id).onDisappear {
                    commentsViewModel.fetchComments(postId: post.id)
                }
//                    .presentationDetents([PresentationDetent.medium, .large])
            }
//            .sheet(isPresented: $isShareViewPresented) {
                // Implement later
                //                let uploadPostViewModel = UploadPostViewModel(feedsViewModel: feedViewModel)
                //                SharePostView(viewModel: uploadPostViewModel, isFromFeedView: true) { selectedContacts, selectedPublicTimelines in
                //                    uploadPostViewModel.showActivityIndicator = true
                //                    var files = [FileModel]()
                //                    let dispatchGroup = DispatchGroup()
                //                    viewModel.post.files?.enumerated().forEach { index, img in
                //                        if let url = URL(string: img.url) {
                //                            dispatchGroup.enter()
                //                            URLSession.shared.dataTask(with: url) { data, response, error in
                //                                defer {
                //                                    dispatchGroup.leave()
                //                                }
                //                                if let error = error {
                //                                    print("Error fetching data: \(error)")
                //                                    return
                //                                }
                //                                guard let data = data else {
                //                                    print("No data returned")
                //                                    return
                //                                }
                //                                let fileName = "\(Int64(Date().timeIntervalSince1970.rounded())).\(url.pathExtension)"
                //                                let fileMemeType = img.memeType ?? ""
                //                                let fileModel = FileModel(fileName: fileName, fileData: data, fileMemeType: fileMemeType, fildName: "myFiles")
                //                                files.append(fileModel)
                //                            }.resume()
                //                        }
                //                    }
                //                    dispatchGroup.notify(queue: .main) {
                //                        var params:[String:Any] = [
                //                            "location":post.location,
                //                            "description":post.description,
                //                            "scheduleDate":post.scheduleDate,
                //                            "liking":String(post.liking),
                //                            "commenting": String(post.commenting)]
                //                        params["share[users]"] =  selectedContacts
                //                        params["share[timelines]"] =  selectedPublicTimelines
                //                        uploadPostViewModel.sharePostFromFeedView(files: files, params: params)
                //                    }
                //                }
//            }
            // likes label
//            if post.liking && likesNumber > 0 {
//                HStack {
//
//                    .padding(.leading, 8)
//                    //                Text("\(post.share.users.count ) Shares")
//                    //                    .font(.caption2)
//                    //                    .fontWeight(.semibold)
//                    //                    .padding(.leading, 5)
//                    //                    .padding(.top, 0.5)
//                    
//                    Spacer()
//                }
//                .padding(.leading, 9)
//            }
            
            // caption label
            HStack(spacing:5) {
                Text("\(post.creator.username ?? "") ")
                    .fontWeight(.semibold)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isUserProfile = true
                    }
                Text("\(post.description ?? "")")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.footnote)
            .padding(.leading, 10)
            .padding(.top, 1)

            Group {
                if isInFeed {
                    Text ("\(post.scheduleDate?.agoFormatString ?? post.createdAt.agoFormatString)")
                } else {
                    if let scheduleDate = post.scheduleDate {
                        Text(TimeUtility.formatDate(dateString: scheduleDate))
                    } else {
                        Text(TimeUtility.formatDate(dateString: post.createdAt))
                    }
                }
            }
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 10)
                .padding(.top, 1)
                .foregroundColor(.gray)
                .padding(.bottom, 6)

            Divider()
        }
        .fullScreenCover(isPresented: $isUserProfile, content: {
            PublicProfileView(profileId: post.creator.id)
        })
        .fullScreenCover(isPresented: $isUserTimeline, content: {
            if isPrivate {
                PublicProfileView(profileId: post.creator.id)
            } else {
                PublicTimelineView(timelineId: post.share.timelines.first?.id ?? "")
            }
        })
        .onAppear(perform: {
            commentsViewModel.fetchComments(postId: post.id)
            isHeartFilled = (post.likes ?? []).map{ $0.id }.contains(UserDefaultsManager.shared.loginUser?.id ?? "")
            likesNumber = post.likes?.count ?? 0
        })
        .padding(.bottom, -20)
    }
}

struct FeedCell_Previews: PreviewProvider {
    static var previews: some View {
        FeedCell(post: Binding<FeedPostResponse>.constant(FeedPostResponse(share: Share(users: [], timelines: []), likes: [], liking: false, commenting: false, twitter: false, files: [], location: "", description: "Palo", scheduleDate: "Palo",creator: Creator(id: "", name: "", description: "", image: nil, username: ""),createdAt:"",id: "")), onRemovePost: { success in })
    }
}
    
struct Slider: View {
    var numberOfPages: Int
    @Binding var currentPage: Int
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.black : Color(red: 220 / 255, green: 220 / 255, blue: 220 / 255))
                    .frame(width: 6, height: 6)
            }
        }
    }
}
