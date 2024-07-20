//
//  CreateTimelineView.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI
import PhotosUI
import AVFoundation

struct CreateTimelineView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedPickerItem: PhotosPickerItem?
    @State private var selectedImage:UIImage?
    @State private var selectedVideoURL: URL? = nil
    @State private var selectedImageType: String = "photo"
    @State private var timelineTitle = ""
    @State private var description = ""
    @State private var link = ""
    @State private var followersHidden = false
    @ObservedObject var viewModel:UserProfileViewModel
    init(viewModel:UserProfileViewModel) {
        self.viewModel = viewModel
    }
    // Determine whether the "Create" button should be enabled
    var isCreateButtonEnabled: Bool {
        return !timelineTitle.isEmpty 
//        && (selectedImage != nil) && !description.isEmpty && !link.isEmpty
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack{
                // Toolbar
                VStack {
                    HStack {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(.black)
                        
                        Spacer()
                        
                        Text("Create Timeline")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button {
                            if isCreateButtonEnabled {
                                viewModel.addTimeLine(link: link, title: timelineTitle, description: description, statusFollowerShow: !followersHidden, timeLineImage: selectedImage, imageType: selectedImageType) { timelines in
                                    self.viewModel.timelines = timelines
                                    if !viewModel.validationAlert {
                                        dismiss()
                                    }
                                }
                            }
                        } label: {
                            Text("Create")
                                .font(.subheadline)
                                .fontWeight(isCreateButtonEnabled ? .bold : .regular)
                                .foregroundColor(.black)
                        }
                        .disabled(!isCreateButtonEnabled)
                        .opacity(isCreateButtonEnabled ? 1 : 0.5)
                        .alert("Create failed", isPresented: $viewModel.validationAlert) {
                            Button("OK") {}
                        } message: {
                            Text(viewModel.validationText)
                        }
                        
                    }
                    .padding()
                    
                    Divider()
                }
                
                PhotosPicker(selection: $selectedPickerItem, matching: .images) {
                    VStack {
                        if selectedImage != nil {
                            Image(uiImage: selectedImage!)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                        } else {
                            Color.gray
                                .frame(width: 100, height: 100)
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
                .onChange(of: selectedPickerItem) { newItem in
                    if let newItem {
                        Task {
                            if let data = try? await    newItem.loadTransferable(type: Data.self) {
                                if ((try? await newItem.loadTransferable(type: Image.self)) != nil) {
                                    if let image = UIImage(data: data) {
                                        selectedImage = image
                                        selectedImageType = "photo"
                                    }
//                                } else {
//                                    if let url = await saveVideoToTemporaryDirectory(data: data) {
//                                        selectedVideoURL = url
//                                        selectedImage = generateThumbnail(url: url)
//                                        selectedImageType = "video"
//                                    }
                                }
                            }
                        }
                    }
                }
                VStack {
                    EditProfileRowView(title: "Title", placeholder: "Enter timeline title", text: $timelineTitle)
                    
                    EditProfileRowView(title: "Description", placeholder: "Enter description", text: $description)
                    
                    EditProfileLinkView(title: "Link", placeholder: "Link", text: $link)
                }
                
                HStack {
                    Toggle(isOn: $followersHidden) {
                        Text("Followers Hidden")
                            .font(.subheadline) 
                    }
                    .toggleStyle(SmallBlackToggleStyle())
                    .padding(.leading, -14)
                    .padding(.vertical, 5)
                    .onChange(of: followersHidden) { (oldValue, newValue) in
                        followersHidden = newValue
                    }
                    
                    Spacer()
                }
                                
                Spacer()
                
            }.onChange(of: viewModel.isUpdated, {
                if viewModel.isUpdated {
                    viewModel.isUpdated = false
                    dismiss()
                }
            })
            AppActivityIndicator(showActivityIndicator: $viewModel.showActivityIndicator)
        }
    }
    
    func generateThumbnail(url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMake(value: 1, timescale: 2)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        } catch {
            print("Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
    func saveVideoToTemporaryDirectory(data: Data) async -> URL? {
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempURL = tempDirectory.appendingPathComponent("temporaryCreateTineline").appendingPathExtension("mov")
        do {
            try data.write(to: tempURL)
            return tempURL
        } catch {
            print("Error saving video to temporary directory: \(error.localizedDescription)")
            return nil
        }
    }
}

struct CreateTimelinePreviewContainer : View {
    @State var timelines: [TimelineDTO] = [TimelineDTO(
        id: "65ba35d75c4448003aa4f733",
        title: "test title",
        description: "test desc",
        link: "test link", coverImage: ImageDTO(real: "timelineimage", key: "test", url: "testurl"),
        status: TimelineStatus(value: "secret", followerShown: true, inviters: []),
        creator: Creator(id: "", name: "", description: "", image: nil, username: ""),
        followers: []
    )]
    
    var body: some View {
        CreateTimelineView(viewModel: UserProfileViewModel())
    }
}


struct CreateTimelineView_Previews: PreviewProvider {
    static var previews: some View {
        CreateTimelinePreviewContainer()
    }
}

