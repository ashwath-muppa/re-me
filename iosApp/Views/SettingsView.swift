//
//  SettingsView.swift
//  iosApp
//
//  Created by Varun Ananthakrishnan on 5/17/25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Response Mode")) {
                    Picker("Response Mode", selection: $viewModel.responseMode) {
                        Text("Text").tag("text")
                        Text("Voice").tag("voice")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
