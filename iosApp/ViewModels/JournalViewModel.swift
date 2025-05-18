import Foundation

class JournalViewModel: ObservableObject {
    @Published var entryText: String = ""
    @Published var entryDate: Date = Date()
    @Published var journalText: String = ""
    @Published var selectedDate: Date = Date()
    @Published var entries: [JournalEntry] = []
    @Published var groupedByMonth: [String: [JournalEntry]] = [:]
    @Published var sortedMonths: [String] = []
    
    init() {
        loadJournalEntries()
    }
    
    func loadJournalEntries() {
        // Load journal entries
        if let savedJournals = UserDefaults.standard.object(forKey: "journals") as? Data {
            let decoder = JSONDecoder()
            if let loadedJournals = try? decoder.decode([JournalEntry].self, from: savedJournals) {
                self.entries = loadedJournals
                
                // Group entries by month
                self.groupedByMonth = Dictionary(grouping: loadedJournals) { entry in
                    return entry.monthID
                }
            }
        }
        
        // Load months (including empty ones)
        if let savedMonths = UserDefaults.standard.stringArray(forKey: "months") {
            // Add any months from saved months that aren't already in groupedByMonth
            for month in savedMonths {
                if groupedByMonth[month] == nil {
                    groupedByMonth[month] = []
                }
            }
        }
        
        // Sort months in descending order (newest first)
        self.sortedMonths = self.groupedByMonth.keys.sorted(by: >)
    }
    
    func loadJournalEntry() {
        // Load journal entry for the selected date if it exists
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: selectedDate)
        
        if let entry = entries.first(where: { formatter.string(from: $0.date) == dateString }) {
            journalText = entry.text
        } else {
            journalText = ""
        }
    }
    
    func submitEntry(completion: @escaping () -> Void) {
        // Create a new journal entry
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        let monthID = formatter.string(from: entryDate)
        
        let newEntry = JournalEntry(
            id: UUID().uuidString,
            text: entryText,
            date: entryDate,
            monthID: monthID
        )
        
        // Add to existing entries
        var updatedEntries = entries
        updatedEntries.append(newEntry)
        
        // Save to UserDefaults
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(updatedEntries) {
            UserDefaults.standard.set(encoded, forKey: "journals")
        }
        
        // Refresh the entries list
        loadJournalEntries()
        
        // Call completion handler
        completion()
    }
    
    func saveJournalEntry() {
        // Similar to submitEntry but uses journalText and selectedDate
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        let monthID = formatter.string(from: selectedDate)
        
        let newEntry = JournalEntry(
            id: UUID().uuidString,
            text: journalText,
            date: selectedDate,
            monthID: monthID
        )
        
        // Add to existing entries
        var updatedEntries = entries
        updatedEntries.append(newEntry)
        
        // Save to UserDefaults
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(updatedEntries) {
            UserDefaults.standard.set(encoded, forKey: "journals")
        }
        
        // Refresh the entries list
        loadJournalEntries()
        
        // Reset the text
        journalText = ""
    }
    
    func addEmptyMonth(_ month: String) {
        // Check if the month is in the future
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        if let monthDate = dateFormatter.date(from: month) {
            let currentDate = Date()
            let calendar = Calendar.current
            let currentComponents = calendar.dateComponents([.year, .month], from: currentDate)
            let monthComponents = calendar.dateComponents([.year, .month], from: monthDate)
            
            if let currentYear = currentComponents.year, let currentMonth = currentComponents.month,
               let monthYear = monthComponents.year, let monthMonth = monthComponents.month {
                
                if monthYear > currentYear || (monthYear == currentYear && monthMonth > currentMonth) {
                    // This is a future month, don't add it
                    return
                }
            }
        }
        
        if !sortedMonths.contains(month) {
            // Add to sorted months
            sortedMonths.append(month)
            sortedMonths.sort(by: >)
            
            // Add empty array for this month
            groupedByMonth[month] = []
            
            // Save to UserDefaults to persist the empty month
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(entries) {
                UserDefaults.standard.set(encoded, forKey: "journals")
                
                // Also save the months separately to ensure they're persisted
                UserDefaults.standard.set(sortedMonths, forKey: "months")
            }
        }
    }
    
    func updateEntry(entry: JournalEntry, newText: String, newDate: Date) {
        // Find the entry to update
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            // Create a new entry with updated values but same ID
            let updatedEntry = JournalEntry(
                id: entry.id,
                text: newText,
                date: newDate,
                monthID: getMonthIDFromDate(newDate)
            )
            
            // Replace the old entry with the updated one
            entries[index] = updatedEntry
            
            // Regroup entries by month
            self.groupedByMonth = Dictionary(grouping: entries) { entry in
                return entry.monthID
            }
            
            // Update sorted months
            self.sortedMonths = self.groupedByMonth.keys.sorted(by: >)
            
            // Save to UserDefaults
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(entries) {
                UserDefaults.standard.set(encoded, forKey: "journals")
            }
        }
    }
    
    // Helper function to get month ID from date
    private func getMonthIDFromDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: date)
    }
}
