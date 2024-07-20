//
//  PublicProfileView.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI
import NukeUI

struct PublicProfileView: View {

    @State private var isReportAccountPresented = false
    @State private var isPublicTimelineViewPresented = false
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var viewModel:PublicProfileViewModel
    init(profileId:String) {
        self.viewModel = PublicProfileViewModel(userId: profileId)
    }
    private let gridItems: [GridItem] = [
        .init(.flexible(), spacing: 1),
        .init(.flexible(), spacing: 1)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 10){
                    HStack{
                        CircularProfileImageView(imagePath: viewModel.user.image?.url ?? "", height: 80, width: 80)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // name and bio
                    VStack(alignment: .leading, spacing: 4){
                        Text(viewModel.user.name ?? "")
                            .font(.footnote)
                            .fontWeight(.semibold)
                        
                        Text("Welcome to my story")
                            .font(.footnote)
                        
                        Text("\(viewModel.user.link ?? "")")
                            .font(.footnote)
                            .fontWeight(.semibold)
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                    
                    Divider()
                }
                
                LazyVGrid(columns: gridItems, spacing: 20) {
                    ForEach(viewModel.timelines) { timeline in
                        VStack {
                            Button {
                                viewModel.selectedTimeLineID = timeline.id
                                isPublicTimelineViewPresented.toggle()

                            } label: {

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
                                    }
                                    .scaledToFill()
                                    .frame(width: (UIScreen.main.bounds.width - 40) / 2, height: (UIScreen.main.bounds.width - 40) / 2 - 25)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        Group {
                                            if timeline.imageType == "video" {
                                                Image(systemName: "video.fill")
                                                    .resizable()
                                                    .frame(width: 24, height: 16)
                                                    .padding(5)
                                                    .foregroundColor(.white)
                                            }
                                        },
                                        alignment: .topTrailing
                                    )
                                } else {
                                    Color.gray
                                        .frame(width: (UIScreen.main.bounds.width - 40) / 2, height: (UIScreen.main.bounds.width - 40) / 2 - 25)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                            .fullScreenCover(isPresented: $isPublicTimelineViewPresented) {
                                PublicTimelineView(timelineId: viewModel.selectedTimeLineID)
                            }

                            VStack {
                                
                                Spacer()
                                
                                HStack {
                                    Text("\(timeline.title)")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .padding(.leading, 10)
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            AppActivityIndicator(showActivityIndicator: $viewModel.showActivityIndicator)
        }
            .navigationTitle("\(viewModel.user.username)")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: HStack {
                Image(systemName: "chevron.left")
                    .foregroundColor(.black)
                    .font(.system(size: 15))
                    .padding(.leading, 1)
                    .onTapGesture {
                        dismiss()
                    }
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isReportAccountPresented.toggle()
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.black)
                    }
                    .contentShape(Rectangle())
                    .alert(isPresented: $isReportAccountPresented) {
                        Alert(
                            title: Text("Block Account?"),
                            primaryButton: .default(Text("Cancel")),
                            secondaryButton: .destructive(Text("Block"), action: {
                                // Perform log out logic here
                            })
                        )
                    }
                    
                }
            }
        }
    }
}

struct PublicProfileView_Previews: PreviewProvider {
    static var previews: some View {
        PublicProfileView(profileId: "65cf70fce02b77109b4ae820")
    }
}
