SELECT movietitle, count(*) as n
FROM imdb_movies JOIN orderdetail on products.prod_id=orderdetail.prod_id
WHERE imdb_movies.year=1999 
GROUP BY imdb_movies.year ORDER BY n desc limit 1  