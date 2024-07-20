//
//  ChatliqstresponstElement.swift
//  lgcy
//
//  Created by Adnan Majeed on 29/02/2024.
//

import Foundation
import UIKit

enum MessageReceiverType: Codable, Equatable {
    case messageReceiver(MessageReceiver)
    case string(String)
    case creator(Creator)
    
    // Custom decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let messageReceiver = try? container.decode(MessageReceiver.self) {
            self = .messageReceiver(messageReceiver)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let creator = try? container.decode(Creator.self) {
            self = .creator(creator)
        } else {
            throw DecodingError.typeMismatch(MessageReceiverType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Cannot decode MessageReceiverType"))
        }
    }
    
    // Custom encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .messageReceiver(let messageReceiver):
            try container.encode(messageReceiver)
        case .string(let string):
            try container.encode(string)
        case .creator(let creator):
            try container.encode(creator)
        }
    }
}

class ChatListResponse: Codable,Equatable {
    static func == (lhs: ChatListResponse, rhs: ChatListResponse) -> Bool {
        return lhs.id == rhs.id
    }
    var messages: [Message]
    var receiver, sender: Creator
    var createdAt, id: String
    var blocker: String?
    init(messages: [Message], receiver: Creator, sender: Creator, createdAt: String, id: String, blocker: String?) {
        self.messages = messages
        self.receiver = receiver
        self.sender = sender
        self.createdAt = createdAt
        self.id = id
        self.blocker = blocker
    }

    var otherUser:Creator {
        if sender.id == UserDefaultsManager.shared.loginUser?.id {
            return receiver
        }
        return sender
    }
}

class Blocker: Codable {
    var blocker: String?
    init(blocker: String?) {
        self.blocker = blocker
    }
}

    // MARK: - Message
class Message: Codable,Equatable {
    static func == (lhs: Message, rhs: Message) -> Bool {
     return lhs.id == rhs.id
    }

    var text, createdAt, id: String
    var receiver: MessageReceiverType
    var sender:Creator
    var isSeen:Bool
    var file: ImageDTO?
    var data: UIImage?
    var dataType: String?

    enum CodingKeys: String, CodingKey {
        case text, createdAt
        case id = "_id"
        case receiver, sender
        case isSeen
        case file
    }

    init(text: String, createdAt: String, id: String, receiver: MessageReceiverType, sender: Creator, file: ImageDTO?, data: UIImage? = UIImage(), dataType: String? = "") {
        self.text = text
        self.createdAt = createdAt
        self.id = id
        self.receiver = receiver
        self.sender = sender
        self.isSeen = false
        self.file = file
        self.data = data
        self.dataType = dataType
    }

    var isSentByUser:Bool {
        if sender.id == UserDefaultsManager.shared.loginUser?.id {
            return true
        }
        return false
    }
}

// MARK: - Receiver
class Receiver: Codable {
    var name: String
    var image: ImageDTO
    var id: String

    init(name: String, image: ImageDTO, id: String) {
        self.name = name
        self.image = image
        self.id = id
    }
}
