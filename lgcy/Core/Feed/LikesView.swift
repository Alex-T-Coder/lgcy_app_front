//
//  LikesView.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI

struct LikesView: View {
    @Environment(\.dismiss) var dismiss
    @State var title: String
    @State var users: [User] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    ForEach(users) { user in
                        VStack {
                            UserCell(user: user, viewModel: TimeLineSearchViewModel())
                            
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
                            Text(title)
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

struct LikesView_Previews: PreviewProvider {
    static var previews: some View {
        LikesView(title: "")
    }
}
