//
//  AddMobileNumberView.swift
//  lgcy
//
//  Created by mac on 1/22/24.
//

import SwiftUI
import iPhoneNumberField

struct AddMobileNumberView: View {
    @State private var mobilenumber = ""
    @State private var actionState: Bool = false
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel:AuthViewModel
    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }
    var body: some View {
        ZStack(alignment: .top) {
        VStack(spacing: 12) {
            Text("Add your Mobile Number")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
                Section {
                        iPhoneNumberField("(000) 000-0000", text: $mobilenumber)
                            .flagHidden(false)
                            .flagSelectable(true)
                            .prefixHidden(false)
                            .maximumDigits(14)
                            .onNumberChange{ code in
                                if let number = code {
                                    viewModel.phoneNumber = "\(number.countryCode)\(number.nationalNumber)"
                                    self.actionState = true
                                } else {
                                    self.actionState = false
                                    viewModel.phoneNumber = ""
                                }

                            }
                            .onEditingEnded{ code in
                                if code.isValidNumber, let number = code.phoneNumber {
                                    viewModel.phoneNumber = "\(number.countryCode)\(number.nationalNumber)"
                                } else {
                                    viewModel.phoneNumber = ""
                                    self.actionState = code.isValidNumber
                                }

                            }
                            .onReturn{ code in
                                if code.isValidNumber, let number = code.phoneNumber {
                                    viewModel.phoneNumber = "\(number.countryCode)\(number.nationalNumber)"
                                } else {
                                    viewModel.phoneNumber = ""
                                    self.actionState = code.isValidNumber
                                }
                            }.onEdit {
                                code in
                                if code.isValidNumber, let number = code.phoneNumber {
                                    viewModel.phoneNumber = "\(number.countryCode)\(number.nationalNumber)"
                                } else {
                                    viewModel.phoneNumber = ""
                                    self.actionState = code.isValidNumber
                                }
                            }
                            .clearButtonMode(.whileEditing)

                            .keyboardType(.numberPad)
                            .textContentType(.telephoneNumber)

                            .font(.subheadline)
                            .scrollDismissesKeyboard(.automatic)
                            .foregroundColor(Color.black)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding(.horizontal, 24)

                }
            Button {
//                if !viewModel.phoneNumber.isEmpty {
//                        viewModel.sendVerificationCode(phoneNumber: viewModel.phoneNumber)
//                        viewModel.verifyCode(phoneNumber: viewModel.phoneNumber, otp: "1234")
//                } else {
//                    viewModel.validationText = "Please Enter a Valid Phone Number"
//                }
                let params = ["email": viewModel.email, "name": viewModel.name, "username": viewModel.userName, "password": viewModel.password, "phoneNumber": viewModel.phoneNumber]
                UserDefaultsManager.shared.clearUserData()
                viewModel.registerUser(params: params)
            } label: {
                Text("Next")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 360, height: 44)
                    .background(actionState ? Color.black : Color.gray)
                    .cornerRadius(8)
            }.disabled(!actionState)
            .padding(.vertical)
//            .alert("Error", isPresented: $viewModel.validationAlert) {
//                Button("OK") {
//                    DispatchQueue.main.async {
//                        viewModel.validationText = ""
//                    }
//                }
//            } message: {
//                Text(viewModel.validationText)
//            }
//            NavigationStack{}
//                .navigationDestination(isPresented: $viewModel.isVerificationCodeSent) {
////                MobileOTPView(viewModel: viewModel).navigationBarBackButtonHidden()
//                    CompleteSignUpView(viewModel: viewModel).navigationBarBackButtonHidden()
//            }
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
    struct AddMobilelNumberView_Previews: PreviewProvider {
        static var previews: some View {
            AddMobileNumberView(viewModel: AuthViewModel())
    }
}
