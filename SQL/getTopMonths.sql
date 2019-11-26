CREATE OR REPLACE FUNCTION getTopMonths(numeric, numeric) RETURNS TABLE(
    mes INT,
    dia INT,
    importe_total INT,
    cantidad_total INT
) AS $$ DECLARE importe_min ALIAS FOR $1;
DECLARE numero_min ALIAS FOR $2;

BEGIN RETURN QUERY

SELECT CAST(query1.year_aux AS INTEGER), CAST(query1.month_aux AS INTEGER), CAST(precio_total AS INTEGER), CAST(cantidad_total AS INTEGER)
FROM
(SELECT EXTRACT( year from orders.orderdate) AS year_aux, EXTRACT( month FROM orders.orderdate) as month_aux, SUM(totalamount) as precio_total
 FROM orders
 GROUP BY EXTRACT(year FROM orders.orderdate), EXTRACT(month FROM orders.orderdate), SUM(totalamount), SUM(orderdetail.quantity)
)query1,
(SELECT year_aux, MAX(sales_aux) as sales_aux
 FROM orders
 GROUP BY movietitle, EXTRACT(year from orders.orderdate)) AS ventasanio
GROUP BY year_aux

)
-- EXTRACT(year from orderdate) as year_aux, EXTRACT(day from orderdate) as day_aux, orderdetail.price*orderdetail.quantity AS sales_aux, sum(orderdetail.quantity) AS quantity_aux 
-- FROM Orders JOIN orderdetail on Orders.orderid=orderdetail.orderid
-- GROUP BY orders.orderdate 
)
end;
$$language plpgsql;