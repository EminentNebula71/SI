CREATE OR REPLACE FUNCTION updInventory() RETURNS TRIGGER AS $$
  DECLARE
    r RECORD;
    s INT4;
  BEGIN
    FOR r IN (
      SELECT * 
      FROM (orderdetail NATURAL JOIN inventory AS i NATURAL JOIN orders) as t 
      WHERE NEW.orderid = t.orderid)
      LOOP
        s := (SELECT stock FROM inventory WHERE r.prod_id = prod_id) - r.quantity;
        IF (s < 0) THEN
          INSERT INTO alerts VALUES (r.orderid,r.prod_id);

          UPDATE orders SET status=NULL
          WHERE NEW.orderid=orderid;
        ELSE
          UPDATE inventory
          SET sales = sales + r.quantity,
          stock = stock - r.quantity
          WHERE r.prod_id = prod_id;

        END IF;
      END LOOP;
      
      UPDATE orders
      SET orderdate = CURRENT_DATE
      WHERE orderid = NEW.orderid;
      
    RETURN NEW;
  END; $$ LANGUAGE plpgsql;

--DROP TRIGGER IF EXISTS t_updInventory ON orders;

CREATE TRIGGER t_updInventory AFTER UPDATE ON orders 
FOR EACH ROW 
WHEN (NEW.status IS DISTINCT FROM OLD.status AND OLD.status IS NULL)--cuando cambie orders.status(CUANDO PASE DE NULL A ALGO?)
EXECUTE PROCEDURE updInventory();
