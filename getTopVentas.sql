CREATE OR REPLACE FUNCTION getTopVentas (numeric) RETURNS TABLE(
  Year INT,
  Title VARCHAR,
  Sales INT
) AS $$ DECLARE return_year ALIAS FOR $1;
BEGIN RETURN QUERY

SELECT TOP 1 year AS year_aux, movietitle AS title_aux, sum(orderdetail.quantity) AS sales_aux
FROM orders INNER JOIN orderdetail ON orders.orderid=orderdetail.orderid,
orderdetail INNER JOIN products ON orderdetail.prod_id=products.prod_id,
products.prod_id=imdb_movies.movieid
WHERE imdb_movies.year>=return_year

end;
$$language plpgsql;
