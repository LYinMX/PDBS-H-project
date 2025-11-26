import pandas as pd
from tmdbv3api import TMDb, Movie, Person, Discover

tmdb = TMDb()
tmdb.api_key  = '你的KEY'
tmdb.language = 'en-US' 

movie_api  = Movie()
person_api = Person()
discover = Discover()

date = "2017-01-01"

pid = []
per = []
mov = []
cre = []

def Getperson ( person_id: int ) :
    print( f"Getperson {person_id} start" )
    details = person_api.details(person_id)

    name_parts = details.name.split() if details.name else []
    first_name = ''.join(name_parts[:-1]) if len(name_parts) > 1 else None
    surname    =         name_parts[ -1]  if     name_parts      else None

    born = details.birthday[0:4] if details.birthday else None
    died = details.deathday[0:4] if details.deathday else None
    gender = 'M' if details.gender == 2 else 'F' if details.gender == 1 else None

    per.append( [ person_id, first_name, surname, born, died, gender ] )

    print( f"Getperson {person_id} finished" )


def Getmovie ( movie_id: int ) :
    print( f"Getmoive {movie_id} start" )
    details = movie_api.details(movie_id)
    
    countries    = details.production_countries[0]["iso_3166_1"].lower() if details.production_countries else None
    year_release = details.release_date[0:4] if details.release_date else None

    credits = movie_api.credits(movie_id)
    
    for crew in credits.crew :
        if crew.job == "Director" : 
            pid.append( crew.id )
            cre.append( [ movie_id, crew.id, 'D' ] )
    
    count = 0
    for cast in credits.cast :
        pid.append( cast.id )
        cre.append( [ movie_id, cast.id, 'A' ] )
        count = count + 1
        if count == 10 :
            break
        
    mov.append(
        [ movie_id, details.title, details.original_title,
          countries, year_release, details.runtime ]
    )
    
    print( f"Getmoive {movie_id} finished" )

if __name__ == "__main__":
    for page in range(1, 100):
        discovered_movies = discover.discover_movies({
            "primary_release_date.gte": "2017-01-01",
            "sort_by": "popularity.desc",
            "vote_average.gte" : 6.5,
            "vote_count.gte" : 500,
            "page": page
        })
            
        if page > discovered_movies.total_pages:
            print(f"finished movie")
            break
        
        for movie in discovered_movies:
            Getmovie( movie_id = movie.id )

        print(f"完成第 {page} 页")

    pid = list( set( pid ) )
    for person_id in pid :
        Getperson( person_id = person_id )

    pd.DataFrame( cre, columns = ['movie_id', 'person_id', 'credit']
    ).to_csv( "cre.csv", index = False, encoding="utf-8-sig" )

    pd.DataFrame( per, columns = ['person_id', 'first_name', 'surname', 'born', 'died', 'gender']
    ).to_csv( "per.csv", index = False, encoding="utf-8-sig" )

    pd.DataFrame( mov, columns = ['movie_id', 'title', 'original_title', 'countries', 'year_release', 'runtime']
    ).to_csv( "mov.csv", index = False, encoding="utf-8-sig" )
