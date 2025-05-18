import Foundation
import SwiftUI

public class ChatViewModel: ObservableObject {
    @Published public var messages: [ChatMessage] = []
    @Published public var input: String = ""
    @Published public var availableMonths: [String] = []
    @Published public var selectedMonthString: String = ""
    
    public init() {
        loadAvailableMonths()
    }
    
    public func loadAvailableMonths() {
        guard let savedJournals = UserDefaults.standard.data(forKey: "journals"),
              let loadedJournals = try? JSONDecoder().decode([JournalEntry].self, from: savedJournals) else {
            return
        }
        let monthIDs = Set(loadedJournals.map { $0.monthID })
        availableMonths = Array(monthIDs).sorted(by: >)
    }
    
    public func sendChat(responseMode: String) {
        let userMessage = ChatMessage(text: input, isUser: true, timestamp: Date(), month: selectedMonthString)
        messages.append(userMessage)
        
        PythonBridge.chat(inputText: input, inputType: "text", responseMode: responseMode, month: selectedMonthString) { [weak self] response in
            DispatchQueue.main.async {
                guard let self = self else { return }
                // If response is non-optional String, use directly:
                let responseMessage = ChatMessage(text: response, isUser: false, timestamp: Date(), month: self.selectedMonthString)
                self.messages.append(responseMessage)
            }
        }
    }
    
    public func messagesForSelectedMonth() -> [ChatMessage] {
        return messages.filter { message in
            if let messageMonth = message.month {
                return messageMonth == selectedMonthString
            }
            return true // Include messages with nil month
        }
    }
}
