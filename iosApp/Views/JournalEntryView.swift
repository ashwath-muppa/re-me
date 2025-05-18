import SwiftUI

struct JournalEntryView: View {
    @StateObject private var viewModel = JournalViewModel()
    @State private var entryText = ""
    @State private var selectedDate = Date()
    @Environment(\.presentationMode) var presentationMode
    var onSave: (() -> Void)?
    
    var body: some View {
        NavigationView {
            VStack {
                // Date display
                Text(formattedDate)
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                
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
                
                // Submit button
                Button(action: {
                    viewModel.entryText = entryText
                    viewModel.entryDate = selectedDate
                    viewModel.submitEntry {
                        entryText = ""
                        onSave?()
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text("Submit Entry")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .disabled(entryText.isEmpty)
            }
            .navigationTitle("New Journal Entry")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: selectedDate)
    }
}

struct JournalEntryView_Previews: PreviewProvider {
    static var previews: some View {
        JournalEntryView()
    }
}