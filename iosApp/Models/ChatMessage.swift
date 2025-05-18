// File: Models/ChatMessage.swift

import Foundation

public struct ChatMessage: Identifiable {
    public let id: String
    public let text: String
    public let isUser: Bool
    public let timestamp: Date
    public let month: String?
    
    public init(text: String, isUser: Bool, timestamp: Date, month: String?) {
        self.id = UUID().uuidString
        self.text = text
        self.isUser = isUser
        self.timestamp = timestamp
        self.month = month
    }
}
