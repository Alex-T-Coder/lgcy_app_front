//
//  PublicTimelinePostView.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI
import NukeUI
import AVKit

struct PublicTimelinePostView: View {
    @Environment(\.dismiss) var dismiss
    @State var post: FeedPostResponse

    var body: some View {
        VStack {
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .font(.system(size: 18))
                    }
                    .foregroundColor(.black)

                    Spacer()

                    Text(post.creator.username ?? "")
                        .font(.headline)
                        .fontWeight(.semibold)

                    Spacer()

                }
                .padding()
            }

            Divider()

            FeedCell(post: .constant(post), onRemovePost: { success in
                dismiss()
            })

            Spacer()
        }
    }
}
