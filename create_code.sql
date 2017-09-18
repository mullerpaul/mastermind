CREATE OR REPLACE PACKAGE mastermind
AS
  TYPE combination IS VARRAY(4) OF integer;

  PROCEDURE compute_score (pi_guess       IN  combination,
                           pi_solution    IN  combination,
                           po_white_count OUT NUMBER,
                           po_black_count OUT NUMBER);

END mastermind;
/

CREATE OR REPLACE PACKAGE BODY mastermind
AS

  PROCEDURE compute_score (pi_guess       IN combination,
                           pi_solution    IN combination,
                           po_white_count OUT NUMBER,
                           po_black_count OUT NUMBER) IS
  
    lv_black NUMBER := 0;
    lv_white NUMBER := 0;

  BEGIN
    po_black_count := lv_black;
    po_white_count := lv_white;

    FOR i IN pi_guess.FIRST .. pi_guess.LAST LOOP
      IF pi_guess(i) = pi_solution(i) 
        THEN lv_black := lv_black + 1;
      END IF;

  END compute_score;

END mastermind;
/


