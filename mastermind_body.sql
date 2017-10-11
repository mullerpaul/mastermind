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
  FUNCTION get_permutation_id_by_combo (fi_combination combination)
  RETURN NUMBER
  IS
    lv_result NUMBER;

  BEGIN
    SELECT permutation_id
      INTO lv_result
      FROM permutation_list
     WHERE peg1 = fi_combination(1)
       AND peg2 = fi_combination(2)
       AND peg3 = fi_combination(3)
       AND peg4 = fi_combination(4);
       
    RETURN lv_result;
    /* too many rows should not happen as peg combos are unique. 
       no data found should not happen unless we have invalid input. */
  END;

  ----------------------------------------------------------
  FUNCTION get_combination_by_id(fi_combo_id NUMBER)
  RETURN combination
  IS
    lv_result combination;
    lv_peg1   NUMBER;
    lv_peg2   NUMBER;
    lv_peg3   NUMBER;
    lv_peg4   NUMBER;
    
  BEGIN

    BEGIN
      SELECT peg1, peg2, peg3, peg4
        INTO lv_peg1, lv_peg2, lv_peg3, lv_peg4
        FROM permutation_list
       WHERE permutation_id = fi_combo_id;
       
      lv_result := combination(lv_peg1, lv_peg2, lv_peg3, lv_peg4);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        /* not 100% sure this is correct behavior in this case */
        lv_result := combination();
    END;

    RETURN lv_result;

  END get_combination_by_id;
  
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

  ----------------------------------------------------------
  PROCEDURE start_game (po_game_id OUT NUMBER) IS

    /* Number of combinations (and max ID) for number of permutations.  We may 
       want to make this dynamic so it works with different # of slots or colors. */
    lc_number_of_combinations CONSTANT NUMBER := 1296;
    
    lv_game_id          NUMBER := game_seq.nextval;
    lv_solution_perm_id NUMBER;
    
  BEGIN
    /* pick secret code */
    lv_solution_perm_id := trunc(dbms_random.VALUE(low => 1, HIGH => lc_number_of_combinations+1));
 
    /* Initialize game */
    INSERT INTO game (game_id, solution_permutation_id)
    VALUES (lv_game_id, lv_solution_perm_id);
    
    po_game_id := lv_game_id;
    
    COMMIT;
      
  END start_game;
  
  ----------------------------------------------------------
  PROCEDURE make_guess (pi_game_id IN NUMBER,
                        pi_guess   IN combination) IS

    lv_completed_flag   game.game_completed_flag%TYPE;
    lv_soultion_perm_id game.solution_permutation_id%TYPE;
    lv_guess_perm_id    game_moves.guess_permutation_id%TYPE;
    lv_move_id          game_moves.move_id%TYPE;
    lv_black_score      NUMBER;
    lv_white_score      NUMBER;
    
  BEGIN
    BEGIN
      SELECT solution_permutation_id, game_completed_flag
        INTO lv_soultion_perm_id, lv_completed_flag
        FROM game
       WHERE game_id = pi_game_id;
    EXCEPTION
      WHEN no_data_found THEN 
        raise_application_error(-20001,'Not a valid game ID');
    END;

    IF lv_completed_flag <> 'N' THEN
      raise_application_error(-20002,'That game is already completed');
    END IF;

    SELECT nvl(MAX(move_id),0) + 1 AS next_move_id
      INTO lv_move_id
      FROM game_moves 
     WHERE game_id = pi_game_id;

    lv_guess_perm_id := get_permutation_id_by_combo(pi_guess);
    
    compute_score (pi_guess       => pi_guess,
                   pi_solution    => get_combination_by_id(lv_soultion_perm_id),
                   po_white_count => lv_white_score,
                   po_black_count => lv_black_score);
                   
    dbms_output.put_line('Guess: ' || combination_to_string(pi_guess) || '  Score: white ' || to_char(lv_white_score) || ' black ' || to_char(lv_black_score));
    
    INSERT INTO game_moves (game_id, move_id, guess_permutation_id, score_black, score_white)
    VALUES (pi_game_id, lv_move_id, lv_guess_perm_id, lv_black_score, lv_white_score);
    
    COMMIT;
    
  END make_guess;

END mastermind;
/

