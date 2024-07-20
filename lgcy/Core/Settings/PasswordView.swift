//
//  PasswordView.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI

struct PasswordView: View {
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmNewPassword = ""
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel:SettingsViewModel
    var isSaveButtonEnabled: Bool {
        return currentPassword.count >= 6
            && newPassword.count >= 6
            && newPassword == confirmNewPassword
    }

    var body: some View {
        ZStack(alignment:.top){
            VStack(spacing: 12) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .font(.system(size: 18))
                    }
                    .foregroundColor(.black)

                    Spacer()

                    Text("Password")
                        .font(.headline)
                        .fontWeight(.semibold)

                    Spacer()

                    Button {
                        if isSaveButtonEnabled {
                            viewModel.updateUserPassword(currentPassword: currentPassword, newPassword: newPassword)
                            print("Update password")
                        }
                    } label: {
                        Text("Save")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(isSaveButtonEnabled ? .black : .gray)
                    }
                    .disabled(!isSaveButtonEnabled)
                }
                .padding()

                Divider()

                Text("Your password must be at least 6 characters in length")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                SecureField("Current Password", text: $currentPassword)
                    .autocapitalization(.none)
                    .modifier(lgcyTextFieldModifier())
                    .padding(.top)

                SecureField("New Password", text: $newPassword)
                    .autocapitalization(.none)
                    .modifier(lgcyTextFieldModifier())
                    .padding(.top)

                SecureField("Confirm New Password", text: $confirmNewPassword)
                    .autocapitalization(.none)
                    .modifier(lgcyTextFieldModifier())
                    .padding(.top)

                Spacer()
            }.onChange(of: viewModel.isUserPassword, {dismiss()})
            AppActivityIndicator(showActivityIndicator: $viewModel.showActivityIndicator)
        }.showToast(toastText: viewModel.validationText, isShowing: $viewModel.validationAlert)
    }
}

struct PasswordView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordView(viewModel: SettingsViewModel())
    }
}
