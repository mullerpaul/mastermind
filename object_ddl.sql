CREATE TABLE peg_list
  (id    NUMBER       NOT NULL,
   color VARCHAR2(12) NOT NULL);

CREATE TABLE solution_list
  (id   NUMBER NOT NULL,
   peg1 NUMBER NOT NULL,
   peg2 NUMBER NOT NULL,
   peg3 NUMBER NOT NULL,
   peg4 NUMBER NOT NULL);

INSERT INTO peg_list (id, color) VALUES (1, 'white');
INSERT INTO peg_list (id, color) VALUES (2, 'black');
INSERT INTO peg_list (id, color) VALUES (3, 'yellow');
INSERT INTO peg_list (id, color) VALUES (4, 'blue');
INSERT INTO peg_list (id, color) VALUES (5, 'red');
INSERT INTO peg_list (id, color) VALUES (6, 'green');

COMMIT;

INSERT INTO solution_list
SELECT ROWNUM AS id, p1.id as peg1, p2.id as peg2, p3.id as peg3, p4.id as peg4
  FROM peg_list p1, peg_list p2, peg_list p3, peg_list p4;

COMMIT;

