//
//  EditProfileView.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI
import PhotosUI
import UIKit

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedPickerItem: PhotosPickerItem?
    @State private var fullname = ""
    @State private var bio = ""
    @State private var link = ""
    @State private var userProfileImageData: UIImage? = nil
    @ObservedObject var viewModel:UserProfileViewModel

    init(viewModel:UserProfileViewModel) {
        self.viewModel = viewModel
    }
   
    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                VStack {
                    HStack {
                        Button("Cancel"){
                            userProfileImageData = nil
                            dismiss()
                        }
                        .foregroundColor(.black) // Set font color to black
                        Spacer()
                        Text("Edit Profile")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Spacer()

                        Button {
                            viewModel.updateProfile(description: bio, name: fullname, link: link, userProfileImage: userProfileImageData) { success in
                                if success{
                                    dismiss()
                                }
                            }
                        } label: {
                            Text("Done")
                                .font(.subheadline)
                                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                .foregroundColor(.black)
                        }
                    }
                    .padding()
                    .alert("Edit failed", isPresented: $viewModel.validationAlert) {
                        Button("OK") {
                            DispatchQueue.main.async {
                                viewModel.validationAlert = false
                            }
                        }
                    } message: {
                        Text(viewModel.validationText)
                    }

                    Divider()
                }

                    //edit profile pic

                PhotosPicker(selection: $selectedPickerItem, matching: .images) {
                    VStack {
                        if let uiimage = userProfileImageData {
                            Image(uiImage: uiimage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        } else {
                            CircularProfileImageView(imagePath: viewModel.user.image?.url ?? "",height: 80, width: 80)
                        }
                        Text("Edit Profile Picture")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)

                        
                    }
                }
                .padding(.vertical, 8)
                .onChange(of: selectedPickerItem) {
                    Task {
                        if let imageData = try? await selectedPickerItem?.loadTransferable(type: Data.self) {
                            if let image = UIImage(data: imageData) {
                                userProfileImageData = image
                            }
                        }
                    }
                }

                //Edit Profile info

                VStack {
                    EditProfileRowView(title: "Name", placeholder: "Enter your name", text: $fullname).onAppear() {
                        self.fullname = viewModel.user.name ?? ""
                    }

                    EditProfileRowView(title: "Bio", placeholder: "Enter your bio", text: $bio).onAppear() {
                        self.bio = viewModel.user.description ?? ""
                    }

                    EditProfileLinkView(title: "Link", placeholder: "Link", text: $link).onAppear() {
                        self.link = viewModel.user.link ?? ""
                    }
                }

                Spacer()
            }
            AppActivityIndicator(showActivityIndicator: $viewModel.showActivityIndicator)
        }
    }
}

struct EditProfileRowView: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Text(title)
                .padding(.leading, 8)
                .frame(width: 100, alignment: .leading)
            VStack {
                TextField(placeholder, text: $text)
                Divider()
            }
        }
        .font(.subheadline)
        .frame(height: 36)
    }
}

struct EditProfileLinkView: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Text(title)
                .padding(.leading, 8)
                .frame(width: 100, alignment: .leading)
            VStack {
                TextField(placeholder, text: $text)
                    .onChange(of: text) { newValue in
                        // Ensure the text starts with a lowercase letter
                        if !newValue.isEmpty && newValue.first!.isUppercase {
                            text = String(newValue.dropFirst())
                        }
                    }
                    .autocapitalization(.none)
                
                Divider()
            }
        }
        .font(.subheadline)
        .frame(height: 36)
    }
}

struct EditProfilePreviewContainer : View {
    @State var userProfileImage = Image("Cordus")
    @State var user: User? = User(
        id: "id",
        name: "Test Name",
        email: "testemail@gmail.com",
        followers: [],
        phoneNumber: "3123123",
        birthday: "02-12-2000",
        username: "testusername",
        description: "test descriptiion",
        link: "www.test.com",
        notification: true,
        directMessage: true,
        role: "user",
        isEmailVerified: true,
        image: nil
    )
    
    var body: some View {
        EditProfileView(viewModel: UserProfileViewModel())
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfilePreviewContainer()
    }
}
