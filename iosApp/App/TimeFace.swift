//
//  TimeFace.swift
//  iosApp
//
//  Created by Varun Ananthakrishnan on 5/17/25.
//

import SwiftUI

struct TimeFace: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            JournalView()
                .tabItem {
                    Label("Journal", systemImage: "book.fill")
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
        .onAppear {
            // Set the tab bar background color
            let appearance = UITabBarAppearance()
            appearance.backgroundColor = UIColor.systemBackground
            
            // Set the selected item color to match the app's theme
            let themeColor = UIColor(red: 109/255, green: 211/255, blue: 178/255, alpha: 1.0) // #6DD3B2
            appearance.stackedLayoutAppearance.selected.iconColor = themeColor
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: themeColor]
            
            // Apply the appearance
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}
