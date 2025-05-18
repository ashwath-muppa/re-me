//
//  PythonBridge.swift
//  iosApp
//
//  Created by Varun Ananthakrishnan on 5/17/25.
//

import Foundation

class PythonBridge {
    static let baseURL = "http://127.0.0.1:5000" // Replace with IP for device testing

    static func sendJournal(id: Int, entry: String, date: Date, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/add_journal") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let json: [String: Any] = [
            "id": id,
            "entry": entry,
            "date": formatter.string(from: date)
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: json)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { _, response, _ in
            let success = (response as? HTTPURLResponse)?.statusCode == 200
            DispatchQueue.main.async {
                completion(success)
            }
        }.resume()
    }

    static func chat(inputText: String, inputType: String, responseMode: String, month: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: "\(baseURL)/chat") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let body: [String: Any] = [
            "text": inputText,
            "input_type": inputType,
            "response_mode": responseMode,
            "journal_num": month  // Using journal_num instead of month
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion("Error: \(error.localizedDescription)")
                }
                return
            }
                
            if let data = data,
               let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let response = result["response"] as? String
                    ?? result["audio_url"] as? String
                    ?? result["video_url"] as? String
                    ?? "No response"
                DispatchQueue.main.async {
                    completion(response)
                }
            } else {
                DispatchQueue.main.async {
                    completion("Failed to parse response")
                }
            }
        }.resume()
    }
}
