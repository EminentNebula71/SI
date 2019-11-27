CREATE OR REPLACE FUNCTION updOrders() RETURNS TRIGGER AS $$
  BEGIN
    IF (TG_OP = 'INSERT') THEN
      UPDATE orders SET netamount = netamount + NEW.price*NEW.quantity
      WHERE orders.orderid = NEW.orderid;
      
      UPDATE orders SET totalamount = netamount + netamount*tax*0.01
      WHERE orders.orderid = NEW.orderid;
      
    ELSIF (TG_OP = 'DELETE') THEN 
      UPDATE orders SET netamount = netamount - OLD.price*OLD.quantity
      WHERE orders.orderid = OLD.orderid;
      
      UPDATE orders SET totalamount = netamount + netamount*tax*0.01
      WHERE orders.orderid = OLD.orderid;

    ELSIF (TG_OP = 'UPDATE') THEN 
      UPDATE orders SET netamount = netamount - OLD.price*OLD.quantity + NEW.price*NEW.quantity
      WHERE orders.orderid = OLD.orderid;
      
      UPDATE orders SET totalamount = netamount + netamount*tax*0.01
      WHERE orders.orderid = OLD.orderid;
    END IF;
  RETURN NEW;
  END;
  $$ LANGUAGE plpgsql;

CREATE TRIGGER t_updOrders AFTER INSERT OR DELETE OR UPDATE ON orderdetail
FOR EACH ROW EXECUTE PROCEDURE updOrders();
