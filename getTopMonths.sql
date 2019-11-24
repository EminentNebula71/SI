SELECT fecha
FROM Orders JOIN orderdetail on Orders.orderid=orderdetail.orderid
GROUP BY orders.orderdate 