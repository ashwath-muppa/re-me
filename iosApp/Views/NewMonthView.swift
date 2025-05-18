import SwiftUI

struct NewMonthView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = JournalViewModel()
    @State private var selectedMonth = Date()
    @State private var showingMonthPicker = false
    var onSave: (() -> Void)?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Create a New Month")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // Month selector
                Button(action: {
                    showingMonthPicker = true
                }) {
                    HStack {
                        Text("Month: \(formatMonth(selectedMonth))")
                            .font(.headline)
                        Spacer()
                        Image(systemName: "calendar")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Create button
                Button(action: {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM"
                    let monthID = formatter.string(from: selectedMonth)
                    viewModel.addEmptyMonth(monthID)
                    onSave?()
                    presentationMode.wrappedValue.dismiss()
                    
                    // Use NotificationCenter instead of direct casting
                    NotificationCenter.default.post(name: NSNotification.Name("RefreshChatMonths"), object: nil)
                }) {
                    Text("Create Month")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("#6DD3B2"))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .disabled(isFutureMonth(selectedMonth))
            }
            .navigationTitle("New Month")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $showingMonthPicker) {
                VStack {
                    MonthYearPicker(selection: $selectedMonth)
                        .padding()
                    
                    Button("Done") {
                        showingMonthPicker = false
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("#6DD3B2"))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .disabled(isFutureMonth(selectedMonth))
                }
                .padding()
            }
        }
    }
    
    // Helper function to format month
    func formatMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"  // Show both month and year
        return formatter.string(from: date)
    }
    
    // Helper function to check if a month is in the future
    func isFutureMonth(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let currentComponents = calendar.dateComponents([.year, .month], from: Date())
        let selectedComponents = calendar.dateComponents([.year, .month], from: date)
        
        if let currentYear = currentComponents.year, let currentMonth = currentComponents.month,
           let selectedYear = selectedComponents.year, let selectedMonth = selectedComponents.month {
            
            if selectedYear > currentYear {
                return true
            } else if selectedYear == currentYear && selectedMonth > currentMonth {
                return true
            }
        }
        
        return false
    }
}

// Custom Month Year Picker
struct MonthYearPicker: View {
    @Binding var selection: Date
    
    @State private var selectedYear: Int
    @State private var selectedMonth: Int
    
    private let months = Calendar.current.monthSymbols
    private let years: [Int]
    
    init(selection: Binding<Date>) {
        self._selection = selection
        
        let calendar = Calendar.current
        let currentComponents = calendar.dateComponents([.month, .year], from: selection.wrappedValue)
        
        self._selectedMonth = State(initialValue: (currentComponents.month ?? 1) - 1)
        
        // Set initial year from the date, defaulting to current year if not available
        let initialYear = currentComponents.year ?? Calendar.current.component(.year, from: Date())
        self._selectedYear = State(initialValue: initialYear)
        
        // Generate years from 1869 to current year (or 2025, whichever is less)
        let currentYear = min(Calendar.current.component(.year, from: Date()), 2025)
        self.years = Array(1869...currentYear)
    }
    
    var body: some View {
        VStack {
            Text("Select Month and Year")
                .font(.headline)
                .padding(.bottom)
            
            HStack {
                Picker("Month", selection: $selectedMonth) {
                    ForEach(0..<months.count, id: \.self) { index in
                        Text(months[index]).tag(index)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 150, height: 150)
                .clipped()
                
                Picker("Year", selection: $selectedYear) {
                    ForEach(years, id: \.self) { year in
                        Text(String(year)).tag(year)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 150, height: 150)
                .clipped()
            }
            // Replace the deprecated onChange with the new version
            .onChange(of: selectedMonth) { _, _ in 
                updateDate()
            }
            .onChange(of: selectedYear) { _, _ in 
                updateDate()
            }
        }
    }
    
    private func updateDate() {
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth + 1
        components.day = 1
        
        if let date = Calendar.current.date(from: components) {
            selection = date
        }
    }
}