//
//  InboxView.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI

struct InboxView: View {
    @State private var showNewMessageView = false
    @State private var showChatTimelineView = false
    @State private var showChatView = false
    @State private var isNewMessage = false
    @Binding var scrollToTop: Bool
    @Binding var selectedTab:Int
    @StateObject var viewModel:MassengerViewModel = MassengerViewModel()
    @EnvironmentObject var mainTabViewModel: MainTabViewModel
    @State var userID: String = ""
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                if !viewModel.chatList.isEmpty{
                    ScrollViewReader { proxy in
                        List($viewModel.chatList,id:\.id) {message in
                            let isSeen = viewModel.getLastReceivedMessage(messages: message.wrappedValue.messages, userID: message.wrappedValue.otherUser.id)?.isSeen ?? true
                            Button {
                                userID = message.wrappedValue.otherUser.id
                                viewModel.selectedChatIndex = viewModel.chatList.firstIndex(where: {$0.id == message.wrappedValue.id }) ?? 0
                                showChatTimelineView = true
                            } label:  {
                                InboxRowView(chat: message, isSeen: isSeen)
                            }.id(message.wrappedValue.id)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(isSeen ? .white : Color(.systemGray6))
                                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                .listRowSeparator(.hidden)
                            
                        }.listStyle(.plain)
                            .frame(height: UIScreen.main.bounds.height - 120)
                            .onChange(of: scrollToTop) {
                                withAnimation {
                                    if let post =  viewModel.chatList.first {
                                        proxy.scrollTo(post.id, anchor: .bottom)
                                        viewModel.getAllChats()
                                    }
                                }
                            }
                    }
                }else{
//                    if !viewModel.showActivityIndicator{
//                        VStack(spacing: 10){
//                            Image(systemName: "message")
//                                .resizable()
//                                .fontWeight(.light)
//                                .frame(width: 70, height: 55)
//                            
//                            Text("No Chats Yet")
//                                .foregroundColor(.black)
//                                .font(.headline)
//                                .fontWeight(.medium)
//                        }
//                    }
                }
                AppActivityIndicator(showActivityIndicator: $viewModel.showActivityIndicator)
            }
            .padding(.top,60)
            .fullScreenCover(isPresented: $showNewMessageView) {
                NewChatView(userId: $userID, showNewMessageView: $showNewMessageView)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
//                        CircularProfileImageView(imagePath: UserDefaultsManager.shared.loginUser?.image?.url)
                            Text("Chats")
                                .font(.title)
                                .fontWeight(.semibold)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        userID = ""
                        showNewMessageView.toggle()
                    } label: {
                        Image(systemName: "square.and.pencil.circle.fill")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundStyle(Color.black, Color(.systemGray5))
                                                }
                }
            }.onAppear{
                viewModel.getAllChats()
                AppManager.isNewMessage.send(false)
            }
            .fullScreenCover(isPresented: $showChatTimelineView) {
                ChatTimelineView(viewModel: PublicProfileViewModel(userId: userID), chatViewModel:viewModel, userID: $userID)
                    .environmentObject(mainTabViewModel)
            }
            .onChange(of: showNewMessageView) {
                if !showNewMessageView && userID != "" {
                    showChatView = true
                }
            }
            .fullScreenCover(isPresented: $showChatView) {
                ChatTimelineView(viewModel: PublicProfileViewModel(userId: userID), chatViewModel:viewModel, userID: $userID)
                    .environmentObject(mainTabViewModel)
            }
        }
        .showToast(toastText: viewModel.validationText, isShowing: $viewModel.validationAlert)
        .onReceive(AppManager.isNewMessage, perform: {
            isNewMessage = $0
            viewModel.getAllChats()
        })
    }
}

struct InboxView_Previews: PreviewProvider {
    static var previews: some View {
        InboxView(scrollToTop: Binding<Bool>.constant(true), selectedTab: Binding<Int>.constant(0))
    }
}
