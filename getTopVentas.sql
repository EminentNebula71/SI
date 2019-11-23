SELECT movietitle
FROM imdb_movies JOIN orderdetail on imdb_movies.movieid=orderdetail.movieid
order by movieid 