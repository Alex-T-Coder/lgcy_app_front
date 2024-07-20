//
//  CreatePasswordView.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI

struct CreatePasswordView: View {
    @State private var actionState: Bool = false
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel:AuthViewModel
    @State var showValidationAlertForPassword = false
    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel

    }
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 12) {
                Text("Create a password")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("Your passwword must be at least 8 characters in length")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                SecureField("Password", text: $viewModel.password)
                    .autocapitalization(.none)
                    .modifier(lgcyTextFieldModifier())

                    .padding(.top)


                Button {
                    if viewModel.password.count >= 8 {
                        self.actionState = true
                    } else {
                        viewModel.validationText = "Please Enter Valid Password"
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
//                .alert("Error", isPresented: $showValidationAlertForPassword) {
//                    Button("OK") {}
//                } message: {
//                    Text("Please Enter Valid Password")
//                }
                NavigationStack{}
                    .navigationDestination(isPresented: $actionState) {
                        AddMobileNumberView(viewModel: viewModel).navigationBarBackButtonHidden()
                    }
                
                Spacer()
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

struct CreatePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePasswordView(viewModel: AuthViewModel())
    }
}
