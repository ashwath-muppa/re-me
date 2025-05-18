import SwiftUI

struct JournalView: View {
    @StateObject private var viewModel = JournalViewModel()
    @State private var showingNewEntrySheet = false
    @State private var showingNewMonthSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                journalListView
            }
        }
    }
    
    private var journalListView: some View {
        List {
            if viewModel.sortedMonths.isEmpty {
                Text("No journal entries yet")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ForEach(viewModel.sortedMonths, id: \.self) { month in
                    Section(header: Text(formatMonthHeader(month))) {
                        let entries = viewModel.groupedByMonth[month] ?? []
                        if entries.isEmpty {
                            Text("No entries")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(entries) { entry in
                                NavigationLink(destination: JournalEntryDetailView(entry: entry)) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(formatDate(entry.date))
                                            .font(.headline)
                                        Text(entry.text.prefix(50) + (entry.text.count > 50 ? "..." : ""))
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Floating action buttons
    var floatingActionButtons: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack(spacing: 16) {
                    // New Month button
                    Button(action: {
                        showingNewMonthSheet = true
                    }) {
                        VStack {
                            Image(systemName: "calendar.badge.plus")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color("#6DD3B2")) // Removed 'hex:' label
                                .clipShape(Circle())
                                .shadow(radius: 4)
                            Text("New Month")
                                .font(.caption)
                                .foregroundColor(Color("#6DD3B2")) // Removed 'hex:' label
                        }
                    }
                    
                    // New Entry button
                    Button(action: {
                        showingNewEntrySheet = true
                    }) {
                        VStack {
                            Image(systemName: "square.and.pencil")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color("#6DD3B2")) // Removed 'hex:' label
                                .clipShape(Circle())
                                .shadow(radius: 4)
                            Text("New Entry")
                                .font(.caption)
                                .foregroundColor(Color("#6DD3B2")) // Removed 'hex:' label
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    // Helper function to format month header
    func formatMonthHeader(_ monthID: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        if let date = dateFormatter.date(from: monthID) {
            dateFormatter.dateFormat = "MMMM yyyy"  // Show both month and year
            return dateFormatter.string(from: date)
        }
        return monthID
    }
    
    // Helper function to format date
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// Detail view for a journal entry
struct JournalEntryDetailView: View {
    let entry: JournalEntry
    @State private var showingEditSheet = false
    @StateObject private var viewModel = JournalViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(formatDate(entry.date))
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                Text(entry.text)
                    .padding()
            }
            .padding()
        }
        .navigationTitle("Journal Entry")
        .navigationBarItems(trailing: Button("Edit") {
            showingEditSheet = true
        })
        .sheet(isPresented: $showingEditSheet) {
            EditJournalEntryView(entry: entry, onSave: {
                // Refresh the view model and dismiss the detail view to show updated entry
                viewModel.loadJournalEntries()
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    // Helper function to format date
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}
