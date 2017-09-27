CREATE OR REPLACE PACKAGE BODY mastermind
AS

  ----------------------------------------------------------
  FUNCTION combination_to_string(fi_combo combination)
  RETURN VARCHAR2
  IS 
    lv_result VARCHAR2(12);
  BEGIN
    FOR i IN fi_combo.FIRST .. fi_combo.LAST LOOP
      lv_result := lv_result || to_char(fi_combo(i)) || ' ';
    END LOOP;

    RETURN TRIM(lv_result);

  END combination_to_string;
  
  ----------------------------------------------------------
  PROCEDURE compute_score (pi_guess       IN combination,
                           pi_solution    IN combination,
                           po_white_count OUT NUMBER,
                           po_black_count OUT NUMBER) IS
  
    lv_black NUMBER := 0;
    lv_white NUMBER := 0;

  BEGIN
    FOR i IN pi_guess.FIRST .. pi_guess.LAST LOOP
      IF pi_guess(i) = pi_solution(i) 
        THEN lv_black := lv_black + 1;
      END IF;
      /* score white pegs here */

    END LOOP;

    po_black_count := lv_black;
    po_white_count := lv_white;

  END compute_score;

END mastermind;
/


