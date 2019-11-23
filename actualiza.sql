update orderdetail
set price = (select price from products)
where pride_id = (select prod_id from products)
