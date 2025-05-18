import SwiftUI

struct EditJournalEntryView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = JournalViewModel()
    @State private var entryText: String
    @State private var selectedDate: Date
    @State private var showingDatePicker = false
    let entry: JournalEntry
    var onSave: (() -> Void)?
    
    init(entry: JournalEntry, onSave: (() -> Void)? = nil) {
        self.entry = entry
        self._entryText = State(initialValue: entry.text)
        self._selectedDate = State(initialValue: entry.date)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Date selector
                Button(action: {
                    showingDatePicker = true
                }) {
                    HStack {
                        Text("Date: \(formatDate(selectedDate))")
                            .font(.headline)
                        Spacer()
                        Image(systemName: "calendar")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                
                // Journal entry text area
                TextEditor(text: $entryText)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .padding()
                
                // Save button
                Button(action: {
                    // Update the entry
                    viewModel.updateEntry(entry: entry, newText: entryText, newDate: selectedDate)
                    onSave?()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save Changes")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("#6DD3B2"))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .disabled(entryText.isEmpty)
            }
            .navigationTitle("Edit Journal Entry")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $showingDatePicker) {
                VStack {
                    DatePicker(
                        "Select a date",
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                    
                    Button("Done") {
                        showingDatePicker = false
                    }
                    .padding()
                }
            }
            .onAppear {
                viewModel.loadJournalEntries()
            }
        }
    }
    
    // Helper function to format date
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}