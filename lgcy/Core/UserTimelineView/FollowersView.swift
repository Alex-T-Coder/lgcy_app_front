//
//  FollowersView.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI

struct FollowersView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    ForEach(0 ... 10, id: \.self) { user in
                        VStack {
//                            UserCell(user: User.getFakeUser(), followUser: { success in })

                            Divider()
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .padding(.top, 16)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                        .onTapGesture {
                            dismiss()
                        }
                }
                
                ToolbarItem(placement: .principal) {
                    Group {
                        VStack {
                            Spacer()
                            Text("Followers")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(10)
                    }
                }
            }
        }
    }
}

struct FollowersView_Previews: PreviewProvider {
    static var previews: some View {
        FollowersView()
    }
}
