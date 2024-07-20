//
//  CompleteSignUpView.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI
struct CompleteSignUpView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel:AuthViewModel

    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 12) {
                Spacer()
                Text("Welcome to lgcy, \(viewModel.userName)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                    .multilineTextAlignment(.center)


                Text("Click below to complete registration and start using lgcy")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Button {
                    let params = ["email": viewModel.email, "username": viewModel.userName, "password": viewModel.password, "phoneNumber": viewModel.phoneNumber]
                    viewModel.registerUser(params: params)

                } label: {
                    Text("Complete Sign Up")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 360, height: 44)
                        .background(Color.black)
                        .cornerRadius(8)
                }
                .padding(.vertical)
                .alert("Sign Up failed", isPresented: $viewModel.validationAlert) {
                    Button("OK") {
                        DispatchQueue.main.async {
                            viewModel.validationAlert = false
                        }}
                } message: {
                    Text(viewModel.validationText)
                }
                Spacer()
                    .onChange(of: viewModel.isEmailAvailable, {
                        if viewModel.isEmailAvailable {
                            viewModel.isEmailAvailable = false
                            AppManager.TabIndex.send(4)
                            AppManager.Authenticated.send(true)
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


struct CompleteSignUpView_Previews: PreviewProvider {
    static var previews: some View {
        CompleteSignUpView(viewModel: AuthViewModel())
    }
}
