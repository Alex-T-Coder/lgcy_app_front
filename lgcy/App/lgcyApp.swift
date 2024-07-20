//
//  lgcyApp.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI
import UserNotifications
import IQKeyboardManagerSwift
@main
struct lgcyApp: App {
    @State var isAuthenticated = false
    @State var selectedTab: Int = 0
    @State var isAuthenticationChecked = false
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @State var tabIndex = 0
    @State var moveToSetting = false
    init() {
       _ = ApiManager.shared
    }
    var body: some Scene {
        WindowGroup {
            Group {
                if !isAuthenticationChecked {
                    EmptyView()
                } else {
                    isAuthenticated ? AnyView(MainTabView(selectedTab: $selectedTab)) : AnyView(LoginView())
                }
            }.alert(isPresented: $moveToSetting, content: {
                Alert(
                    title: Text("Error"),
                    message: Text("Notifications are disabled please enable from Settings."),
                    primaryButton: .default(Text("Settings").foregroundColor(.black),action: {
                        if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                            UIApplication.shared.open(appSettings)
                        }
                    }),
                    secondaryButton: .destructive(Text("Cancel"))
                )
            })
            .onReceive(AppManager.TabIndex, perform: {
                selectedTab = $0
            })
            .onReceive(AppManager.Authenticated, perform: {
                isAuthenticationChecked = true
                isAuthenticated = $0
            })
            .onAppear{
                checkPushAuthorization();
                if UserDefaults.standard.string(forKey: UserDefaultsKeys.access_token.rawValue) != "" {
                    ApiManager().getToken { token in
                        if token == nil {
                            AppManager.Authenticated.send(false)
                        } else {
                            ApiManager.shared.getUser { result in
                                switch result {
                                case .success(let user):
                                    UserDefaultsManager.shared.loginUser = user
                                    AppManager.Authenticated.send(true)
                                case .failure(_):
                                    AppManager.Authenticated.send(false)
                                }
                            }
                        }
                    }
                } else {
                    isAuthenticationChecked = true
                    AppManager.Authenticated.send(false)
                }
            }
        }
    }

    func checkPushAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { status in
            print(#line,#function,status)
            switch status.authorizationStatus {
                case .denied:
                    moveToSetting = true
                case .authorized:
                    registerForNotifications()
                case .notDetermined, .provisional, .ephemeral:
                    requestPushAuthorization()
                @unknown default:
                    requestPushAuthorization()
            }
        })

    }

    func requestPushAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
            if success {
                print(#line,#function,"Push notifications allowed")
                registerForNotifications()
            } else if let error = error {
                moveToSetting = true
                print(#line,#function,error.localizedDescription)
            }
        }
    }

    func registerForNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
}



class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        IQKeyboardManager.shared.enable = true
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        UserDefaultsManager.shared.notificationToken = token
        if AppManager.IsAuthenticated(),let user = UserDefaultsManager.shared.loginUser {
            ApiManager.shared.postRequest(endPoint: "/users/\(user.id)/updateAPNS", params: ["token":token], completionHandler: {(result:Result<User,Error>) in })
        }
        print(#line,#function,"Device Token: \(token)")
    };

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(#line,#function,error.localizedDescription)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
            // Process the notification here
        print("Received notification while app is in the background:", userInfo)
        completionHandler(.newData) // Indicate the result of the background fetch
    }

        // Handle notification tap (optional)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if let type = response.notification.request.content.userInfo["type"] as? String, let castType = NotificationType(rawValue: type) {
            NotificationCenter.default.post(name: .didReceiveNotification, object: nil, userInfo: ["type": castType])
        }
        
        completionHandler()
    }
}

extension Notification.Name {
    static let didReceiveNotification = Notification.Name("didReceiveNotification")
}

enum notificationType:String, Codable {
    case timeline = "timeline"
    case post = "post"
    case comment = "comment"
    case liked = "liked"
    case message = "message"
    case followed = "followed"
//
}
