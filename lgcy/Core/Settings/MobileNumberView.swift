//
//  MobileNumberView.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI

struct MobileNumberView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentMobileNumber = ""
    @State private var newMobileNumber = ""
    @ObservedObject var viewModel:SettingsViewModel
    @State var isSaveButtonEnabled = false
    var body: some View {
        ZStack(alignment: .top){
        VStack {
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .font(.system(size: 18))
                    }

                    Text("Mobile Number")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                    Button {
                        if isSaveButtonEnabled {
                            viewModel.updateUserPhone(currentPhone: currentMobileNumber, newPhone: newMobileNumber)
                        }
                    } label: {
                        Text("Save")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(isSaveButtonEnabled ? .black : .gray)
                    }
                    .disabled(!isSaveButtonEnabled)
                }
            }
            .padding(20)

            Divider()

            Text("Your phone number makes it easier for you to recover your account, for you and your friends to find each other on lgcy and more. To help keep your account safe, only use a phone number that you own")
                .font(.footnote)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.top)
                .padding(.bottom, 30)

            List {
                Section {
                    TextField("Current Mobile Number", text: $currentMobileNumber)
                        .keyboardType(.numberPad)
                        .foregroundColor(.black)
                        .disabled(true)

                    TextField("New Mobile Number", text: $newMobileNumber)
                        .keyboardType(.numberPad)
                        .foregroundColor(.black)
                }
            }

        }.onChange(of: viewModel.isUserPassword, {dismiss()})
                .onChange(of: newMobileNumber, {
                    self.isSaveButtonEnabled = newMobileNumber.count > 7
                })
        AppActivityIndicator(showActivityIndicator: $viewModel.showActivityIndicator)
    }
        .onAppear(perform: {
            ApiManager.shared.getUser { result in
                switch result {
                case .success(let user):
                    currentMobileNumber = user.phoneNumber
                    
                case .failure(_):
                    print("Error getting user details")
                }
            }
        }).showToast(toastText: viewModel.validationText, isShowing: $viewModel.validationAlert)
    }
}

struct MobileNumberView_Previews: PreviewProvider {
    static var previews: some View {
        MobileNumberView(viewModel: SettingsViewModel())
    }
}
