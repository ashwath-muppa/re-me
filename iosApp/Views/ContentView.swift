import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Journal", systemImage: "book.fill")
                }
            
            JournalView()
                .tabItem {
                    Label("New Entry", systemImage: "square.and.pencil")
                }
            
            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "message.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .accentColor(Color("#6DD3B2"))  // Remove 'hex:' label
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}