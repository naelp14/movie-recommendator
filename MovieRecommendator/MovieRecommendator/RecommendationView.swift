//
//  RecommendationView.swift
//  MovieRecommendator
//
//  Created by Nathaniel Putera on 18/09/25.
//

import SwiftUI

struct RecommendationData: Hashable {
    let selectedMovie: String
    let recommendations: [String]
}

struct RecommendationView: View {
    var data: RecommendationData
    
    var body: some View {
        VStack {
            Text("Because you liked:")
                .font(.headline)
            Text(movie)
                .font(.title2)
                .padding(.bottom, 20)
            
            List(recommendations, id: \.self) { rec in
                Text(rec)
            }
        }
        .padding()
    }
}
