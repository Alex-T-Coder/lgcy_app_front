//
//  CreateUsernameView.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI

struct CreateUsernameView: View {
    @State private var actionState: Bool = false
    @State private var showValidationAlertForUsername: Bool = false
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel:AuthViewModel
    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 12) {
                Text("Create Username")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)

                SpaceEmojiTextField(placeholder: "Username", text: $viewModel.userName)
                    .autocapitalization(.none)

                Button {
                    if viewModel.userName.isValidUsername {
                        viewModel.checkAvailabilityOf(params:["username":viewModel.userName])
                    } else {
                        viewModel.validationText = "Please Enter Valid UserName"
                        showValidationAlertForUsername = true
                    }
                } label: {
                    Text("Next")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 360, height: 44)
                        .background(Color.black)
                        .cornerRadius(8)
                }
                .padding(.vertical)
//                .alert("Error", isPresented: $showValidationAlertForUsername) {
//                    Button("OK") {}
//                } message: {
//                    Text(viewModel.validationText)
//                }

                NavigationStack{}
                    .navigationDestination(isPresented: $actionState) {
                        CreateNameView(viewModel: viewModel)
                            .navigationBarBackButtonHidden()
                    }
                Spacer()
                    .onChange(of: viewModel.isEmailAvailable, {
                        if viewModel.isEmailAvailable {
                            viewModel.isEmailAvailable = false
                            self.actionState = true
                        }
                    })
            }
            AppActivityIndicator(showActivityIndicator: $viewModel.showActivityIndicator)
        }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                        .onTapGesture {
                            dismiss()
                        }
                }
            }
    }
}
    struct CreateUsernameView_Previews: PreviewProvider {
        static var previews: some View {
            CreateUsernameView(viewModel: AuthViewModel())
    }
}
