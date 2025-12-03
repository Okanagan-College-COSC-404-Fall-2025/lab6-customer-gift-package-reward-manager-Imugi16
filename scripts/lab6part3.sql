SET SERVEROUTPUT ON;

CREATE OR REPLACE PACKAGE customer_manager IS
  FUNCTION get_total_purchase(p_customer_id IN NUMBER) RETURN NUMBER;

  PROCEDURE assign_gifts_to_all;
END customer_manager;
/

CREATE OR REPLACE PACKAGE BODY customer_manager IS

  FUNCTION choose_gift_package(p_total_purchase IN NUMBER) RETURN NUMBER IS
    v_gift_id NUMBER;
  BEGIN
    SELECT gift_id
      INTO v_gift_id
      FROM (
        SELECT gift_id
          FROM gift_catalog
         WHERE min_purchase <= NVL(p_total_purchase, 0)
         ORDER BY min_purchase DESC
      )
     WHERE ROWNUM = 1;

    RETURN v_gift_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END choose_gift_package;

  FUNCTION get_total_purchase(p_customer_id IN NUMBER) RETURN NUMBER IS
    v_total NUMBER := 0;
  BEGIN

    SELECT NVL(SUM(oi.unit_price * oi.quantity), 0)
      INTO v_total
      FROM orders o
      JOIN order_items oi ON o.order_id = oi.order_id
     WHERE o.customer_id = p_customer_id
       AND NVL(UPPER(o.order_status), 'X') <> 'CANCELLED';

    RETURN v_total;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 0;
  END get_total_purchase;

  PROCEDURE assign_gifts_to_all IS
    v_total   NUMBER;
    v_gift_id NUMBER;
  BEGIN
    FOR c IN (SELECT customer_id, email_address FROM customers) LOOP
      v_total := get_total_purchase(c.customer_id);
      v_gift_id := choose_gift_package(v_total);

      IF v_gift_id IS NOT NULL THEN
        INSERT INTO customer_rewards (customer_email, gift_id)
        VALUES (c.email_address, v_gift_id);
      END IF;
    END LOOP;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END assign_gifts_to_all;

END customer_manager;
/
