//
//  CreateUsernameView.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI

struct CreateNameView: View {
    @State private var actionState: Bool = false
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel:AuthViewModel
    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 12) {
                Text("Create Name")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)

                TextField("Name", text: $viewModel.name)
                    .autocapitalization(.none)
                    .modifier(lgcyTextFieldModifier())

                Button {
                    if viewModel.name.isEmpty {
                        viewModel.validationText = "Please Enter Valid Name";
                    } else {
                        viewModel.isNameAvailable = true
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

                NavigationStack{}
                    .navigationDestination(isPresented: $actionState) {
                        CreatePasswordView(viewModel: viewModel)
                            .navigationBarBackButtonHidden()
                    }
                Spacer()
                    .onChange(of: viewModel.isNameAvailable, {
                        if viewModel.isNameAvailable {
                            viewModel.isNameAvailable = false
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
    struct CreateNameView_Preview: PreviewProvider {
        static var previews: some View {
            CreateNameView(viewModel: AuthViewModel())
    }
}
