//
//  SharesView.swift
//  lgcy
//
//  Created by Himanshu Joshi on 07/06/24.
//

import SwiftUI

struct SharesView: View {
    @ObservedObject var viewModel: FeedViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.users, id: \.id) { user in
                        VStack {
                            HStack {
                                CircularProfileImageView(imagePath: user.image?.url)
                                Text("\(user.name ?? "")")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .onTapGesture {
                                        
                                    }
                                
                                Spacer()
                            }
                            .padding(.leading, 30)
                            .padding(.vertical, 3)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                
                            }
                        }
                        Divider()
                            .padding(.leading, 25)
                    }
                }
            }
            .navigationTitle("Share")
            .navigationBarTitleDisplayMode(.inline)
            .padding(.top)
            
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
                            Text("Share")
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

#Preview {
    SharesView(viewModel: FeedViewModel())
}
