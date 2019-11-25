CREATE OR REPLACE FUNCTION getTopMonths(numeric, numeric) RETURN TABLE(
    mes INT,
    dia INT,
    importe_total INT,
    cantidad_total INT
) AS $$ DECLARE importe_min ALIAS FOR $1;
DECLARE numero_min ALIAS FOR $2;
BEGIN RETURN QUERY

SELECT EXTRACT(year from orderdate) as year_aux, EXTRACT(day from orderdate) as day_aux, orderdetail.price*orderdetail.quantity AS sales_aux, sum(orderdetail.quantity) AS quantity_aux 
FROM Orders JOIN orderdetail on Orders.orderid=orderdetail.orderid
GROUP BY orders.orderdate 

end;
$$language plpgsql;