//
//  NotificationsView.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI

struct NotificationsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject  var viewModel:NotificationViewModel = NotificationViewModel()
    @Binding var scrollToTop: Bool
    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                List {
                    ForEach(Array(viewModel.notification.enumerated()), id: \.element.id) { index, notification in
                        NotificationCell(notification: $viewModel.notification[index])
                            .background(notification.status ? Color.white : Color(.systemGray6))
                            .onTapGesture {
                                makeRead(notification: notification)
                            }
                            .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: index == viewModel.notification.count - 1 ? 0 : 10, trailing: 0))
                            .listRowSeparator(.hidden)
                    }
//                    GeometryReader { geometry in
//                        Color.clear.onAppear {
//                            viewModel.currentPage += 1
//                            viewModel.getNotifications()
//                        }
//                    }
//                    .frame(height: 1)

                }
                .listStyle(.plain)
                .listRowSpacing(10)
                .onChange(of: scrollToTop) {
                    withAnimation {
                        if let notification = viewModel.notification.first {
                            proxy.scrollTo(notification.id, anchor: .bottom)
                        }
                    }
                }
            }
            .navigationBarTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .padding(.top)
            .navigationBarItems(leading: backButton)
            .onAppear {
                viewModel.getNotifications()
                viewModel.makeReadAll()
            }
        }
    }
    
    private func makeRead(notification: NotificationModel) {
        viewModel.makeRead(notificationId: notification.id, read: true)
    }

    var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.black)
                .font(.system(size: 18))
        }
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView(scrollToTop: Binding<Bool>.constant(true))
    }
}
