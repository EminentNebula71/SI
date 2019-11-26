create or replace function setOrderAmount()
returns void as $$
begin
	update orders
	set netamount = case when netamount is null then
		round((select sum(orderdetail.price*orderdetail.quantity)
		from orderdetail where orderid=orders.orderid), 2) else
		netamount end,
	totalamount = case when totalamount is null then
		round((select sum(orderdetail.price*ordersdetail.quantity)
		from orderdetail where orderid=orders.orderid)
		*(1+(tax/100)), 2) else
		totalmount end;
end;
$$language plpgsql;

select setOrderAmount();