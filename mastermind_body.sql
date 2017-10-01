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
  
    TYPE scored_pegs_type IS TABLE OF INTEGER;
    la_scored_solution_pegs scored_pegs_type := scored_pegs_type();
    la_scored_guess_pegs    scored_pegs_type := scored_pegs_type();
    
    lv_black NUMBER := 0;
    lv_white NUMBER := 0;

  BEGIN
    /* match black pegs first */
    FOR i IN pi_guess.FIRST .. pi_guess.LAST LOOP
      IF pi_guess(i) = pi_solution(i) 
      THEN 
        /* match!  increment black counter and store index of solution so we don't use it again.  */
        lv_black := lv_black + 1;
        la_scored_solution_pegs.EXTEND;
        la_scored_solution_pegs(la_scored_solution_pegs.LAST) := i;
        la_scored_guess_pegs.EXTEND;
        la_scored_guess_pegs(la_scored_guess_pegs.LAST) := i;
        
      END IF;
    END LOOP;

    /* match white pegs next */
    FOR i IN pi_guess.FIRST .. pi_guess.LAST loop
      IF i NOT MEMBER OF la_scored_guess_pegs
      THEN

        FOR j IN pi_solution.FIRST .. pi_solution.LAST loop
          IF pi_guess(i) = pi_solution(j) AND j NOT MEMBER OF la_scored_solution_pegs
          THEN
            /* match!  Increment White counter and store index of solution so we don't score it again.  */
            lv_white := lv_white + 1;
            la_scored_solution_pegs.EXTEND;
            la_scored_solution_pegs(la_scored_solution_pegs.LAST) := j;
            /* Don't really need to track scored guesses at this point; but keeping this in for now.  Remove later if speed is an issue.   */
            la_scored_guess_pegs.EXTEND;
            la_scored_guess_pegs(la_scored_guess_pegs.LAST) := i;

            /* Now exit the loop since we don't want to match any other solution pegs */
            EXIT;
            
          END IF;  
        END LOOP;  

      END IF;  
    END LOOP;

    po_black_count := lv_black;
    po_white_count := lv_white;

  END compute_score;

END mastermind;
/


