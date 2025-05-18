import Foundation

class PythonBridge {
    static var baseURL = "http://127.0.0.1:5000"
    
    static func chat(inputText: String, inputType: String, responseMode: String, month: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: "\(baseURL)/chat") else {
            completion("Error: Invalid URL")
            return
        }
        
        let parameters: [String: Any] = [
            "input": inputText,
            "input_type": inputType,
            "response_mode": responseMode,
            "month": month
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            completion("Error: \(error.localizedDescription)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion("Error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    completion("Error: No data received")
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let response = json["response"] as? String {
                        completion(response)
                    } else {
                        completion("Error: Invalid response format")
                    }
                } catch {
                    completion("Error parsing response: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}