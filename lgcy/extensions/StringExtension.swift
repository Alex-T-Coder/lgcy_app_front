//
//  StringExtension.swift
//  lgcy
//
//  Created by Adnan Majeed on 23/02/2024.
//

import Foundation
extension String {
    var agoFormatString:String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // Adjust the format according to your date string
        guard let date = dateFormatter.date(from: self) else {
            print(self)
            return self
        }
        print(formatter.localizedString(for: date, relativeTo: Date()))
        return formatter.localizedString(for: date, relativeTo: Date())
    }


    var isValidEmail:Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
         let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)

    }

    var isValidUsername:Bool {
        let usernameRegex = "^[a-zA-Z0-9_-]{3,16}$"
         let userNamePred = NSPredicate(format:"SELF MATCHES %@", usernameRegex)
        return userNamePred.evaluate(with: self)

    }

    var isValidPassword: Bool {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: self)
    }

    var isValidMobileNumber: Bool {
        let mobileNumberRegex = "^[0-9]{10,14}$"
         let mobileNumberPredicate = NSPredicate(format: "SELF MATCHES %@", mobileNumberRegex)
            return mobileNumberPredicate.evaluate(with: self)

    }
}
