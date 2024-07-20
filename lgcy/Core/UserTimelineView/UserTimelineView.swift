//
//  UserTimelineView.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI
import NukeUI

struct UserTimelineView: View {
    @Environment(\.dismiss) var dismiss
    @State var timeline: TimelineDTO
    @State var username: String
    @ObservedObject var viewModel: UserProfileViewModel
    let deletedTimeline: () -> Void

    private let gridItems: [GridItem] = [
        .init(.flexible(), spacing: 3),
        .init(.flexible(), spacing: 3),
        .init(.flexible(), spacing: 3)
    ]
    
    var body: some View {
        NavigationStack {
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

                        if viewModel.selectedTimeline?.status.followerShown ?? false == true {
                            HStack(spacing: 8) {
                                NavigationLink {
                                    LikesView(title: "Followers", users: viewModel.selectedTimeline?.followers ?? [])
                                        .navigationBarBackButtonHidden()
                                } label: {
                                    UserStatView(value: viewModel.selectedTimeline?.followers.count ?? 0, title: "Followers")
                                }


                                Spacer()
                            }
                            .foregroundColor(.black)
                        }
                    }
                    .padding(.horizontal)

                        // name and bio

                    VStack(alignment: .leading, spacing: 4) {

                        Text(viewModel.selectedTimeline?.title ?? "")
                            .font(.footnote)
                            .fontWeight(.semibold)

                        Text(viewModel.selectedTimeline?.description ?? "")
                            .font(.footnote)

                        Text(viewModel.selectedTimeline?.link ?? "")
                            .font(.footnote)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                        // action button
                    NavigationLink {
                        EditTimelineView(
                            timeline: timeline,
                            viewModel: viewModel,
                            deletedTimeline: {
                                deletedTimeline()
                            }
                        )
                        .navigationBarBackButtonHidden()
                    } label: {
                        Text("Edit Timeline")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(width: 360, height: 32)
                            .foregroundColor(.black)
                            .overlay(RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray, lineWidth: 1))
                    }

                    Divider()
                }
                    // post grid view
                LazyVGrid(columns: gridItems, spacing: 1) {
                    ForEach(viewModel.posts) { post in
                        NavigationLink {
                            UserTimelinePostView(post: post)
                                .navigationBarBackButtonHidden()
                        } label:{
                            if let firstFile = post.files?.first {
                                Group {
                                    if !firstFile.isVideo {
                                        LazyImage(url: URL(string: post.files?.first?.url ?? "")) { state in
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
//                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 10)
                            }
                        }
                    }
                }

            }
            .scrollIndicators(.hidden)
            .padding(.top, 20)
            .navigationTitle(username)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: HStack {
                Image(systemName: "chevron.left")
                    .foregroundColor(.black)
                    .font(.system(size: 15))
                    .padding(.leading, 1)
                    .onTapGesture {
                        dismiss()
                    }
            })
            .onAppear {
                viewModel.posts = []
                viewModel.getTimeLinePosts(timelineId: timeline.id)
            }
        }
    }
}

struct UserTimelinePreviewContainer : View {
    @State var timelineImage: Image = Image("Cordus")
    @State var username = "test.username"
    @State var timeline: TimelineDTO = TimelineDTO(
        id: "65ba35d75c4448003aa4f733",
        title: "preview test title",
        description: "preview test desc",
        link: "test link", coverImage: ImageDTO(real: "timelineimage", key: "test", url: "testurl"),
        status: TimelineStatus(value: "secret", followerShown: false, inviters: []), 
        creator: Creator(id: "", name: "", description: "", image: nil, username: ""),
        followers: []
    )
    @ObservedObject private var viewModel = UserProfileViewModel()

    @State var timelines: [TimelineDTO] = []
    var body: some View {
        UserTimelineView(
            timeline: timeline,
            username: username,
            viewModel: viewModel,
            deletedTimeline: {}
        )
    }
}

struct UserTimelineView_Previews: PreviewProvider {
    static var previews: some View {
        UserTimelinePreviewContainer()
    }
}
