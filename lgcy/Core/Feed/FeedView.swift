//
//  FeedView.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI

struct FeedView: View {
    @State private var isNotificationsViewPresented = false
    @State private var badgeCount = 0
    @State private var isBottomReached = false
    @Binding var scrollToTop: Bool
    @Binding var selectedTab:Int
    @StateObject var viewModel: FeedViewModel
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                ScrollViewReader { proxy in
                    List {
                        ForEach($viewModel.posts) { post in
                            FeedCell(isInFeed: true, post: post, onRemovePost: { success in }).id(post.id)
                                .onAppear {
                                    if viewModel.shouldLoadData(id: post.id) {
                                        viewModel.currentPage += 1
                                        viewModel.fetchPosts()
                                    }
                                }
                                .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                                .listRowSpacing(10)
                                .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .listRowSpacing(10)
                    .onChange(of: scrollToTop) {
                        withAnimation {
                            if let post = viewModel.posts.first {
                                proxy.scrollTo(post.id, anchor: .bottom)
                            }
                        }
                    }
                    .refreshable {
                        viewModel.currentPage = 0
                        viewModel.fetchPosts(isRefreshFromPullToRefresh: true)
                    }
                    GeometryReader { geometry in
                        Color.clear.onAppear {
                            viewModel.currentPage += 1
                            viewModel.fetchPosts()
                        }
                    }
                    .frame(height: 1)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Image("lgcytrans")
                            .resizable()
                            .frame(width: 75, height: 40)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            isNotificationsViewPresented.toggle()
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: viewModel.unreadCounts > 0 ? "bell.fill" :  "bell")
                                    .imageScale(.large)
                                    .foregroundColor(.black)
                                    .fontWeight(.semibold)
                                    .badge(30)
                                if $viewModel.unreadCounts.wrappedValue > 0{
                                    Text("\(viewModel.unreadCounts)")
                                        .font(.system(size: 10))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(4)
                                        .background(Circle().fill(Color(hex: "#E81B23")))
                                        .offset(x: 0, y: -10)
                                }
                            }
                        }
                        .fullScreenCover(isPresented: $isNotificationsViewPresented) {
                            NotificationsView(scrollToTop: Binding<Bool>.constant(true))
                                .onDisappear {
                                    viewModel.fetchUnreadCounts()
                                }
                        }
                    }
                }
                .onAppear {
                    viewModel.fetchPosts()
                    viewModel.fetchContacts()
                }
                AppActivityIndicator(showActivityIndicator: $viewModel.showActivityIndicator)
            }
        }
        .showToast(toastText: viewModel.validationText, isShowing: $viewModel.validationAlert)
        .accentColor(selectedTab == 0 ? .black : .gray)
    }
}
    struct FeedView_Previews: PreviewProvider {
        static var previews: some View {
            FeedView(scrollToTop: Binding<Bool>.constant(true), selectedTab: Binding<Int>.constant(0), viewModel: FeedViewModel())
    }
}
