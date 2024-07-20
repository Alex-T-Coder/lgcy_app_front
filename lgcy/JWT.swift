//
//  JWT.swift
//  lgcy
//
//  Created by Vlad on 31.01.24.
//

import Foundation

func base64StringWithPadding(encodedString: String) -> String {
    var stringTobeEncoded = encodedString.replacingOccurrences(of: "-", with: "+")
        .replacingOccurrences(of: "_", with: "/")
    let paddingCount = encodedString.count % 4
    for _ in 0..<paddingCount {
        stringTobeEncoded += "="
    }
    return stringTobeEncoded
}

func decodeJWTPart(part: String) -> [String: Any]? {
    let payloadPaddingString = base64StringWithPadding(encodedString: part)
    guard let payloadData = Data(base64Encoded: payloadPaddingString) else {
        fatalError("payload could not converted to data")
    }
        return try? JSONSerialization.jsonObject(
        with: payloadData,
        options: []) as? [String: Any]
}

func decodeJWT(jwt: String) throws -> [String: Any]? {
    let parts = jwt.components(separatedBy: ".")

    if parts.count != 3 { throw  ErrorResponse.init(code: 500, message: "invalid User Session", stack: nil) }

    let header = parts[0]
    let payload = parts[1]
    let signature = parts[2]
    
    return decodeJWTPart(part: payload )
}

func isExpired(token: String) throws -> Bool {
    let payload = try decodeJWT(jwt: token)
    let exp = payload!["exp"] as! Int
    let expDate = Date(timeIntervalSince1970: TimeInterval(exp))
    let isExpired = expDate < Date()
    
    return isExpired
}
