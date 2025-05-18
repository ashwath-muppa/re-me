//
//  SettingsViewModel.swift
//  iosApp
//
//  Created by Varun Ananthakrishnan on 5/17/25.
//

import Foundation

class SettingsViewModel: ObservableObject {
    @Published var responseMode: String {
        didSet {
            UserDefaults.standard.set(responseMode, forKey: "responseMode")
        }
    }

    init() {
        self.responseMode = UserDefaults.standard.string(forKey: "responseMode") ?? "text"
    }
}
