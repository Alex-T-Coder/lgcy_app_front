//
//  NewChatView.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI

struct NewChatView: View {
    @State private var searchText = ""
    @State private var searchedUsers: [User] = []
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel:MassengerViewModel = MassengerViewModel()
    @Binding var userId: String
    @Binding var showNewMessageView: Bool
    var body: some View {
        NavigationStack {
            ScrollView {
                TextField("To: ", text: $searchText)
                    .frame(height: 44)
                    .padding(.leading)
                    .background(Color(.systemGroupedBackground))
                    .onChange(of: searchText, {
                        viewModel.syncingContacts(contact: [searchText], complete: { users in
                            searchedUsers = users
                        })
                    })
                ForEach(searchedUsers,id:\.id) { user in
                    VStack {
                        HStack {
                            CircularProfileImageView(imagePath: user.image?.url)
                            Text(user.username)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding(.leading)
                        .onTapGesture {
                            userId = user.id
                            showNewMessageView = false
                            dismiss()
                        }
                        Divider()
                            .padding(.leading, 40)
                    }
                }
                Text("CONTACTS")
                    .foregroundColor(.gray)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                ForEach(viewModel.users,id:\.id) { user in
                    VStack {
                        HStack {
                            CircularProfileImageView(imagePath: user.image?.url)
                            Text(user.username)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding(.leading)
                        .onTapGesture {
                            userId = user.id
                            showNewMessageView = false
                            dismiss()
                        }
                        Divider()
                            .padding(.leading, 40)
                    }
                }
            }
            .navigationTitle("New Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                        
                    }
                    .foregroundColor(.black)
                }
        }
        }.onAppear {
            viewModel.fetchContacts()
        }
    }
}
