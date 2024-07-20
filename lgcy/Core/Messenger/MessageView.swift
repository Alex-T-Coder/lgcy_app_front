//
//  MessageView.swift
//  lgcy
//
//  Created by Adnan Majeed on 01/03/2024.
//

import Foundation
import SwiftUI
import NukeUI
import AVKit
struct MessageView: View {
    var message: Message
    @State var onFileShowed: () -> Void
    @State private var isLoaded: Bool = false
    var body: some View {
        HStack{
            if !message.isSentByUser {
                CircularProfileImageView(imagePath: message.sender.image?.url,height: 30,width: 30)
            }
            VStack {
                if let file = message.data {
                    HStack {
                        if message.isSentByUser {
                            Spacer()
                        }
                        ZStack {
                            Image(uiImage: file)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .scaledToFill()
                                .frame(width: 250)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white)) // Customize the color if needed
                                .scaleEffect(2)
                        }
                        if !message.isSentByUser {
                            Spacer()
                        }
                    }
                    .padding(.top, 12)
                }
                if let url = message.file?.url {
                    HStack {
                        if message.isSentByUser {
                            Spacer()
                        }
                        if let file = message.file {
                            if file.isVideo {
                                if let urlString = file.url, let videoURL = URL(string: urlString) {
                                    let avPlayer = AVPlayer(url: videoURL)
                                    VideoPlayer(player: avPlayer)
                                        .aspectRatio(contentMode: .fit)
                                        .scaledToFill()
                                        .frame(width: 250)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            } else {
                                LazyImage(url: URL(string: url)) { state in
                                    if let image = state.image {
                                        image.resizable()
                                            .onAppear {
                                                if !isLoaded {
                                                    onFileShowed()
                                                    isLoaded = true
                                                }
                                            }
                                    } else if state.error != nil  {
                                        Image("Cordus")
                                            .resizable()
                                    } else {
                                        ProgressView()
                                    }
                                }
                                .aspectRatio(contentMode: .fit)
                                .scaledToFill()
                                .frame(width: 250)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        if !message.isSentByUser {
                            Spacer()
                        }
                    }
                    .padding(.top, 12)
                }
                if !message.text.isEmpty {
                    HStack {
                        if message.isSentByUser {
                            Spacer()
                        }
                        Text(message.text)
                            .font(.subheadline)
                            .padding(10)
                            .background(message.isSentByUser ? Color.black : Color.gray.opacity(0.4))
                            .foregroundColor(message.isSentByUser ? .white: .black)
                            .clipShape(RoundedCorner(radius: 10, corners: message.isSentByUser ? [.topLeft, .bottomLeft, .topRight] : [.topLeft, .topRight, .bottomRight]))
                        
                        if !message.isSentByUser {
                            Spacer()
                        }
                    }
                    .padding(.top, 12)
                }
                HStack {
                    if message.isSentByUser {
                        Spacer()
                    }
                    Text(formatDateString(dateString: message.createdAt))
                        .font(.footnote)
                        .foregroundColor(.gray)
                    if !message.isSentByUser {
                        Spacer()
                    }
                }
            }
        }
        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
    }
    
    func formatDateString(dateString: String) -> String {
        let inputFormatter = ISO8601DateFormatter()
        inputFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = inputFormatter.date(from: dateString) else {
            return "Now"
        }
        
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "h:mm a"
            return outputFormatter.string(from: date)
        } else {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "MMM dd, yyyy"
            return outputFormatter.string(from: date)
        }
    }
}

