//
//  SharePostView.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI

struct SharePostView: View {
    @EnvironmentObject var tabStateManager: TabStateManager
    @State private var selectedPublicTimelines: Set<String> = []
    @State private var selectedContacts: Set<String> = []
    @State private var actionState: Bool = false
    @ObservedObject var viewModel: UploadPostViewModel
    @ObservedObject var contactManager = ContactManageModel()
    var isFromFeedView: Bool
    var onPostTapped: ((Set<String>, Set<String>) -> Void)?
    @Environment(\.dismiss) var presentationMode
    init(viewModel: UploadPostViewModel, isFromFeedView: Bool = false, onPostTapped: ((Set<String>, Set<String>) -> ())? = nil) {
        self.viewModel = viewModel
        self.isFromFeedView = isFromFeedView
        self.onPostTapped = onPostTapped
    }

    var isShareButtonDisabled: Bool {
        selectedPublicTimelines.isEmpty && selectedContacts.isEmpty
    }

    var body: some View {
        ZStack(alignment: .top) {
            NavigationView {
                VStack(spacing: 0) {
                    VStack {
                        HStack {
                            Button {
                                presentationMode()
                            } label: {
                                Image(systemName: "chevron.backward")
                                    .foregroundColor(.black)
                            }
                            Spacer()
                            Text("Share Post")
                                .fontWeight(.semibold)
                            

                            Spacer()
                            Button {
                                viewModel.isPostCreated = false
                                if isFromFeedView {
                                    onPostTapped?(selectedContacts, selectedPublicTimelines)
                                } else {
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "MM-dd-yyyy"
                                    let scheduleDate = dateFormatter.string(from: viewModel.selectedDate)
                                    var params:[String:Any] = [
                                        "location":viewModel.locationText,
                                        "description":viewModel.caption,
                                        "scheduleDate":scheduleDate,
                                        "liking":String(!viewModel.turnOffLikes),
                                        "commenting": String(!viewModel.turnOffComments)]
                                    params["share[users]"] =  selectedContacts
                                    params["share[timelines]"] =  selectedPublicTimelines
                                    viewModel.sharePost(params:params, completion: { success in
                                        if (success) {
                                            tabStateManager.selectedTab = 0
                                        }
                                    })
                                }
                            } label: {
                                    Text("Share")
                                        .foregroundColor(isShareButtonDisabled ? .gray : .black)
                                        .fontWeight(isShareButtonDisabled ? .regular : .semibold)
                                }
                            .disabled(isShareButtonDisabled)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 12).edgesIgnoringSafeArea(.horizontal)
                    }
                    .padding(.bottom)

                    Divider()

                    NavigationStack {
                        ScrollView {
                            Text("Timelines")
                                .foregroundColor(.black)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()

                            ForEach(viewModel.timelines) { timeline in
                                VStack {
                                    HStack {
                                        let url = (timeline.coverImage?.url ?? "")
                                        if !url.isEmpty {
                                            CircularProfileImageView(imagePath: url)
                                        } else {
                                            Color.gray
                                                .frame(width: 40, height: 40)
                                                .clipShape(Circle())
                                        }
                                        Text(timeline.title)
                                            .font(.subheadline)
//                                            .fontWeight(.semibold)
                                            .onTapGesture {
                                                togglePublicSelection(for: timeline.id)
                                            }

                                        Spacer()

                                        if selectedPublicTimelines.contains(timeline.id) {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.black)
                                                .padding(.horizontal, 12)
                                        } else {
                                            Spacer()
                                        }
                                    }
                                    .padding(.leading, 30)
                                    .padding(.vertical, 3)
                                    .contentShape(Rectangle()) // Tap gesture covers the entire row
                                    .onTapGesture {
                                        togglePublicSelection(for: timeline.id)
                                    }
                                }
                                Divider()
                                    .padding(.leading, 25)
                            }

                            Text("Contacts")
                                .foregroundColor(.black)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()

                            ForEach(viewModel.users, id: \.id) { user in
                                VStack {
                                    HStack {
                                        CircularProfileImageView(imagePath: user.image?.url)
                                        Text("\(user.username ?? "")")
                                            .font(.subheadline)
//                                            .fontWeight(.semibold)
                                            .onTapGesture {
                                                toggleContactSelection(for: user.id)
                                            }
                                        
                                        Spacer()

                                        if selectedContacts.contains(user.id) {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.black)
                                                .padding(.horizontal, 12)
                                        } else {
                                            Spacer()
                                        }
                                    }
                                    .padding(.leading, 30)
                                    .padding(.vertical, 3)
                                    .contentShape(Rectangle()) // Tap gesture covers the entire row
                                    .onTapGesture {
                                        toggleContactSelection(for: user.id)
                                    }
                                }
                                Divider()
                                    .padding(.leading, 25)
                            }
                        }
                    }.navigationBarBackButtonHidden()
                    Spacer()
                }.onChange(of: viewModel.isPostCreated, {

                    if viewModel.isPostCreated {
                        viewModel.caption = ""
                        viewModel.selectedImages = []
                        viewModel.locationText = ""
                        viewModel.selectedDate = Date()
                        viewModel.moveToNextAvailable = false
//                        AppManager.TabIndex.send(0)
                    }
                })
                .onChange(of: viewModel.isPostCreatedFromFeedView, {
                    if viewModel.isPostCreatedFromFeedView {
                        presentationMode()
                    }
                })
            }
            AppActivityIndicator(showActivityIndicator: $viewModel.showActivityIndicator)
        }
        .onAppear {
            contactManager.fetchContacts { contacts, error in
                if let error = error {
                    print("Failed to fetch contacts:", error)
                } else if let contacts = contacts {
                    var phoneNumbers: [String] = []
                    for contact in contacts {
                        for phoneNumber in contact.phoneNumbers {
                            let number = phoneNumber.value.stringValue
                            phoneNumbers.append(number)
                        }
                    }
                    viewModel.syncingContacts(contact: phoneNumbers)
                }
            }
        }
            .showToast(toastText: viewModel.validationText, isShowing: $viewModel.validationAlert)
            .navigationBarHidden(true)
    }

    private func togglePublicSelection(for user: String) {
        if selectedPublicTimelines.contains(user) {
            selectedPublicTimelines.remove(user)
        } else {
            selectedPublicTimelines.insert(user)
        }
    }

    private func toggleContactSelection(for user: String) {
        if selectedContacts.contains(user) {
            selectedContacts.remove(user)
        } else {
            selectedContacts.insert(user)
        }
    }
}

struct SharePostView_Previews: PreviewProvider {
    @StateObject static var vm = UploadPostViewModel(feedsViewModel: FeedViewModel())
    static var previews: some View {
        SharePostView(viewModel: vm)
    }
}
