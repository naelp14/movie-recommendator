from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from knn_movies import prepare

app = FastAPI()
movies, genre_df, knn = prepare()

class MovieRequest(BaseModel):
    title: str

@app.get("/")
def root():
    return {"message": "Movie Recommendation API is running 🚀"}

@app.post("/recommendations")
def get_recommendations(request: MovieRequest):
    title = request.title

    if title not in movies["title"].values:
        raise HTTPException(status_code=404, detail="item not found")

    idx = movies[movies["title"] == title].index[0]
    movie_vec = genre_df.iloc[idx].values.reshape(1, -1)

    distances, indices = knn.kneighbors(movie_vec, n_neighbors=6)

    recs = []
    for i in indices[0][1:]:
        recs.append(movies.iloc[i]["title"])

    return {"recommendations": recs}

