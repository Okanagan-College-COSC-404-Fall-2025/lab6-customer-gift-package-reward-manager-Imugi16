SET SERVEROUTPUT ON;

CREATE OR REPLACE TYPE gift_item_list IS TABLE OF VARCHAR2(255);
/

BEGIN
	EXECUTE IMMEDIATE 'DROP TABLE gift_catalog CASCADE CONSTRAINTS';
EXCEPTION
	WHEN OTHERS THEN
		IF SQLCODE != -942 THEN
			RAISE;
		END IF;
END;
/

CREATE TABLE gift_catalog (
	gift_id      NUMBER PRIMARY KEY,
	min_purchase NUMBER,
	gifts        gift_item_list
)
NESTED TABLE gifts STORE AS gifts_storage_table;

INSERT INTO gift_catalog (gift_id, min_purchase, gifts)
VALUES (1, 100, gift_item_list('Stickers', 'Pen Set'));

INSERT INTO gift_catalog (gift_id, min_purchase, gifts)
VALUES (2, 1000, gift_item_list('Teddy Bear', 'Mug', 'Perfume Sample'));

INSERT INTO gift_catalog (gift_id, min_purchase, gifts)
VALUES (3, 10000, gift_item_list('Backpack', 'Thermos Bottle', 'Chocolate Collection'));

COMMIT;

SELECT * FROM gift_catalog;