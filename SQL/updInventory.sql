CREATE OR REPLACE FUNCTION updInventory() RETURNS TRIGGER AS $$
  DECLARE
    record RECORD;
    entero INT4;
  BEGIN
    FOR record IN (
      SELECT * 
      FROM (orderdetail NATURAL JOIN inventory AS i NATURAL JOIN orders) as aux 
      WHERE NEW.orderid = aux.orderid)
      LOOP
        entero := (SELECT stock FROM inventory WHERE record.prod_id = prod_id)-record.quantity;
        IF (entero < 0) THEN
          INSERT INTO alerts VALUES (record.orderid, record.prod_id);

          UPDATE orders SET status=NULL
          WHERE NEW.orderid=orderid;
        ELSE
          UPDATE inventory
          SET sales = sales + record.quantity,
          stock = stock - record.quantity
          WHERE record.prod_id = prod_id;

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
