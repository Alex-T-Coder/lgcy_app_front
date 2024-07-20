//
//  TimeUtility.swift
//  lgcy
//
//  Created by Evan Boymel on 7/10/24.
//

import Foundation

class TimeUtility {
    static func formatDate(dateString: String) -> String {
        // Create a DateFormatter to parse the input string
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        inputFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Set the time zone to GMT

        // Convert the string to a Date object
        if let date = inputFormatter.date(from: dateString) {
            // Create another DateFormatter to format the Date object
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "MMMM dd, yyyy"
            
            // Convert the Date object to the desired output string
            let formattedDateString = outputFormatter.string(from: date)
            
            // Print the formatted date string
            return formattedDateString
        } else {
            return "Invalid date string"
        }
    }
}
