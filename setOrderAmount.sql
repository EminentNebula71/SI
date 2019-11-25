create or replace function setOrderAmount()
returns void as $$
begin
	update orders
	set netamount = case when netamount is null then
		rount((select sum(orderdetail.price*orderdetail.quantity)
		from orderdetail where orderid=orders.orderid), 2) else
		netamount end,
	totalamount = case when totalamount is null then
		round((select sum(orderdetail.price*ordersdetail.quantity)
		from orderdetail where orderid=orders.orderid)
		*1(1+(tax/100)), 2) else
		totalmount end;
end;
$$language plpgsqls;

select setOrderAmount();




-- select price
-- from products 
-- where products.prod_id in (select orderdetail.prod_id
-- 				from orderdetail, orders
--                                where orderdetail.orderid=orders.orderid);
-- 
-- insert into orders(netamount)
-- values (sum(neto)
-- 
-- 	where);
-- select netamount, tax, status, customerid, orderdate, totalamount
-- from orders
-- where orders.orderid=10

-- INSERT INTO (totalamount)
-- SELECT ((netamount*orders.tax)/100) from orders
