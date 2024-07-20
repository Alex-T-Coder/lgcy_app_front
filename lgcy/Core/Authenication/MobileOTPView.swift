//
//  MobileOTPView.swift
//  lgcy
//
//  Created by Adnan Majeed on 26/02/2024.
//

import Foundation
import SwiftUI
import Combine
struct MobileOTPView: View {
    @State private var actionState: Bool = false
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel:AuthViewModel

    enum FocusPin {
        case  pinOne, pinTwo, pinThree, pinFour
    }

    @FocusState private var pinFocusState : FocusPin?
    @State var pinOne: String = ""
    @State var pinTwo: String = ""
    @State var pinThree: String = ""
    @State var pinFour: String = ""

    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 12) {
                Text("Enter OTP")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                Text("We have sent a OTP on your number \(viewModel.phoneNumber)")
                    .font(.title2)
                    .lineLimit(2)
                    .fontWeight(.bold)
                    .padding(.top)
                Section {
                    HStack(spacing:15, content: {
                        TextField("", text: $pinOne)
                            .modifier(OtpModifer(pin:$pinOne))
                            .onChange(of:pinOne){
                                if (pinOne.count == 1) {
                                    pinFocusState = .pinTwo
                                }
                            }
                            .focused($pinFocusState, equals: .pinOne)

                        TextField("", text:  $pinTwo)
                            .modifier(OtpModifer(pin:$pinTwo))
                            .onChange(of:pinTwo){
                                if (pinTwo.count == 1) {
                                    pinFocusState = .pinThree
                                }
                            }
                            .focused($pinFocusState, equals: .pinTwo)
                        TextField("", text:$pinThree)
                            .modifier(OtpModifer(pin:$pinThree))
                            .onChange(of:pinThree){
                                if (pinThree.count == 1) {
                                    pinFocusState = .pinFour
                                }
                            }
                            .focused($pinFocusState, equals: .pinThree)


                        TextField("", text:$pinFour)
                            .modifier(OtpModifer(pin:$pinFour))
                            .focused($pinFocusState, equals: .pinFour)


                    })
                    .padding(.vertical)
                }

                Button {
                    let code = "\(pinOne+pinTwo+pinThree+pinFour)"
                    if code.count == 4 {
                        viewModel.verifyCode(phoneNumber: viewModel.phoneNumber, otp: code)
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
                .alert("Error", isPresented: $viewModel.validationAlert) {
                    Button("OK") {
                        DispatchQueue.main.async {
                            viewModel.validationAlert = false
                        }
                    }
                } message: {
                    Text(viewModel.validationText)
                }

                NavigationStack{}
                    .navigationDestination(isPresented: $viewModel.isPhoneVerified) {
                        CompleteSignUpView(viewModel: viewModel).navigationBarBackButtonHidden()
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
struct MobileOTPView_Previews: PreviewProvider {
    static var previews: some View {
        MobileOTPView(viewModel: AuthViewModel())
    }
}

