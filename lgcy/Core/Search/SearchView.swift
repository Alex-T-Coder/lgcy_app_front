//
//  SearchView.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var searchUsers:[User] = []
    @Binding var scrollToTop: Bool
    @Binding var selectedTab:Int
    @StateObject var viewModel:TimeLineSearchViewModel = TimeLineSearchViewModel()
    var body: some View {
        NavigationStack {
            ZStack(alignment:.top) {
                ScrollViewReader { proxy in
                    List {
                        ForEach($viewModel.users) { user in
                            VStack {
                                UserCell(user: user.wrappedValue, viewModel: viewModel)
//                                Divider()
                            }
                            .id(user.id)
                            .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                            .padding(.vertical, 4)
                            .listRowSpacing(10)
                            .listRowSeparator(.hidden)
                        }
                        ForEach($viewModel.timeLines) { timeline in
                            VStack {
                                TimeLineListViewCell(timeLine: timeline.wrappedValue,viewModel:viewModel)
//                                Divider()
                            }
                            .id(timeline.id)
                            .onAppear(perform: {
                                if viewModel.shouldLoadData(id: timeline.id) && searchText == "" {
                                    viewModel.getUserTimeLine()
                                }
                            })
                            .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                            .padding(.vertical, 4)
                            .listRowSpacing(10)
                            .listRowSeparator(.hidden)
                        }
                    }.listStyle(.plain)
                        .onChange(of: searchText) { newSearchText in
                            if newSearchText.isEmpty {
                                viewModel.resetSearchResults()
                            } else {
                                viewModel.performSearch(with: newSearchText)
                            }
                        }
                        .onChange(of: scrollToTop) {
                        withAnimation {
                            if let post =  viewModel.timeLines.first {
                                proxy.scrollTo(post.id, anchor: .bottom)
                            }
                        }
                    }
                }
                AppActivityIndicator(showActivityIndicator: $viewModel.showActivityIndicator)
            }
            .navigationTitle("Search")
            .onAppear {
                viewModel.getUserTimeLine()
            }
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Search")
                        .font(.headline)
                }
            }

        }
        .showToast(toastText: viewModel.validationText, isShowing: $viewModel.validationAlert)
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(scrollToTop: Binding<Bool>.constant(true), selectedTab: Binding<Int>.constant(0))
    }
}

