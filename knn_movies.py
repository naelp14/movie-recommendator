import pandas as pd
from sklearn.preprocessing import MultiLabelBinarizer
from sklearn.neighbors import NearestNeighbors

def read_data():
    df = pd.read_csv("/Users/nathaniel.putera/Projects/Personal/Movie_Recommendations/ml-32m/movies.csv")
    df["genres"] = df["genres"].apply(lambda x: x.split("|"))
    return df

def preprocess(data_frame):
    mlb = MultiLabelBinarizer()
    genre_matrix = mlb.fit_transform(data_frame["genres"])
    return mlb, genre_matrix

def train_knn(data_matrix):
    knn = NearestNeighbors(metric="cosine", algorithm="brute")
    knn.fit(data_matrix)
    return knn

def prepare():
    data = read_data()
    mlb, matrix = preprocess(data)

    genre_df = pd.DataFrame(matrix, columns=mlb.classes_, index=data.index)

    knn = train_knn(genre_df)

    return data, genre_df, knn

def main():
    data, genre_df, knn = prepare()
    recommnedations = 5
    movie_title = "Toy Story (1995)"
    
    if movie_title not in data["title"].values:
        f"Movie '{movie_title}' not found in dataset."
        return
    
    idx = data[data["title"] == movie_title].index[0]
    print(idx)
    # Get the vector of that movie
    movie_vec = genre_df.iloc[idx].values.reshape(1, -1)
    
    # Find nearest neighbors
    distances, indices = knn.kneighbors(movie_vec, n_neighbors=recommnedations+1)
    
    # Exclude the first one (itself)
    rec_indices = indices.flatten()[1:]
    rec_movies = data.iloc[rec_indices]["title"].tolist()

    print("Recommendations for 'Toy Story (1995)':")
    print(rec_movies)

if __name__ == "__main__":
    main()
    

