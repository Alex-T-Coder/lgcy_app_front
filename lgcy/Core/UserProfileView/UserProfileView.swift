//
//  UserProfileView.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI
import NukeUI
struct UserProfileView: View {
    @StateObject private var viewModel:UserProfileViewModel = UserProfileViewModel()
    @Binding var scrollToTop: Bool
    @Binding var selectedTab:Int
    
    private let gridItems : [GridItem] = Array(repeating: .init(.flexible(),spacing: 20), count: 2)
    
    var body: some View {
        let screenWidth = UIScreen.main.bounds.width
        NavigationView {
            ScrollViewReader { proxy in
                ScrollView {
                    //header
                    VStack(spacing: 10){
                        // pic and stats
                        HStack{
                            CircularProfileImageView(imagePath: viewModel.user.image?.url ?? "", height: 80, width: 80)
                            
                            Spacer()
                            
                            Button {
                                viewModel.isCreateTimelineViewPresented.toggle()
                            } label: {
                                Text("Create Timeline")
                                    .font(.subheadline)
                                    .bold()
                                    .frame(width: 135, height: 32)
                                    .foregroundColor(.black)
                                    .overlay(RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray, lineWidth: 0.75))
                            }
                            .padding(.trailing)
                            .fullScreenCover(isPresented: $viewModel.isCreateTimelineViewPresented) {
                                CreateTimelineView(viewModel: viewModel)
                            }
                            
                        }
                        .padding(.horizontal)
                        
                        // name and bio
                        VStack(alignment: .leading, spacing: 4){
                            Text(viewModel.user.name ?? "")
                                .font(.footnote)
                                .fontWeight(.semibold)
                            
                            Text(viewModel.user.description ?? "")
                                .font(.footnote)
                            
                            Text(viewModel.user.link ?? "")
                                .font(.footnote)
                                .fontWeight(.semibold)
                            
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        
                        // action button
                        
                        Button {
                            viewModel.isEditProfileViewPresented.toggle()
                        } label: {
                            Text("Edit Profile")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .frame(width: 360, height: 32)
                                .foregroundColor(.black)
                                .overlay(RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray, lineWidth: 1))
                        }
                        .fullScreenCover(isPresented: $viewModel.isEditProfileViewPresented) {
                            EditProfileView(viewModel: viewModel)
                        }
                        
                        Divider()
                    }
                    .onChange(of: scrollToTop) {
                        withAnimation {
                            if let post =  viewModel.timelines.first {
                                proxy.scrollTo(post.id, anchor: .bottom)
                                viewModel.getUserTimeLine()
                            }
                        }
                    }
                    if !viewModel.timelines.isEmpty {
                        LazyVGrid(columns: gridItems, spacing: 20, content: {
                            ForEach(viewModel.timelines) { timeline in
                                VStack {
                                    Button {
                                        viewModel.selectedTimeline = timeline
                                        viewModel.isUserTimelineViewPresented.toggle()
                                    } label: {
                                        if let url = URL(string: timeline.coverImage?.url ?? "") {
                                            LazyImage(url: url) { state in
                                                if let image = state.image {
                                                    image.resizable()
                                                } else if state.error != nil  {
                                                    Image("Cordus")
                                                        .resizable()
                                                } else {
                                                    ProgressView()
                                                }
                                            }
                                            .scaledToFill()
                                            .frame(width: (UIScreen.main.bounds.width - 40) / 2, height: (UIScreen.main.bounds.width - 40) / 2 - 25)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            .overlay(
                                                Group {
                                                    if timeline.imageType == "video" {
                                                        Image(systemName: "video.fill")
                                                            .resizable()
                                                            .frame(width: 24, height: 16)
                                                            .padding(5)
                                                            .foregroundColor(.white)
                                                    }
                                                },
                                                alignment: .topTrailing
                                            )
                                        } else {
                                            Color.gray
                                                .frame(width: (UIScreen.main.bounds.width - 40) / 2, height: (UIScreen.main.bounds.width - 40) / 2 - 25)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                        }
                                    }
                                    .fullScreenCover(isPresented: $viewModel.isUserTimelineViewPresented) {
                                        UserTimelineView(
                                            timeline: viewModel.selectedTimeline!,
                                            username: viewModel.user.username,
                                            viewModel: viewModel,
                                            deletedTimeline: {
                                                viewModel.isUserTimelineViewPresented = false
                                            }
                                        )
                                    }
                                    VStack {
                                        Spacer()
                                        HStack {
                                            Text(timeline.title)
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .lineLimit(1)
                                            
                                            Spacer()
                                            Button {
                                                viewModel.selectedTimeline = timeline
                                                viewModel.isEditTimelineViewPresented.toggle()
                                            } label: {
                                                Image(systemName: "ellipsis")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.black)
                                                    .padding(1)
                                            }
                                            .fullScreenCover(isPresented: $viewModel.isEditTimelineViewPresented) {
                                                EditTimelineView(
                                                    timeline: viewModel.selectedTimeline!,
                                                    viewModel: viewModel,
                                                    deletedTimeline: {
                                                        viewModel.isEditTimelineViewPresented.toggle()
                                                    }
                                                )
                                            }
                                        }
                                    }
                                }.id(timeline.id)
                            }
                        })
                        .padding(.horizontal,15)
                        Spacer()
                    } else {
//                        VStack(spacing: 10){
//                            Spacer()
//                            Image(systemName: "camera")
//                                .resizable()
//                                .fontWeight(.light)
//                                .frame(width: 70, height: 55)
//                            
//                            Text("No Posts Yet")
//                                .foregroundColor(.black)
//                                .font(.title3)
//                                .fontWeight(.semibold)
//                            
//                            Spacer()
//                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle(viewModel.user.username)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                self.viewModel.getUserTimeLine()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Group {
                        Button {
                            viewModel.isSettingsViewPresented.toggle()
                        } label: {
                            Image(systemName: "line.3.horizontal")
                                .foregroundColor(.black)
                        }
                        .fullScreenCover(isPresented: $viewModel.isSettingsViewPresented) {
                            SettingsView( id: viewModel.user.id, viewModel: SettingsViewModel() )
                        }
                    }
                    
                }
                
            }
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView(scrollToTop: Binding<Bool>.constant(true), selectedTab: Binding<Int>.constant(0))
    }
}
