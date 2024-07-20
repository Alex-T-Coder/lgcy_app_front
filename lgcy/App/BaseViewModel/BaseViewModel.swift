//
//  BaseViewModel.swift
//  lgcy
//
//  Created by Adnan Majeed on 19/02/2024.
//

import Foundation
import Combine
import SwiftUI

class BaseViewModel: ObservableObject {
    var apiService = ApiManager.shared
    lazy var cancellableSet: Set<AnyCancellable> = []
    @Published var showAlertDialog = false
    @Published var validationAlert: Bool = false
    @Published var showActivityIndicator: Bool = false
    @State var showValidationAlertForUsername = false
    @Published var validationText: String = "1234" {
        didSet {
            if validationText.isEmpty {
                validationAlert = false
            } else {
                validationAlert = true
            }
        }
    }


}
