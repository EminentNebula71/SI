INSERT INTO (netamount)
VALUES (select sum(select precio 
                    from products 
                    where products.prod_id in (select prod_id
                                                from orderdetail
                                                where orderdetail.orderid=orders.orderid)))

INSERT INTO (totalamount)
SELECT ((netamount*orders.tax)/100) from orders

-- LO QUE HAY QUE HACER ES SUMAR EL PRECIO DE LAS PELIS DEL PEDIDO. para ello, se cogen los precios de las películas cuya id estén en la lista de ids
-- de orderdetail, para aquel orderdetail cuyo order_id coincida con uno de los order_id de la tabla orders