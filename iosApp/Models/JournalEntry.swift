import Foundation

struct JournalEntry: Identifiable, Codable {
    var id: String
    var text: String
    var date: Date
    var monthID: String
    
    init(id: String, text: String, date: Date, monthID: String) {
        self.id = id
        self.text = text
        self.date = date
        self.monthID = monthID
    }
}
