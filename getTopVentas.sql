SELECT movietitle, count(*) as n
FROM imdb_movies JOIN orderdetail on imdb_movies.movieid=orderdetail.movieid
WHERE imdb_movies.year=anio_argumento 
GROUP BY imdb_movies.year ORDER BY n desc limit 1  