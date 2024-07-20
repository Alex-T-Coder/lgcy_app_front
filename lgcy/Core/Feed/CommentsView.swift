//
//  CommentsView.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI

struct CommentsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var commentView = ""
    @StateObject var viewModel: CommentsViewModel = CommentsViewModel()
    @State var postId: String
    @State private var isFocused = false
    @FocusState private var isTextFieldFocused: Bool
    @State private var textFieldHeight: CGFloat = 48

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 23) {
                    ForEach($viewModel.postComments, id:\.id) { comment in
                        CommentsViewCell(comment: comment, likedComment: {_ in
                            viewModel.likeUnLikeComment(commentId: comment.wrappedValue.id, completion: {_ in 
//                                    viewModel.fetchComments(postId: postId)
                            })
                        })
                    }
                }
            }
            .navigationTitle("Comments")
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
                            Text("Comments")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(10)
                    }
                }
            }
            
            
            ZStack(alignment: .bottomTrailing) {
                GeometryReader { geometry in
                    VStack {
                        TextField("Comment..", text: $commentView, axis: .vertical)
                            .focused($isTextFieldFocused)
                            .padding([.leading, .trailing, .top], 12)
                            .padding(.trailing, 48)
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
                    if !commentView.isEmpty {
                        viewModel.addedCommentToPost(postId: postId, message: commentView)
                        commentView = ""
                    }
                } label: {
                    Text("Send")
                        .padding(.bottom, 12)
                        .fontWeight(.semibold)
                        .foregroundColor(commentView.isEmpty ? Color.gray : Color.black)
                }
                .padding(.horizontal)
                .disabled(commentView.isEmpty)
            }
            .frame(height: textFieldHeight)
            .background(Color(UIColor.systemGroupedBackground))
            .cornerRadius(16)
            .padding()
            .onChange(of: isTextFieldFocused) { newValue in
                if newValue {
                    isFocused = true
                } else {
                    isFocused = false
                }
            }
        }
        .presentationDetents(isFocused ? [.large] : [.medium, .large])
    }
}

struct CommentsView_Previews: PreviewProvider {
    static var previews: some View {
        CommentsView(postId: "")
    }
}
