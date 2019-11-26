update orderdetail
set price=round((((select price from products where prod_id=orderdetail.prod_id)
/ (select(1.02^(extract(year from now()) - extract(year from orders.orderdate))) from orders where orderid=orderdetail.orderid))*quantity)::numeric, 2);