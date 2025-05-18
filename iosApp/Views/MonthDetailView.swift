import SwiftUI
import AVFoundation

struct MonthDetailView: View {
    let monthID: String
    @StateObject private var viewModel = JournalViewModel()
    @State private var showingForm = false
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        VStack {
            // Media section
            HStack {
                Text("Month: \(formatMonthHeader(monthID))")
                    .font(.title3).bold()
            
                Spacer()
            
                Button("🔊") {
                    playAudio(for: monthID)
                }
            
                Button("🎙️") {
                    print("Record audio for \(monthID)")
                }
            }
        
            // Live rendering of updated entries
            ForEach(viewModel.groupedByMonth[monthID] ?? []) { journal in
                VStack(alignment: .leading) {
                    Text(journal.text)
                        .foregroundColor(.black)
                    Text(formatDate(journal.date))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
        
            Button(action: {
                showingForm = true
            }) {
                Label("Add Entry", systemImage: "plus")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("#6DD3B2"))
                    .foregroundColor(.black)
                    .cornerRadius(10)
            }
        }
        .padding()
        .navigationTitle(formatMonthHeader(monthID))
        .sheet(isPresented: $showingForm) {
            VStack(spacing: 16) {
                DatePicker("Select Date", selection: $viewModel.entryDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .accentColor(Color("#6DD3B2"))
        
                TextEditor(text: $viewModel.entryText)
                    .frame(height: 200)
                    .padding(8)
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
        
                Button("Submit Entry") {
                    viewModel.submitEntry {
                        showingForm = false
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("#6DD3B2"))
                .cornerRadius(10)
                .foregroundColor(.black)
        
                Spacer()
            }
            .padding()
        }
        .onAppear {
            viewModel.loadJournalEntries()
        }
    }
    
    func playAudio(for month: String) {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let file = path.appendingPathComponent("voices/\(month).m4a")
        guard FileManager.default.fileExists(atPath: file.path) else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: file)
            audioPlayer?.play()
        } catch {
            print("Failed to play audio for \(month):", error)
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
