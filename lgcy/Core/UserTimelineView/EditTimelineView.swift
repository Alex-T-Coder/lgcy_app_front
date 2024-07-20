//
//  EditTimelineView.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI
import PhotosUI
import NukeUI

struct EditTimelineView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedPickerItem: PhotosPickerItem?
    @State var timeline: TimelineDTO
    @State private var timelineTitle = ""
    @State private var description = ""
    @State private var link = ""
    @State private var followersHidden = false
    @State private var isDeleteTimelineAlertPresented = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var selectedImage: UIImage?
    @ObservedObject var viewModel: UserProfileViewModel
    let deletedTimeline: () -> Void
    
    // Determine whether the "Done" button should be enabled
    var isDoneButtonEnabled: Bool {
        return !timelineTitle.isEmpty
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                // Toolbar
                VStack {
                    HStack {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(.black)
                        
                        Spacer()
                        
                        Text("Edit Timeline")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button {
                            if isDoneButtonEnabled {
                                
                                viewModel.updateTimeLine(timelineId: timeline.id, link: link, title: timelineTitle, description: description, statusFollowerShow: !followersHidden, timeLineImage: selectedImage) { updatedTimeline in
                                    if let updatedTimeline = updatedTimeline {
                                        self.timeline = updatedTimeline
                                        self.viewModel.selectedTimeline = updatedTimeline
                                        dismiss()
                                    }
                                }
                                
                            }
                            
                        } label: {
                            Text("Done")
                                .font(.subheadline)
                                .fontWeight(isDoneButtonEnabled ? .bold : .regular)
                                .foregroundColor(.black)
                        }
                        .disabled(!isDoneButtonEnabled) // Disable the button when isDoneButtonEnabled is false
                        .alert("Edit failed", isPresented: $showAlert) {
                            Button("OK") {}
                        } message: {
                            Text(alertMessage)
                        }
                    }
                    .padding()
                    
                    Divider()
                }.onChange(of: viewModel.isUpdated, {
                    if viewModel.isUpdated {
                        viewModel.isUpdated = false
                        dismiss()
                    }
                })
                
                // Edit profile pic
                PhotosPicker(selection: $selectedPickerItem, matching: .images) {
                    VStack {
                        if selectedImage == nil {
                            if let url = URL(string: timeline.coverImage?.url ?? "") {
                                LazyImage(url: url) { state in
                                    if let image = state.image {
                                        image.resizable()
                                    } else if state.error != nil  {
                                        Image("Cordus")
                                            .resizable()
                                    } else {
                                        ProgressView()
                                    }
                                    
                                }.scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.white)
                                    .background(.gray)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                            } else {
                                Color.gray
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.white)
                                    .background(.gray)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                            }
                        } else {
                            Image(uiImage:selectedImage!)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.white)
                                .background(.gray)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                        }
                        Text("Timeline Picture")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .padding(5)
                        
                    }
                }
                .padding(.vertical, 8)
                .onChange(of: selectedPickerItem) {
                    Task {
                        if let imageData = try? await selectedPickerItem?.loadTransferable(type: Data.self) {
                            if let image = UIImage(data: imageData) {
                                selectedImage = image
                            }
                        }
                    }
                }
                // Edit profile info
                VStack {
                    EditProfileRowView(title: "Title", placeholder: "Enter timeline title", text: $timelineTitle).onAppear() {
                        self.timelineTitle = viewModel.selectedTimeline?.title ?? ""
                    }
                    
                    EditProfileRowView(title: "Description", placeholder: "Enter description", text: $description).onAppear() {
                        self.description = viewModel.selectedTimeline?.description ?? ""
                    }
                    
                    EditProfileLinkView(title: "Link", placeholder: "Link", text: $link).onAppear() {
                        self.link = viewModel.selectedTimeline?.link ?? ""
                    }
                }
                HStack {
                    Toggle(isOn: $followersHidden) {
                        Text("Followers Hidden")
                            .font(.subheadline) // Apply the subheadline font here
                    }
                    .toggleStyle(SmallBlackToggleStyle())
                    .padding(.leading, -14)
                    .padding(.vertical, 5)
                    .onChange(of: followersHidden) { (oldValue, newValue) in
                        followersHidden = newValue
                    }
                    .onAppear {
                        if let timeline = viewModel.selectedTimeline {
                            followersHidden = !timeline.status.followerShown
                        }
                    }
                    
                    Spacer()
                }
                
                Divider()
                
                Button {
                    isDeleteTimelineAlertPresented.toggle()
                } label: {
                    HStack {
                        Text("Delete Timeline")
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.leading, 8)
                            .padding(.vertical, 6)
                        
                        Spacer()
                        Image(systemName: "trash")
                            .imageScale(.large)
                            .foregroundColor(.red)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 6)
                    }
                    .contentShape(Rectangle())
                    .alert(isPresented: $isDeleteTimelineAlertPresented) {
                        Alert(
                            title: Text("Delete Timeline"),
                            message: Text("Are you sure you want to delete this Timeline? This action cannot be undone."),
                            primaryButton: .default(Text("Cancel").foregroundColor(.black)),
                            secondaryButton: .destructive(Text("Delete"), action: {
                                // Perform delete account logic here
                                viewModel.deleteTimeLine(timelineId: timeline.id) { isCompleted in
                                    if isCompleted {
                                        deletedTimeline()
                                    }
                                }
                            })
                        )
                    }
                }
                Divider()
                
                Spacer()
            }
            AppActivityIndicator(showActivityIndicator: $viewModel.showActivityIndicator)
        }
    }
}

struct EditTimelinePreviewContainer : View {
    @State var timelineImage: Image = Image("Cordus")
    @State var username = "test.username"
    @State var timeline: TimelineDTO = TimelineDTO(
        id: "65ba35d75c4448003aa4f733",
        title: "test title",
        description: "test desc",
        link: "test link", coverImage: ImageDTO(real: "timelineimage", key: "test", url: "testurl"),
        status: TimelineStatus(value: "secret", followerShown: true, inviters: []),
        creator: Creator(id: "", name: "", description: "", image: nil, username: ""),
        followers: []
    )
    @State var timelines: [TimelineDTO] = []
    @ObservedObject private var viewModel = UserProfileViewModel()
    
    var body: some View {
        EditTimelineView(
            timeline: timeline,
            viewModel: viewModel,
            deletedTimeline: {}
        )
    }
}

struct EditTimelineView_Previews: PreviewProvider {
    static var previews: some View {
        EditTimelinePreviewContainer()
    }
}
