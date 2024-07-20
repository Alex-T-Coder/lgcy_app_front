//
//  AddEmailView.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//



import SwiftUI

struct AddEmailView: View {
    @State private var actionState: Bool = false
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel:AuthViewModel
    init( viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack() {
            VStack(spacing: 12) {
                Text("Add your email")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)

                SpaceEmojiTextField(placeholder: "Email", text: $viewModel.email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)

                Button {
                   if viewModel.email.isValidEmail {
                    viewModel.checkAvailabilityOf(params: ["email": viewModel.email])
                   } else {
                       viewModel.validationText = "Please Enter Valid Email"
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
                .onChange(of: viewModel.isEmailAvailable, {
                    if viewModel.isEmailAvailable {
                        viewModel.isEmailAvailable = false
                        self.actionState = true
                    }
                })
//                .alert("Error", isPresented: $viewModel.validationAlert) {
//                    Button("OK") {
//                        DispatchQueue.main.async {
//                            viewModel.validationAlert = false
//                        }
//                    }
//                } message: {
//                    Text(viewModel.validationText)
//                }

                NavigationStack{}
                    .navigationDestination(isPresented: $actionState) {
                        CreateUsernameView(viewModel: viewModel)
                            .navigationBarBackButtonHidden()
                    }

                Spacer()
            }
            AppActivityIndicator(showActivityIndicator: $viewModel.showActivityIndicator)
        }.toolbar {
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
struct SpaceEmojiTextField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .onChange(of: text, perform: { value in
                text = filterInput(value)
            })
            .modifier(lgcyTextFieldModifier())
    }

    func filterInput(_ input: String) -> String {
        return input.filter { character in
            // Check if character is not a space and not an emoji
            return character.isASCII && !character.isWhitespace && !character.isEmoji
        }
    }
}

extension Character {
    var isEmoji: Bool {
        // Check if the character is an emoji
        return unicodeScalars.first?.properties.isEmojiPresentation ?? false
    }
}

struct AddEmailView_Previews: PreviewProvider {
    static var previews: some View {
        AddEmailView(viewModel: AuthViewModel())
    }
}
