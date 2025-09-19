//
//  HomeView.swift
//  MovieRecommendator
//
//  Created by Nathaniel Putera on 18/09/25.
//

import SwiftUI

struct HomeView: View {
    private let viewModel = HomeViewModel()
    @State private var searchText: String = ""
    @State private var selectedMovie: String? = nil
    @State private var movies: [String] = []
    @State private var filteredMovies: [String] = []
    @State private var debounceTimer: Timer?
    @State private var isLoading = false
    
    // For Error
    @State private var showError = false
    @State private var errorMessage = ""
    
    // Navigation
    @State private var path: [RecommendationData] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                searchBar
                movieList
                Spacer()
                getRecommendationButton
            }
            .onAppear(perform: {
                movies = viewModel.loadMoviesFromCSV(named: "movies")
                filteredMovies = movies
            })
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .navigationDestination(for: RecommendationData.self) { data in
                RecommendationView(data: data)
            }
        }
    }
    
    private var searchBar: some View {
        TextField("Search", text: $searchText)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            .onChange(of: searchText) { _, newValue in
                debounceTimer?.invalidate()
                
                debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                    if newValue.isEmpty {
                        filteredMovies = movies
                    } else {
                        filteredMovies = movies.filter { $0.localizedCaseInsensitiveContains(newValue) }
                    }
                }
            }
    }
    
    private var movieList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach(filteredMovies, id: \.self) { movie in
                    HStack {
                        Text(movie)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                selectedMovie == movie ? Color.blue.opacity(0.2) : Color.clear
                            )
                            .cornerRadius(8)
                        
                        if selectedMovie == movie {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                                .padding(.trailing)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedMovie = movie
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var getRecommendationButton: some View {
        Button {
            if let movie = selectedMovie {
                viewModel.fetchRecommendations(for: movie, completion: {
                    list, error in
                    if let error {
                        showError = true
                        errorMessage = error.localizedDescription
                    } else if let list {
                        path.append(
                            RecommendationData(
                                selectedMovie: movie,
                                recommendations: list
                            )
                        )
                    }
                })
            }
        } label: {
            if isLoading {
                ProgressView("Loading...")
            } else {
                Text("Get Recommendations")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedMovie == nil ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .disabled(selectedMovie == nil)
    }
}

#Preview {
    HomeView()
}
