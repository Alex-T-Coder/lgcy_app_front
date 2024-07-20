//
//  MainTabView.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI
import Combine
import SocketIO
final class TabStateManager: ObservableObject {
    @Published var scrollPostTabToTop = false
    @Published var scrollSearchTabToTop = false
    @Published var scrollMessageTabToTop = false
    @Published var scrollProfileTabToTop = false
    @Published var selectedTab: Int = 0
    @Published var prevSelectedTab: Int = 0
    private var cancellable: AnyCancellable?
    
    init() {
        listenForTabSelection()
    }

    deinit {
        cancellable?.cancel()
        cancellable = nil
    }

    private func listenForTabSelection() {
        cancellable = $selectedTab
            .sink { [weak self] newTab in
                guard let self = self else { return }
                if newTab == self.selectedTab {
                    if newTab == 0 {
                        self.scrollPostTabToTop.toggle()
                    } else  if newTab == 1 {
                        self.scrollPostTabToTop.toggle()
                    } else  if newTab == 3 {
                        self.scrollPostTabToTop.toggle()
                    }  else  if newTab == 4 {
                        self.scrollPostTabToTop.toggle()
                    }
                }
            }
    }
}


struct MainTabView: View {
    @State var isNewMessage = false
    @StateObject private var tabStateManager = TabStateManager()
    @StateObject private var viewModel = MainTabViewModel()
    @State private var isSharingPost: Bool = false
    @Binding var selectedTab: Int
    let feedViewModel = FeedViewModel()
    
    init(selectedTab: Binding<Int>) {
        // Customize the tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.systemBackground
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        _selectedTab = selectedTab
    }
    
    var body: some View {
        VStack {
            //            TabView(selection: $tabStateManager.selectedTab) {
            if tabStateManager.selectedTab == 0 {
                FeedView(scrollToTop: $tabStateManager.scrollPostTabToTop,
                         selectedTab: $tabStateManager.selectedTab, viewModel: feedViewModel)
                //                    .tag(0)
            }
            
            if tabStateManager.selectedTab == 1 {
                SearchView(scrollToTop: $tabStateManager.scrollSearchTabToTop,
                           selectedTab: $tabStateManager.selectedTab)
                //                    .tag(1)
            }
            
            if tabStateManager.selectedTab == 2 {
                NewPostView(tabIndex: $tabStateManager.selectedTab, viewModel: UploadPostViewModel(feedsViewModel: feedViewModel))
                //                    .toolbar(.hidden, for: .tabBar)
                    .environmentObject(tabStateManager)
//                    .tag(2)
            }
            
            if tabStateManager.selectedTab == 3 {
                InboxView(scrollToTop: $tabStateManager.scrollMessageTabToTop,
                          selectedTab: $tabStateManager.selectedTab)
                .environmentObject(viewModel)
                //                    .tag(3)
            }
            
            if tabStateManager.selectedTab == 4 {
                UserProfileView(scrollToTop: $tabStateManager.scrollProfileTabToTop,
                                selectedTab: $tabStateManager.selectedTab)
                //                    .tag(4)
            }
            
            if tabStateManager.selectedTab != 2 {
                HStack {
                    Button(action: {
                        tabStateManager.selectedTab = 0
                        feedViewModel.currentPage = 0
                        feedViewModel.fetchPosts(isRefreshFromPullToRefresh: true)
                    }) {
                        Image(systemName: tabStateManager.selectedTab == 0 ? "house.fill" : "house")
                            .resizable()
                            .environment(\.symbolVariants, tabStateManager.selectedTab == 0 ? .fill : .none)
                            .frame(width: 24, height: 24)
                            .foregroundColor(tabStateManager.selectedTab == 0 ? .black : .gray)
                    }
                    Spacer()
                    Button(action: { tabStateManager.selectedTab = 1 }) {
                        Image(systemName: tabStateManager.selectedTab == 1 ? "magnifyingglass" : "magnifyingglass")
                            .resizable()
                            .environment(\.symbolVariants, tabStateManager.selectedTab == 1 ? .fill : .none)
                            .frame(width: 24, height: 24)
                            .foregroundColor(tabStateManager.selectedTab == 1 ? .black : .gray)
                    }
                    Spacer()
                    Button(action: {
                        tabStateManager.prevSelectedTab = tabStateManager.selectedTab
                        tabStateManager.selectedTab = 2
                    }) {
                        Image(systemName: tabStateManager.selectedTab == 2 ? "plus.square" : "plus.square")
                            .resizable()
                            .environment(\.symbolVariants, tabStateManager.selectedTab == 2 ? .none : .none)
                            .frame(width: 24, height: 24)
                            .foregroundColor(tabStateManager.selectedTab == 2 ? .black : .gray)
                    }
                    Spacer()
                    Button(action: { tabStateManager.selectedTab = 3 }) {
                        Image(systemName:  "message")
                            .resizable()
                            .environment(\.symbolVariants, tabStateManager.selectedTab == 3 ? .fill : .none)
                            .frame(width: 24, height: 24)
                            .foregroundColor(tabStateManager.selectedTab == 3 ? .black : .gray)
                    }
                    Spacer()
                    Button(action: { tabStateManager.selectedTab = 4 }) {
                        Image(systemName: tabStateManager.selectedTab == 4 ? "person.fill" : "person")
                            .resizable()
                            .environment(\.symbolVariants, tabStateManager.selectedTab == 4 ? .fill : .none)
                            .frame(width: 24, height: 24)
                            .foregroundColor(tabStateManager.selectedTab == 4 ? .black : .gray)
                    }
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 30)
            }
        }
        .accentColor(.black)
        .onChange(of: selectedTab) { newValue in
            tabStateManager.selectedTab = newValue
        }
        .onAppear {
            tabStateManager.selectedTab = selectedTab
            feedViewModel.fetchUnreadCounts()
        }
        .onReceive(NotificationCenter.default.publisher(for: .didReceiveNotification)) {
            notification in
            if let userInfo = notification.userInfo,
               let type = userInfo["type"] as? NotificationType {
                switch type {
                case .COMMENT, .LIKECOMMENT:
                    tabStateManager.selectedTab = 0;
                    break;
                case .LIKE:
                    tabStateManager.selectedTab = 0;
                    break;
                case .MSG:
                    tabStateManager.selectedTab = 3;
                    break;
                case .POST:
                    tabStateManager.selectedTab = 0;
                    break;
                case .TIMELINE:
                    tabStateManager.selectedTab = 1;
                    break;
                }
                feedViewModel.fetchUnreadCounts()
            }
        }
    }
    
    private func showTabBar() {
        UITabBar.appearance().isHidden = false
    }

    private func hideTabBar() {
        UITabBar.appearance().isHidden = true
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(selectedTab: .constant(0))
        
    }
}

class MainTabViewModel: ObservableObject {
    @Published var socketManager: SocketManager?
    @Published var socket: SocketIOClient?
    
    init() {
        setupSocket()
    }
    
    private func setupSocket() {
        let headers: [String: String] = ["authorization": "Bearer \(UserDefaults.standard.string(forKey: UserDefaultsKeys.access_token.rawValue) ?? "")"]
        socketManager = SocketManager(socketURL: URL(string: Constants.baseURL)!)
        socketManager?.config = SocketIOClientConfiguration(
            arrayLiteral: .compress,
            .extraHeaders(headers),
            .log(true)
        )
        
        socket = socketManager?.socket(forNamespace: "/")
        
        socket?.on(clientEvent: .connect) { data, emitter in
            print("socket connect")
        }
        
        socket?.connect()
    }
}
