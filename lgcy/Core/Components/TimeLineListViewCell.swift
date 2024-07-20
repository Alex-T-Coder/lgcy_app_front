//
//  TimeLineListViewCell.swift
//  lgcy
//
//  Created by Adnan Majeed on 21/02/2024.
//

import SwiftUI

struct TimeLineListViewCell: View {
    var timeLine:TimeLineListModel
    @State private var isFollowing:Bool = false
    @State private var isInFollowing: Bool = false
    @State private var isShowingTimeline: Bool = false
    @ObservedObject var viewModel:TimeLineSearchViewModel = TimeLineSearchViewModel()
    
    init(timeLine: TimeLineListModel,viewModel:TimeLineSearchViewModel) {
        self.timeLine = timeLine
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack {
            CircularProfileImageView(imagePath: timeLine.coverImage?.url ?? "",height: 40, width: 40)
            VStack(alignment: .leading) {
                Text("\(timeLine.title)")
                    .fontWeight(.semibold)
                    .onTapGesture {
                        isShowingTimeline = true
                    }
                    .fullScreenCover(isPresented: $isShowingTimeline) {
                        PublicTimelineView(timelineId: timeLine.id, onDismiss: { following in
                            isFollowing = following
                        })
                    }

                Text("\(timeLine.creator.username ?? "")")
            }
            .font(.footnote)

            Spacer()
            if timeLine.creator.id != UserDefaultsManager.shared.loginUser!.id {
                if isInFollowing == false {
                    Text(isFollowing ? "Following" : "Follow")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(width: 100, height:32)
                        .foregroundColor(.black)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                                .frame(width: isFollowing ? 100 : 100, height: 32)
                        }
                        .onTapGesture {
                            isInFollowing = true
                            viewModel.followTimeLine(timeLineID: timeLine.id,isFollowing:isFollowing, completion: { success in
                                isFollowing.toggle()
                                isInFollowing = false
                            })
                        }
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(width: 100, height:32)
                        .foregroundColor(.black)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                                .frame(width: isFollowing ? 100 : 100, height: 32)
                        }
                }
            }
        }
        .padding(.horizontal)
        .onAppear {
            isFollowing = timeLine.followers.contains(where: {$0.id == UserDefaultsManager.shared.loginUser!.id})
        }

    }
}
