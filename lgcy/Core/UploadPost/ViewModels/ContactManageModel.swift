//
//  ContactManageModel.swift
//  lgcy
//
//  Created by Evan Boymel on 6/28/24.
//

import Foundation
import Contacts
import SwiftUI

class ContactManageModel: ObservableObject {
    @Published var contacts: [CNContact] = []

    private let store = CNContactStore()

    func fetchContacts(completion: @escaping ([CNContact]?, Error?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            switch CNContactStore.authorizationStatus(for: .contacts) {
            case .authorized:
                do {
                    let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
                    let request = CNContactFetchRequest(keysToFetch: keys)
                    
                    var contacts: [CNContact] = []
                    try self.store.enumerateContacts(with: request) { (contact, stop) in
                        contacts.append(contact)
                    }
                    DispatchQueue.main.async {
                        completion(contacts, nil)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            case .denied:
                DispatchQueue.main.async {
                    completion(nil, NSError(domain: "CNContactStore", code: 1, userInfo: [NSLocalizedDescriptionKey: "Access denied"]))
                }
            case .notDetermined:
                self.store.requestAccess(for: .contacts) { granted, error in
                    if granted {
                        self.fetchContacts(completion: completion)
                    } else {
                        DispatchQueue.main.async {
                            completion(nil, NSError(domain: "CNContactStore", code: 1, userInfo: [NSLocalizedDescriptionKey: "Access denied"]))
                        }
                    }
                }
            case .restricted:
                DispatchQueue.main.async {
                    completion(nil, NSError(domain: "CNContactStore", code: 1, userInfo: [NSLocalizedDescriptionKey: "Access restricted"]))
                }
            @unknown default:
                break
            }
        }
    }
}
