//
//  UploadPostView.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI
import PhotosUI
import MapKit
import CoreLocation

struct UploadPostView: View {
    @ObservedObject var viewModel:UploadPostViewModel
    @State private var isDatePickerPresented = false
    @State private var tapCount = 0
    @State private var showPlaceLookupSheet = false
    @EnvironmentObject var locationManager: LocationManager
    @State var returnedPlace = Place(mapItem: MKMapItem())
    @Environment(\.dismiss) var presentationMode
    init(viewModel:UploadPostViewModel) {
        self.viewModel = viewModel
    }
    var body: some View {
        NavigationView {
            VStack {
                HStack(alignment: .top, spacing: 0) {
                    Button {
                        presentationMode()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(.black)
                    }
                    Spacer()
                    Text("New Post")
                        .fontWeight(.semibold)
                    Spacer()
                    NavigationLink(destination: {
                        SharePostView(viewModel: viewModel)
                    }, label: {
                        Text("Next")
                            .fontWeight(.semibold)
                            .foregroundColor(Color.black)
                    })
                    .isDetailLink(false)
                }
                .padding(.top)
                .padding(.horizontal)
                .padding(.bottom)

                Divider()



ScrollView(.vertical,content: {

    HStack(spacing: 8) {
        ScrollView(.horizontal) {
            HStack(alignment: .center, spacing:0){
                
                if let image = viewModel.selectedImages.last?.image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipped()
//                          .clipShape(RoundedRectangle(cornerRadius:10))
                    }
            }
            .scrollTargetLayout()
        }.frame(width: 100, height: 85)
        .scrollTargetBehavior(.viewAligned)

        TextField("Share the story...", text: $viewModel.caption, axis: .vertical)
            .accentColor(.black) 
    }
        .padding()

    Divider()

            HStack {
                Text(viewModel.selectedDate, style: .date)
                    .font(.headline)
                    .fontWeight(.regular)
                    .foregroundColor(.black)
                    .padding(.leading)

                Spacer()

                Button {
                    isDatePickerPresented.toggle()
                } label: {
                    Image(systemName: "calendar")
                        .resizable()
                        .frame(width: 23, height: 23)
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)
                }
                .popover(isPresented: $isDatePickerPresented) {
                    VStack {
                        DatePicker(
                            "",
                            selection: $viewModel.selectedDate,
                            in: ...Date(),
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.graphical)
                        .onTapGesture(count: 2) {
                            isDatePickerPresented.toggle()
                        }

                        Button("Done") {
                            isDatePickerPresented.toggle()
                        }
                        .padding()
                        .foregroundColor(.black)
                    }
                    .padding()
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 5)
            .padding(.trailing, 4)

            Divider()

            Toggle("Turn Off Commenting", isOn: $viewModel.turnOffComments)
                .toggleStyle(SmallBlackToggleStyle())
                .padding(.horizontal, -2)
                .padding(.vertical, 4)
                .padding(.trailing, 6)
                .onChange(of: viewModel.turnOffComments) { (oldValue, newValue) in
                    viewModel.turnOffComments = newValue
                    print(viewModel.turnOffComments)
                }

            Divider()

            Toggle("Turn Off Liking", isOn: $viewModel.turnOffLikes)
                .toggleStyle(SmallBlackToggleStyle())
                .padding(.horizontal, -2)
                .padding(.vertical, 4)
                .padding(.trailing, 6)
                .onChange(of: viewModel.turnOffLikes) { (oldValue, newValue) in
                    viewModel.turnOffLikes = newValue
                    print(viewModel.turnOffLikes)
                }

            Divider()

            HStack {
                Text("Add Location")
                    .font(.headline)
                    .fontWeight(.regular)
                    .padding(.leading)
                    .padding(.horizontal, 6)

                Spacer()

                Button {
                    showPlaceLookupSheet.toggle()
                } label: {
                    Text($viewModel.locationText.wrappedValue) // Display the selected location text
                        .font(.subheadline)
                        .frame(width: 220, height: 32)
                        .foregroundColor(.black)
                        .overlay(RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 0.75))
                }
                .padding(.trailing, 13)
                .padding(.leading, 22)
                .padding(.vertical, 4)
            }
            .fullScreenCover(isPresented: $showPlaceLookupSheet) {
                PlaceLookupView(returnedPlace: $returnedPlace)
                    .environmentObject(LocationManager()) // Pass the LocationManager
            }
            .onChange(of: returnedPlace) {
                viewModel.locationText = returnedPlace.address
            }
            .onChange(of: viewModel.locationText) {

            }

                    Divider()

                    Spacer()
                })
            }.navigationBarBackButtonHidden()
        }.navigationBarHidden(true)
    }
}

struct UploadPostView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UploadPostView(viewModel: UploadPostViewModel(feedsViewModel: FeedViewModel()))
                .environmentObject(LocationManager()) // Make sure LocationManager is added if needed
        }
    }
}

