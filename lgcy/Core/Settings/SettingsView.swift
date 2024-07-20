//
//  SettingsView.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State var id: String
    @ObservedObject var viewModel:SettingsViewModel

    var body: some View {
        VStack {
                // Toolbar
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .font(.system(size: 17))
                    }

                    Spacer()

                    Text("Settings")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Spacer()
                }
            }
            .padding(17)

            Divider()

            Spacer()

            VStack(spacing: 15) {
                    // Password
                Button {
                        // Navigate to PasswordView
                    viewModel.isPasswordViewPresented = true
                } label: {
                    HStack {
                        Image(systemName: "lock")
                            .font(.system(size: 14))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)

                        Text("Password")
                            .font(.headline)
                            .fontWeight(.regular)
                            .padding(.vertical, 10)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12)) // Adjust size based on scale factor
                            .padding(.horizontal, 20)
                    }
                }
                .foregroundColor(.black)
                .contentShape(Rectangle())
                .fullScreenCover(isPresented: $viewModel.isPasswordViewPresented) {
                    PasswordView(viewModel:viewModel)
                }

                Divider()

                    // Phone Number
                Button {
                    viewModel.isMobileNumberViewPresented = true
                } label: {
                    HStack {
                        Image(systemName: "phone")
                            .font(.system(size: 14))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)

                        Text("Mobile Number")
                            .font(.headline)
                            .fontWeight(.regular)
                            .padding(.vertical, 6)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .padding(.horizontal, 20)
                    }
                }
                .foregroundColor(.black)
                .contentShape(Rectangle())
                .fullScreenCover(isPresented: $viewModel.isMobileNumberViewPresented) {
                    MobileNumberView(viewModel:viewModel)
                }

                Divider()

                    // Push Notifications
                HStack {
                    Image(systemName: "bell")
                        .font(.system(size: 14))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)

                    Text("Push Notifications")
                        .font(.headline)
                        .fontWeight(.regular)
                        .padding(.vertical, 6)

                    Spacer()

                    Toggle("", isOn: $viewModel.pushNotificationsOn)
                        .toggleStyle(SmallBlackToggleStyle())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                }
                .contentShape(Rectangle())
                .alert(isPresented: $viewModel.showSettingPage) {
                    Alert(
                        title: Text("Notification not Granted Please Enable from Setting"),
                        primaryButton: .default(Text("Cancel")),
                        secondaryButton: .destructive(Text("Settings"), action: {
                            if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                                UIApplication.shared.open(appSettings)
                            }
                        })
                    )
                }.onChange(of: viewModel.pushNotificationsOn, {
                    
                    if viewModel.pushNotificationsOn {
                        viewModel.checkNotificationAuthorization { status in
                            if status == .notDetermined{
                                viewModel.requestNotificationAuthorization()
                            }else if status == .denied{
                                viewModel.showSettingPage = true
                            }
                        }
                        
                    }else{
                        viewModel.checkNotificationAuthorization { status in
                            if status == .authorized{
                                viewModel.pushNotificationsOn = true
                                viewModel.showSettingPage = true
                            }
                        }
                    }
                })
                Divider()

                    // Privacy Policy & Terms
                Button {
                    viewModel.isPrivacyPolicyViewPresented = true

                } label: {
                    HStack {
                        Image(systemName: "checkmark.shield")
                            .font(.system(size: 14))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)

                        Text("Privacy Policy & Terms")
                            .font(.headline)
                            .fontWeight(.regular)
                            .padding(.vertical, 6)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .padding(.horizontal, 20)
                    }
                }
                .foregroundColor(.black)
                .contentShape(Rectangle())
                .fullScreenCover(isPresented: $viewModel.isPrivacyPolicyViewPresented) {
                    PrivacyPolicyView()
                }


                Divider()

                    // Log Out
                Button {
                    viewModel.isLogoutAlertPresented = true
                } label: {
                    HStack {
                        Text("Log Out")
                            .foregroundColor(.red)
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.leading, 8)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)

                        Spacer()

                    }
                }
                .contentShape(Rectangle())
                .alert(isPresented: $viewModel.isLogoutAlertPresented) {
                    Alert(
                        title: Text("Log out?"),
                        primaryButton: .default(Text("Cancel")),
                        secondaryButton: .destructive(Text("Log Out"), action: {
                                // Perform log out logic here
                            UserDefaultsManager.shared.clearUserData()
                            AppManager.Authenticated.send(false)
                        })
                    )
                }

                Divider()
                    // Delete Account
                Button {
                    viewModel.isDeleteAccountAlertPresented.toggle()
                } label: {
                    HStack {
                        Text("Delete Account")
                            .foregroundColor(.red)
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.leading, 8)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)


                        Spacer()

                    }
                }
                .contentShape(Rectangle())
                .alert(isPresented: $viewModel.isDeleteAccountAlertPresented) {
                    Alert(
                        title: Text("Delete Account"),
                        message: Text("Are you sure you want to delete your account? This action cannot be undone."),
                        primaryButton: .default(Text("Cancel").foregroundColor(.black)),
                        secondaryButton: .destructive(Text("Delete"), action: {
                            UserDefaultsManager.shared.clearUserData()
                            viewModel.deleteAccount(id: id)                            
                        })
                    )
                }

                Divider()

                Spacer()

            }
        }.onAppear {
            viewModel.checkNotificationAuthorization { status in
                if status == .authorized{
                    self.viewModel.pushNotificationsOn = true
                }else{
                    self.viewModel.pushNotificationsOn = false
                }
            }
        }.onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            viewModel.checkNotificationAuthorization { status in
                if status == .authorized{
                    self.viewModel.pushNotificationsOn = true
                }else{
                    self.viewModel.pushNotificationsOn = false
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(id: "", viewModel: SettingsViewModel())
    }
}
