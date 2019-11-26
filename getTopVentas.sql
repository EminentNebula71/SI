CREATE OR REPLACE FUNCTION getTopVentas (numeric) RETURNS TABLE(
  Year INT,
  Title VARCHAR,
  Sales INT
) AS $$ DECLARE return_anio ALIAS FOR $1;
BEGIN RETURN QUERY

SELECT CAST (query1.year_aux AS INTEGER),
       title_aux,
       CAST (query1.sales_aux AS INTEGER)

FROM(       
	SELECT EXTRACT(year FROM orders.orderdate) AS year_aux, movietitle AS title_aux, sum(quantity) AS sales_aux
	FROM orders INNER JOIN orderdetail ON orders.orderid=orderdetail.orderid
	INNER JOIN products ON orderdetail.prod_id=products.prod_id
	INNER JOIN imdb_movies ON products.movieid=imdb_movies.movieid
	GROUP BY
		EXTRACT(year from orders.orderdate), movietitle
) query1,
(
	SELECT year_aux, MAX(sales_aux) as sales_aux
	FROM( SELECT EXTRACT(year from orders.orderdate) AS year_aux, movietitle AS title_aux, sum(quantity) AS sales_aux
		FROM orders INNER JOIN orderdetail ON orders.orderid=orderdetail.orderid
		INNER JOIN products ON orderdetail.prod_id=products.prod_id
		INNER JOIN imdb_movies on products.movieid=imdb_movies.movieid
		GROUP BY movietitle, EXTRACT(year from orders.orderdate)) AS ventasanio
	GROUP BY year_aux) AS query2

WHERE query1.year_aux=query2.year_aux AND query1.sales_aux=query2.sales_aux AND query1.year_aux>=return_anio
ORDER BY query1.year_aux desc;

end;
$$language plpgsql;
