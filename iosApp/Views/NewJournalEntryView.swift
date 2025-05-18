import SwiftUI

struct NewJournalEntryView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = JournalViewModel()
    @State private var entryText = ""
    @State private var selectedDate = Date()
    @State private var selectedMonthID = ""
    @State private var showingDatePicker = false
    @State private var showingMonthPicker = false
    @State private var showingNewMonthSheet = false
    @State private var showingNoMonthsAlert = false
    var onSave: (() -> Void)?
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.sortedMonths.isEmpty {
                    // Display message when no months exist
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 60))
                            .foregroundColor(Color("#6DD3B2"))
                        
                        Text("No Months Available")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("You need to create a month before adding journal entries.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        Button(action: {
                            showingNewMonthSheet = true
                        }) {
                            Text("Create New Month")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("#6DD3B2"))  // Remove 'hex:' label
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        Spacer()
                    }
                    .padding()
                } else {
                    // Regular journal entry form when months exist
                    // Month selector
                    Button(action: {
                        showingMonthPicker = true
                    }) {
                        HStack {
                            Text("Month: \(formatMonthFromID(selectedMonthID))")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "chevron.down")
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                    
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
                    
                    // Upload button
                    Button(action: {
                        viewModel.entryText = entryText
                        viewModel.entryDate = selectedDate
                        
                        // Override the month ID if a specific one is selected
                        if !selectedMonthID.isEmpty {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd"
                            let dayString = formatter.string(from: selectedDate)
                            
                            // Extract just the day part
                            let dayPart = String(dayString.suffix(2))
                            
                            // Create a new date with the selected month and the day from selectedDate
                            formatter.dateFormat = "yyyy-MM-dd"
                            if let newDate = formatter.date(from: "\(selectedMonthID)-\(dayPart)") {
                                viewModel.entryDate = newDate
                            }
                        }
                        
                        viewModel.submitEntry {
                            onSave?()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Text("Upload Entry")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("#6DD3B2"))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .disabled(entryText.isEmpty)
                }
            }
            .navigationTitle("New Journal Entry")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                viewModel.loadJournalEntries()
                
                // If no months exist and we're not showing the create month sheet,
                // show the no months alert
                if viewModel.sortedMonths.isEmpty && !showingNewMonthSheet {
                    showingNoMonthsAlert = true
                }
                
                // If months exist, set the selected month to the most recent month
                if let lastMonth = viewModel.sortedMonths.first {
                    selectedMonthID = lastMonth
                    
                    // Set the date to be within the selected month
                    if let date = monthIDToDate(lastMonth) {
                        selectedDate = date
                    }
                }
            }
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
            .actionSheet(isPresented: $showingMonthPicker) {
                var buttons: [ActionSheet.Button] = []
                
                // Add buttons for existing months
                for month in viewModel.sortedMonths.sorted() {
                    buttons.append(.default(Text(formatMonthFromID(month))) {
                        selectedMonthID = month
                        
                        // Update the date to be within the selected month
                        if let date = monthIDToDate(month) {
                            // Keep the same day, just change the month and year
                            let calendar = Calendar.current
                            let day = calendar.component(.day, from: selectedDate)
                            
                            var components = calendar.dateComponents([.year, .month], from: date)
                            components.day = day
                            
                            if let newDate = calendar.date(from: components) {
                                selectedDate = newDate
                            } else {
                                selectedDate = date
                            }
                        }
                    })
                }
                
                // Add button to create new month
                buttons.append(.default(Text("Create New Month")) {
                    showingNewMonthSheet = true
                })
                
                buttons.append(.cancel())
                
                return ActionSheet(
                    title: Text("Select Month"),
                    message: Text("Choose an existing month or create a new one"),
                    buttons: buttons
                )
            }
            .sheet(isPresented: $showingNewMonthSheet) {
                NewMonthView(onSave: {
                    viewModel.loadJournalEntries()
                    // Update the selected month to the newly created month
                    if let lastMonth = viewModel.sortedMonths.first {
                        selectedMonthID = lastMonth
                        
                        // Set the date to be within the selected month
                        if let date = monthIDToDate(lastMonth) {
                            selectedDate = date
                        }
                    }
                })
            }
        }
    }
    
    // Helper function to format date
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
    
    // Helper function to format month from ID
    func formatMonthFromID(_ monthID: String) -> String {
        if monthID.isEmpty {
            return "Select a Month"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        if let date = dateFormatter.date(from: monthID) {
            dateFormatter.dateFormat = "MMMM yyyy"  // Show both month and year
            return dateFormatter.string(from: date)
        }
        return monthID
    }
    
    // Helper function to convert month ID to date
    func monthIDToDate(_ monthID: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        return dateFormatter.date(from: monthID)
    }
}