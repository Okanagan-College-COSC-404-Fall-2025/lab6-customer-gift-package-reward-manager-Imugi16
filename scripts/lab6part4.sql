SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE display_first_five_rewards IS
  CURSOR c_rewards IS
    SELECT * FROM (
      SELECT cr.reward_id,
             cr.customer_email,
             cr.gift_id,
             cr.reward_date,
             gc.min_purchase
      FROM customer_rewards cr
      JOIN gift_catalog gc ON cr.gift_id = gc.gift_id
      ORDER BY cr.reward_date DESC, cr.reward_id
    )
    WHERE ROWNUM <= 5;

  v_reward_id   customer_rewards.reward_id%TYPE;
  v_customer    customer_rewards.customer_email%TYPE;
  v_gift_id     customer_rewards.gift_id%TYPE;
  v_reward_date customer_rewards.reward_date%TYPE;
  v_min_purchase gift_catalog.min_purchase%TYPE;
  v_gifts       VARCHAR2(2000);
BEGIN
  FOR r IN c_rewards LOOP
    v_reward_id := r.reward_id;
    v_customer := r.customer_email;
    v_gift_id := r.gift_id;
    v_reward_date := r.reward_date;
    v_min_purchase := r.min_purchase;

    BEGIN
      SELECT LISTAGG(t.COLUMN_VALUE, ', ') WITHIN GROUP (ORDER BY t.COLUMN_VALUE)
        INTO v_gifts
        FROM gift_catalog g, TABLE(g.gifts) t
       WHERE g.gift_id = v_gift_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_gifts := NULL;
      WHEN OTHERS THEN
        v_gifts := NULL;
    END;

    DBMS_OUTPUT.PUT_LINE(
      'Reward_ID: ' || NVL(TO_CHAR(v_reward_id), 'NULL') ||
      ' | Email: ' || NVL(v_customer, '(null)') ||
      ' | Gift_ID: ' || NVL(TO_CHAR(v_gift_id), 'NULL') ||
      ' | Min_Purchase: ' || NVL(TO_CHAR(v_min_purchase), 'NULL') ||
      ' | Items: ' || NVL(v_gifts, '(none)') ||
      ' | Date: ' || NVL(TO_CHAR(v_reward_date, 'YYYY-MM-DD'), '(none)')
    );
  END LOOP;
END display_first_five_rewards;
/

SET SERVEROUTPUT ON;
BEGIN
  display_first_five_rewards;
END;
/
