import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            JournalEntryView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Journal")
                }
            
            ChatView()
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Chat")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .accentColor(.green)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}