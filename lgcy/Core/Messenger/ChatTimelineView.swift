//
//  ChatTimelineView.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI
import NukeUI
import PhotosUI
import Photos
import AVFoundation

struct ChatTimelineView: View {
    @Environment(\.dismiss) var dismiss
    @State var isPublicTimelineViewPresented = false
    @State var isShowingMedioPicker = false
    @StateObject var viewModel: PublicProfileViewModel
    @StateObject var chatViewModel: MassengerViewModel
    @State private var selectedTab = 0
    @State private var newMessageText = ""
    @Binding var userID: String
    @EnvironmentObject var mainTabViewModel: MainTabViewModel
    @State var isSocketConfigured = false
    @State private var isShowingTimeline: Bool = false
    @State private var selectedPickerItem: PhotosPickerItem? = nil
    @State private var files: [CreatePostImageModel] = []
    @FocusState private var keyboardVisible: Bool
    @State private var isFileUploading: Bool = false
    @State private var isShowingBlock: Bool = false
    @State private var textFieldHeight: CGFloat = 48

    @Namespace var namespace
    private let gridItems: [GridItem] = [
        .init(.flexible(), spacing: 1),
        .init(.flexible(), spacing: 1),
        .init(.flexible(), spacing: 1)
    ]

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                VStack {
                    HStack {
                        Button {
                            chatViewModel.getAllChats()
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                                .font(.system(size: 18))
                        }
                        .foregroundColor(.black)
                        Spacer()
                        HStack {
                            CircularProfileImageView(imagePath: viewModel.user.image?.url ?? "", height: 30, width: 30)
                            
                            Text("\(viewModel.user.username)")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                        }
                        Spacer()
                        Image(systemName: "ellipsis")
                            .foregroundColor(.black)
                            .padding(.horizontal, 15)
                            .frame(width: 50,height: 50)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                isShowingBlock.toggle()
                            }
                            .alert(isPresented: $isShowingBlock) {
                                if chatViewModel.selectedChat?.blocker != nil {
                                    if chatViewModel.selectedChat?.blocker == UserDefaultsManager.shared.loginUser?.id {
                                        Alert(
                                            title: Text("Unblock this user"),
                                            message: Text("After block this user, you can't send or receive the chat only with this user."),
                                            primaryButton: .default(Text("Cancel").foregroundColor(.black)),
                                            secondaryButton: .destructive(Text("Unblock"), action: {
                                                if let id = chatViewModel.selectedChat?.id {
                                                    chatViewModel.blockChat(chatId: id)
                                                }
                                            })
                                        )
                                    } else {
                                        Alert(
                                            title: Text("Block this user"),
                                            message: Text("This chat is blocked by your friend \(viewModel.user.username)"),
                                            primaryButton: .default(Text("Cancel").foregroundColor(.black)),
                                            secondaryButton: .destructive(Text("Ok"), action: {})
                                        )
                                    }
                                } else {
                                    Alert(
                                        title: Text("Block this user"),
                                        message: Text("After block this user, you can't send or receive the chat only with this user."),
                                        primaryButton: .default(Text("Cancel").foregroundColor(.black)),
                                        secondaryButton: .destructive(Text("Block"), action: {
                                            if let id = chatViewModel.selectedChat?.id {
                                                chatViewModel.blockChat(chatId: id)
                                            }
                                        })
                                    )
                                }
                            }
                    }.padding(.horizontal)
                    HStack {
                        Spacer()
                        TabItem(imageName: nil, text: "Messages", index: 0, selectedTab: $selectedTab, namespace: namespace.self )
                        Spacer()
                        TabItem(imageName: "book", text: nil, index: 1, selectedTab: $selectedTab,namespace: namespace.self)
                        Spacer()
                    }
                    if selectedTab == 0 {
                        VStack{
                            List(chatViewModel.selectedChat?.messages ?? [], id: \.id) { message in
                                MessageView(message: message, onFileShowed: {
                                    moveToScrollEnd(proxy: proxy)
                                })
                                    .id(message.id)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets())
                            }
                            .listStyle(PlainListStyle())
                            if chatViewModel.selectedChat?.blocker != nil {
                                Text("This chat is blocked")
                            }
                            if files.count > 0 {
                                ScrollView(.horizontal) {
                                    HStack {
                                        ForEach(files){ file in
                                            if let image = file.image {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .scaledToFill()
                                                    .frame(width: 100, height: 100)
                                                    .clipShape(Rectangle())
                                                    .opacity(0.8)
                                                    .overlay(
                                                        ZStack {
                                                            Button(action: {
                                                                files.removeAll(where: { value in value.id == file.id })
                                                            }) {
                                                                Image(systemName: "xmark.circle.fill")
                                                                    .resizable()
                                                                    .frame(width: 24, height: 24)
                                                                    .foregroundColor(.white)
                                                            }
                                                        }
                                                    )
                                            }
                                        }
                                    }.padding(.horizontal, 10)
                                }
                                .frame(height: 100)
                            }
                            HStack(spacing: 4) {
                                PhotosPicker(selection: $selectedPickerItem, matching: .any(of: [.images, .videos])) {
                                    Image(systemName: "plus")
                                        .resizable()
                                        .frame(width: 12, height: 12)
                                        .padding(12)
                                        .background(Color.gray.opacity(0.2))
                                        .foregroundColor(.black)
                                        .clipShape(Circle())
                                }
                                .padding([.leading, .trailing], 12)
                                .onChange(of: selectedPickerItem) { newItem in
                                    if let newItem {
                                        Task {
                                            if let data = try? await  newItem.loadTransferable(type: Data.self) {
                                                if ((try? await newItem.loadTransferable(type: Image.self)) != nil) {
                                                    if let image = UIImage(data: data) {
                                                        let imageModel = CreatePostImageModel(image: image, type: 0)
                                                        files.append(imageModel)
                                                    }
                                                } else {
                                                    if let url = await saveVideoToTemporaryDirectory(data: data) {
                                                        let image = self.generateThumbnail(url: url)
                                                        let imageModel = CreatePostImageModel(image: image, videoData: data, type: 1)
                                                        files.append(imageModel)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                ZStack(alignment: .bottomTrailing) {
                                    GeometryReader { geometry in
                                        VStack {
                                            TextField("Type a message", text: $newMessageText, axis: .vertical)
                                                .focused($keyboardVisible)
                                                .padding([.leading, .top], 12)
                                                .padding(.trailing, 60)
                                                .background(Color(.systemGroupedBackground))
                                                .font(.subheadline)
                                                .accentColor(.black)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .scrollContentBackground(.hidden)
                                                .background(GeometryReader { geo -> Color in
                                                    DispatchQueue.main.async {
                                                        self.textFieldHeight = max(32, geo.size.height + 12)
                                                    }
                                                    return Color.clear
                                                })
                                            
                                            Spacer()
                                        }
                                    }
                                    
                                    Button {
                                        sendMessage {
                                            moveToScrollEnd(proxy: proxy)
                                        }
                                    } label: {
                                        Text("Send")
                                            .padding(.bottom, 12)
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color.black)
                                    }
                                    .padding(.horizontal)
                                }
                                .frame(height: textFieldHeight)
                                .background(Color(UIColor.systemGroupedBackground))
                                .cornerRadius(16)
                                .padding(.leading, 4)
                                .padding(.trailing, 12)
                            }
                            .disabled(chatViewModel.selectedChat?.blocker != nil)
                            .padding(.top, 8)
                        }
                        .onAppear {
                            chatViewModel.getChatAgainst(userId: userID, name: viewModel.user.name ?? "", desc: viewModel.user.description ?? "", image: viewModel.user.image, username: viewModel.user.username)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation {
                                    if let item = chatViewModel.selectedChat?.messages.last {
                                        proxy.scrollTo(item.id, anchor: .bottom)
                                        if let lastReceivedMessage = chatViewModel.getLastReceivedMessage(messages: chatViewModel.selectedChat?.messages ?? [], userID: userID) {
                                            if lastReceivedMessage.isSeen == false {
                                                chatViewModel.updateMessageToSeen(chatId: chatViewModel.selectedChat?.id ?? "", messageId: lastReceivedMessage.id, completion: { _ in })
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        ScrollView {
                            LazyVGrid(columns: gridItems, spacing: 1) {
                                ForEach(viewModel.posts ?? [],id:\.id) { post in
                                    NavigationLink {
                                        PrivateTimelinePostView(post: post)
                                            .navigationBarBackButtonHidden(true)
                                    } label: {
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
                                                    } else {
                                                        Image("Cordus")
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
                        }.tag(1)
                        .onAppear {
                            viewModel.getPrivatePosts(userId: userID)
                            if !isSocketConfigured {
                                mainTabViewModel.socket?.on("messages", callback: { data, emitter in
                                    print("Got messages \(data)")
                                    if let messageObject = data.first {
                                        do {
                                            let jsonData = try JSONSerialization.data(withJSONObject: messageObject, options: [])
                                            let message = try JSONDecoder().decode(Message.self, from: jsonData)
                                            var newMessageArray = self.chatViewModel.selectedChat
                                            newMessageArray?.messages.append(message)
                                            
                                            self.chatViewModel.selectedChat = newMessageArray
                                            moveToScrollEnd(proxy: proxy)
                                        } catch {
                                            print("Error while serialization of messageObject")
                                        }
                                    }
                                })
                                self.isSocketConfigured = true
                            }
                        }
                    }
                }
                .onDisappear {
                    mainTabViewModel.socket?.off("messages")
                }
            }
        }
    }
    
    func moveToScrollEnd(proxy: ScrollViewProxy) -> Void {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                if let item = chatViewModel.selectedChat?.messages.last {
                    proxy.scrollTo(item.id, anchor: .bottom)
                }
            }
        }
    }
    
    func saveVideoToTemporaryDirectory(data: Data) async -> URL? {
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempURL = tempDirectory.appendingPathComponent("temporaryCreateTineline").appendingPathExtension("mov")
        do {
            try data.write(to: tempURL)
            return tempURL
        } catch {
            print("Error saving video to temporary directory: \(error.localizedDescription)")
            return nil
        }
    }
    
    func generateThumbnail(url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMake(value: 1, timescale: 2)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        } catch {
            print("Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    

    func sendMessage(completion: @escaping () -> ()) {
        if self.files.count > 0 {
            isFileUploading = true
            var files = [FileModel]()
            for createPostImageModel in self.files {
                let data: Data
                var isVideo: Bool = false
                if createPostImageModel.type == 1 {
                    isVideo = true
                    data = createPostImageModel.videoData ?? Data()
                } else {
                    data = createPostImageModel.image?.pngData() ?? Data()
                }
                let img = ImageModel(id: "\(createPostImageModel.id)", image: createPostImageModel.image, memeType: isVideo ? "video/mp4": "image/jpeg", fileData: data)
                
                let fileName = "\(Int64(Date().timeIntervalSince1970.rounded())).\(img.exten)"
                files.append(
                    FileModel(fileName: fileName, fileData: img.fileData, fileMemeType: img.memeType, fildName: "myFiles"))
                
                self.chatViewModel.selectedChat?.messages.append(Message(text: "", createdAt: "\(Date.now)", id: UUID().uuidString, receiver: MessageReceiverType.string(userID), sender: Creator(id: UserDefaultsManager.shared.loginUser?.id ?? "", name: UserDefaultsManager.shared.loginUser?.name ?? "", description: "", image: UserDefaultsManager.shared.loginUser?.image, username: UserDefaultsManager.shared.loginUser?.username ?? ""), file: ImageDTO(), data: createPostImageModel.image, dataType: isVideo ? "video" : "photo"))
            }
            chatViewModel.createPrivatePost(userId: userID, files: files, completion: { res in
                if let files = res?.files {
                    for file in files {
                        let data = ["messages": ["text": "", "sender": UserDefaultsManager.shared.loginUser?.id ?? "", "receiver": userID, "file": ["memeType": file.memeType, "url": file.url, "key": file.key, "real": file.real]], "sender": UserDefaultsManager.shared.loginUser?.id ?? "", "receiver": userID] as [String : Any]
                        isFileUploading = true
                        mainTabViewModel.socket?.emit("createChat", data, completion: {
                            chatViewModel.getChatAgainst(userId: userID, name: viewModel.user.name ?? "", desc: viewModel.user.description ?? "", image: viewModel.user.image, username: viewModel.user.username)
                            newMessageText = ""
                        })
                    }
                }
            })
            
            self.files.removeAll()
        }
        if !newMessageText.isEmpty {
            let data: [String: Any] = [
                "messages": [
                    "text": newMessageText,
                    "sender": UserDefaultsManager.shared.loginUser?.id ?? "",
                    "receiver": userID,
                    "file": nil
                ],
                "sender": UserDefaultsManager.shared.loginUser?.id ?? "",
                "receiver": userID
            ]

            mainTabViewModel.socket?.emit("createChat", data, completion: {
                chatViewModel.getChatAgainst(userId: userID, name: viewModel.user.name ?? "", desc: viewModel.user.description ?? "", image: viewModel.user.image, username: viewModel.user.username)
                    newMessageText = ""
                    completion()
            })
        }

    }
}
