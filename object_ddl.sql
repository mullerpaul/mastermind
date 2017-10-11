DROP TABLE game_moves;
DROP TABLE game;
DROP TABLE permutation_list;
DROP TABLE peg_list;
DROP SEQUENCE game_seq;

CREATE TABLE peg_list
  (id    NUMBER       NOT NULL,
   color VARCHAR2(12) NOT NULL);

CREATE TABLE permutation_list
  (permutation_id NUMBER NOT NULL,
   peg1           NUMBER NOT NULL,
   peg2           NUMBER NOT NULL,
   peg3           NUMBER NOT NULL,
   peg4           NUMBER NOT NULL,
   CONSTRAINT permutation_list_pk PRIMARY KEY (permutation_id));

CREATE TABLE game
  (game_id                 NUMBER                  NOT NULL,
   game_date               DATE  DEFAULT SYSDATE   NOT NULL,
   solution_permutation_id NUMBER                  NOT NULL,
   game_completed          VARCHAR2(1) DEFAULT 'N' NOT NULL,
   CONSTRAINT game_pk PRIMARY KEY (game_id),
   CONSTRAINT game_fk01 FOREIGN KEY (solution_permutation_id) 
     REFERENCES permutation_list (permutation_id),
   CONSTRAINT game_ck01 CHECK (game_completed IN ('N','Y')));

CREATE SEQUENCE game_seq;

CREATE TABLE game_moves
  (game_id              NUMBER NOT NULL,
   move_id              NUMBER NOT NULL,
   guess_permutation_id NUMBER,
   score_black          NUMBER,
   score_white          NUMBER,
   CONSTRAINT game_move_pk PRIMARY KEY (game_id, move_id),
   CONSTRAINT game_move_fk01 FOREIGN KEY (game_id)
     REFERENCES game (game_id),
   CONSTRAINT game_move_fk02 FOREIGN KEY (guess_permutation_id)
     REFERENCES permutation_list (permutation_id));


--- insert constant reference data
INSERT INTO peg_list (id, color) VALUES (1, 'white');
INSERT INTO peg_list (id, color) VALUES (2, 'black');
INSERT INTO peg_list (id, color) VALUES (3, 'yellow');
INSERT INTO peg_list (id, color) VALUES (4, 'blue');
INSERT INTO peg_list (id, color) VALUES (5, 'red');
INSERT INTO peg_list (id, color) VALUES (6, 'green');

INSERT INTO permutation_list
SELECT ROWNUM AS permutation_id, 
       p1.id as peg1, p2.id as peg2, p3.id as peg3, p4.id as peg4
  FROM peg_list p1, peg_list p2, peg_list p3, peg_list p4;

COMMIT;

