//
//  HomeViewModel.swift
//  MovieRecommendator
//
//  Created by Nathaniel Putera on 18/09/25.
//

import Foundation

final class HomeViewModel {
    func fetchRecommendations(for title: String, completion: @escaping(([String]?, Error?) -> Void)) {
        guard let url = URL(string: "http://127.0.0.1:8000/recommendations") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Send JSON body { "title": "Toy Story (1995)" }
        let body: [String: Any] = ["title": title]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                print("data nil")
                completion(nil, nil)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(Recommendations.self, from: data)
                completion(result.recommendations, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    
    func loadMoviesFromCSV(named fileName: String) -> [String] {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "csv") else { return [] }
        do {
            let data = try String(contentsOfFile: path, encoding: .utf8)
            let rows = data.components(separatedBy: "\n")
            
            // Assuming CSV format: movieId,title,genres
            return rows.dropFirst().compactMap { row in
                let cols = row.components(separatedBy: ",")
                if cols.count > 1 {
                    // Trim spaces & quotes around title
                    return cols[1].trimmingCharacters(in: CharacterSet(charactersIn: "\" "))
                }
                return nil
            }
        } catch {
            print("Error loading CSV: \(error)")
            return []
        }
    }
}
