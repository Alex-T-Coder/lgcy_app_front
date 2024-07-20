//
//  LoginView.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @ObservedObject var viewModel = AuthViewModel()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                VStack{

                    Spacer()

                        //logo image
                    Image("lgcylogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220, height: 100)
                        .padding(.bottom, 20)
                    VStack{
                        TextField("Enter your email", text: $email)
                            .autocapitalization(.none)
                            .modifier(lgcyTextFieldModifier())

                        SecureField("Enter your password", text: $password)
                            .modifier(lgcyTextFieldModifier())
                    }

                    Button {
                        UserDefaultsManager.shared.clearUserData()
                        viewModel.login(email: email, password: password)
                    } label: {
                        Text("Login")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 360, height: 44)
                            .background(Color.black)
                            .cornerRadius(8)
                    }
                    .padding(.vertical)

                    Spacer()

                    Divider()

                    NavigationLink {
                        AddEmailView(viewModel: viewModel)
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        HStack(spacing: 3) {
                            Text("Don't have an account?")
                                .foregroundColor(Color.black)

                            Text("Sign Up")
                                .fontWeight(.semibold)
                                .foregroundColor(Color.black)

                        }
                        .padding()

                    }
                    .padding(.bottom, 30)
                }
                AppActivityIndicator(showActivityIndicator: $viewModel.showActivityIndicator)
            }.edgesIgnoringSafeArea(.all)
            .alert("Error", isPresented: $viewModel.validationAlert) {
                Button("OK") {
                    DispatchQueue.main.async {
                        viewModel.validationAlert = false
                    }
                }
            } message: {
                Text(viewModel.validationText)
            }
//            .showToast(toastText: viewModel.validationText, isShowing: $viewModel.validationAlert)
            .onAppear{
            }.onChange(of: viewModel.isRegisterSuccess, {
                if viewModel.isRegisterSuccess {
                    AppManager.TabIndex.send(4)
                    AppManager.Authenticated.send(true)
                }

            }).onChange(of: viewModel.isLoggedinSuccess, {
                if viewModel.isLoggedinSuccess && !viewModel.isRegisterSuccess {
                    AppManager.TabIndex.send(0)
                    AppManager.Authenticated.send(true)
                }

            })
        }.onAppear {
            #if DEBUG
//            email = "himanshujoshi2088@gmail.com"
//            password = "2088_Roman"
            #endif
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
