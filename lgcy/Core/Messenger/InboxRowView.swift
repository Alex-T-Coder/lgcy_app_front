//
//  InboxRowView.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI

struct InboxRowView: View {
   @Binding var chat:ChatListResponse
    @State var isSeen: Bool
    var body: some View {
        HStack(alignment: .center) {
            CircularProfileImageView(imagePath: chat.otherUser.image?.url ?? "")
            VStack(alignment: .leading, spacing: 2) {
                Text("\(chat.otherUser.username ?? "")")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                if let lastMessage = chat.messages.last {
                    let fileName = lastMessage.file?.real
                    Text("\(lastMessage.text.isEmpty ? (fileName ?? "") : lastMessage.text)")
                        .font(.caption2)
                        .fontWeight( isSeen ? .regular : .semibold)
                        .onAppear{
                            print(lastMessage)
                        }
                }
            }
            Spacer()
            HStack {
                if let lastMessage = chat.messages.last {
                    Text("\(lastMessage.createdAt.agoFormatString)")
                } else {
                    Text("\(chat.createdAt.agoFormatString)")
                }

            }
            .font(.footnote)
            .foregroundColor(.gray)
            
        }
        .frame(height: 40)
    }
}

struct InboxRowView_Previews: PreviewProvider {
    static var previews: some View {
        InboxRowView(chat:Binding<ChatListResponse>.constant(ChatListResponse(messages: [], receiver: Creator(id: "", name: "", description: "", image: nil, username: ""), sender: Creator(id: "", name: "", description: "", image: nil, username: ""), createdAt: "", id: "", blocker: "")), isSeen: false)
    }
}
