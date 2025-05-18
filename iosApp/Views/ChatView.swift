import SwiftUI

struct ChatView: View {
    @StateObject private var chatViewModel = ChatViewModel()
    @State private var messageText = ""
    @State private var selectedMonthYear = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack {
            // Title and subtitle
            VStack(alignment: .leading) {
                Text("Chat with Your(past)self")
                    .font(.title2) // Smaller title
                    .bold()
                    .padding(.top)
                
                Text("Select a month/year to chat with your past self.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom)
            }
            .padding(.horizontal)

            // Month/Year selector
            Picker("Select Month/Year", selection: $selectedMonthYear) {
                ForEach(chatViewModel.availableMonths, id: \.self) { monthYear in
                    Text(formatMonthHeader(monthYear)).tag(monthYear)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding(.horizontal)

            // Messages list
            // Update the ForEach to use chatViewModel.messages
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(chatViewModel.messagesForSelectedMonth()) { message in
                        MessageBubble(message: message)
                    }
                }
                .padding()
            }
            
            // Input area
            HStack {
                TextField("Type a message...", text: $messageText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                
                Button(action: {
                    guard !messageText.isEmpty else { return }
                    guard selectedMonthYear.isEmpty == false else {
                        // Show alert or message that month must be selected
                        return
                    }
                    chatViewModel.input = messageText
                    chatViewModel.selectedMonthString = selectedMonthYear
                    chatViewModel.sendChat(responseMode: "text")
                    messageText = ""
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(Color("#6DD3B2"))  // Removed 'hex:' label
                }
            }
            .padding()
        }
        .navigationTitle("Chat")
        .onAppear {
            chatViewModel.loadAvailableMonths()
            
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("RefreshChatMonths"),
                object: nil,
                queue: .main) { _ in
                    chatViewModel.loadAvailableMonths()
                }
        }
        .alert("Connection Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                Text(message.text)
                    .padding(12)
                    .background(Color("#6DD3B2"))  // Removed 'hex:' label
                    .foregroundColor(.black)
                    .cornerRadius(16)
                    .padding(.leading, 60)
            } else {
                Text(message.text)
                    .padding(12)
                    .background(Color(.systemGray5))
                    .foregroundColor(.black)
                    .cornerRadius(16)
                    .padding(.trailing, 60)
                Spacer()
            }
        }
    }
}

// Update ChatMessageModel to match ChatMessage
struct ChatMessageModel: Identifiable {
    let id: String
    let text: String
    let isUser: Bool
    let timestamp: Date
    let month: String?
    
    init(from chatMessage: ChatMessage) {
        self.id = chatMessage.id
        self.text = chatMessage.text
        self.isUser = chatMessage.isUser
        self.timestamp = chatMessage.timestamp
        self.month = chatMessage.month
    }
}


// Add the missing functions
private func formatMonthHeader(_ monthID: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM"
    if let date = dateFormatter.date(from: monthID) {
        dateFormatter.dateFormat = "MMMM yyyy"  // Show both month and year
        return dateFormatter.string(from: date)
    }
    return monthID
}
