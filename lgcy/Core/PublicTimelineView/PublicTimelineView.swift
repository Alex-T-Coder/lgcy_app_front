//
//  PublicTimelineView.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI
import AVFoundation
import NukeUI

struct PublicTimelineView: View {
    @Environment(\.dismiss) var dismiss
    @State var timelineId: String = ""
    @State private var isFollowing: Bool = false
    @State var isShowingProfile = false
    @State private var isPublicTimelinePostViewPresented = false
    @ObservedObject private var viewModel:PublicTimelineViewModel
    
    var onDismiss: ((Bool) -> Void)?

    init(timelineId:String, onDismiss: ((Bool) -> Void)? = {follow in}) {
        self.timelineId = timelineId
        self.viewModel =  PublicTimelineViewModel(timeLineId: timelineId)
        self.onDismiss = onDismiss
    }

    private let gridItems: [GridItem] = [
        .init(.flexible(), spacing: 3),
        .init(.flexible(), spacing: 3),
        .init(.flexible(), spacing: 3)
    ]
    
    var body: some View {
        NavigationStack {
            HStack {
                Image(systemName: "chevron.left")
                    .foregroundColor(.black)
                    .font(.system(size: 15))
                    .padding(.leading, 1)
                    .onTapGesture {
                        dismiss()
                        onDismiss?(isFollowing)
                    }
                Spacer()
                Text(viewModel.selectedTimeline?.creator.username ?? "")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 80)
                    .onTapGesture {
                        isShowingProfile = true
                    }
                Spacer()
            }.padding(.horizontal)
                .fullScreenCover(isPresented: $isShowingProfile) {
                    PublicProfileView(profileId: viewModel.selectedTimeline?.creator.id ?? "")
                }
            ZStack(alignment: .top){
                ScrollView {
                        //header

                    VStack(spacing: 20) {

                            // profile pic and stats

                        HStack {
                            if let url = URL(string: viewModel.selectedTimeline?.coverImage?.url ?? "") {
                                LazyImage(url: url) { state in
                                    if let image = state.image {
                                        image.resizable()
                                    } else if state.error != nil  {
                                        Image("Cordus")
                                            .resizable()
                                    } else {
                                        ProgressView()
                                    }
                                }.scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            } else {
                                Color.gray
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            }
                            

                            Spacer()

                            HStack(spacing: 8) {
                                NavigationLink {
                                    LikesView(title: "Followers", users: viewModel.selectedTimeline?.followers ?? [])
                                        .navigationBarBackButtonHidden()

                                } label: {
                                    UserStatView(value: (viewModel.selectedTimeline?.followers.count ?? 0), title: "Followers")
                                }


                                Spacer()
                            }
                            .foregroundColor(.black)
                        }
                        .padding(.horizontal)

                            // name and bio

                        VStack(alignment: .leading, spacing: 4) {

                            Text(viewModel.selectedTimeline?.title ?? "")
                                .font(.footnote)
                                .fontWeight(.semibold)

                            Text("Welcome to my story")
                                .font(.footnote)

                            Text("\(viewModel.selectedTimeline?.description ?? "")")
                                .font(.footnote)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                            // Follow button
                        Button {
                            viewModel.followTimeLine(timeLineID: timelineId, isFollowing: isFollowing, completion: { success in
                                isFollowing.toggle()
                            })
                        } label: {
                            Text(isFollowing ? "Following" : "Follow")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .frame(width: 360, height:32)
                                .foregroundColor(.black)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                        .frame(width:( viewModel.selectedTimeline?.isUserFollower ?? false) ? 360 : 360, height: 32)
                                }
                        }

                        Divider()
                    }

                        // post grid view
                    LazyVGrid(columns: gridItems, spacing: 1) {
                        ForEach(viewModel.posts) { post in
                            NavigationLink {
                                PublicTimelinePostView(post: post)
                                    .navigationBarBackButtonHidden()
                            } label:{
                                if let firstFile = post.files?.first {
                                    Group {
                                        if !firstFile.isVideo {
                                            LazyImage(url: URL(string: firstFile.url ?? "")) { state in
                                                if let image = state.image {
                                                    image.resizable()
                                                }  else {
                                                    Image("Cordus")
                                                        .resizable()
                                                }
                                            }
                                        } else {
                                            if let file = viewModel.postVideoThumbnails[post.id] {
                                                Image(uiImage: file)
                                                    .resizable()
                                            }
                                        }
                                    }
                                    .scaledToFill()
                                    .frame(width: (UIScreen.main.bounds.width) / 3, height: (UIScreen.main.bounds.width) / 3)
                                    .clipShape(RoundedRectangle(cornerRadius: 0))
                                    .overlay(
                                        Group {
                                            if let files = post.files {
                                                if firstFile.isVideo && files.count < 2 {
                                                    Image(systemName: "video.fill")
                                                        .resizable()
                                                        .frame(width: 24, height: 16)
                                                        .padding(5)
                                                        .foregroundColor(.white)
                                                } else {
                                                    if files.count > 1 {
                                                        Image(systemName: "square.fill.on.square.fill")
                                                            .resizable()
                                                            .frame(width: 20, height: 20)
                                                            .padding(8)
                                                            .foregroundColor(.white)
                                                    }
                                                }
                                            }
                                        },
                                        alignment: .topTrailing
                                    )
//                                    .padding(.bottom, 3)
//                                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 10)
                                }
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
                AppActivityIndicator(showActivityIndicator: $viewModel.showActivityIndicator)
            }
            .padding(.top, 20)
            .onAppear {
                viewModel.getTimeLinePosts(timelineId: timelineId)
                viewModel.getTimeLine(timelineId: timelineId, completion: { result in
                    self.isFollowing = result.followers.contains(where: {$0.id == UserDefaultsManager.shared.loginUser!.id})
                })
            }
        }
    }
}

struct PublicTimelineView_Previews: PreviewProvider {
    static var previews: some View {
        PublicTimelineView(timelineId: "65ce5142576876029c460ff4")
    }
}
