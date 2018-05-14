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
  FUNCTION get_combination_from_pegs(fi_peg1 IN NUMBER,
                                     fi_peg2 IN NUMBER,
                                     fi_peg3 IN NUMBER,
                                     fi_peg4 IN NUMBER)
  RETURN combination
  IS
  BEGIN
    RETURN combination(fi_peg1, fi_peg2, fi_peg3, fi_peg4);
  END get_combination_from_pegs;

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
  PROCEDURE print_game_history(pi_game_id        IN game.game_id%TYPE,
                               pi_print_solution IN boolean DEFAULT FALSE)
  IS
    lv_game_rec GAME%rowtype;

  BEGIN
    SELECT *
      INTO lv_game_rec
      FROM game
     WHERE game_id = pi_game_id;
     
    dbms_output.put_line('GAME: ' || to_char(lv_game_rec.game_id) ||
                         ' Started on: ' || to_char(lv_game_rec.game_date, 'YYYY-Mon-DD hh24:mi') ||
                         ' Completed: ' || lv_game_rec.game_completed_flag);

    IF pi_print_solution
    THEN 
      dbms_output.put_line('Solution: ' || combination_to_string(get_combination_by_id(lv_game_rec.solution_permutation_id)));
    END IF;
    
    FOR i IN (SELECT move_id, guess_permutation_id, score_black, score_white
                FROM game_move_record
               WHERE game_id = lv_game_rec.game_id
               ORDER BY move_id) LOOP

      dbms_output.put_line('  Move: ' || to_char(i.move_id) ||
                           ' Guess: ' || combination_to_string(get_combination_by_id(i.guess_permutation_id)) ||
                           ' Black pegs: ' || to_char(i.score_black) ||
                           ' White pegs: ' || to_char(i.score_white));
    END LOOP;
    dbms_output.put_line('----');  --is there a better way to get a blank line??
    
  END print_game_history;
  
  ----------------------------------------------------------
  FUNCTION compute_score_sql(fi_guess_perm_id    IN permutation_list.permutation_id%TYPE,
                             fi_solution_perm_id IN permutation_list.permutation_id%TYPE)
  RETURN NUMBER
  IS
    lv_result NUMBER;
    lv_white_score NUMBER;
    lv_black_score NUMBER;
    
  BEGIN

    compute_score (pi_guess       => get_combination_by_id(fi_guess_perm_id),
                   pi_solution    => get_combination_by_id(fi_solution_perm_id),
                   po_white_count => lv_white_score,
                   po_black_count => lv_black_score);

    /* we want this to be callable from SQL; but that means it can only return one value.
       We could write two funtions - one to return white, and another to return black;
       but first i want to try this trick encoding both scores into a single number output.  */
    lv_result := (lv_black_score * 10) + lv_white_score;
    
    RETURN lv_result;
    
  END compute_score_sql;  

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
  PROCEDURE compute_score (pi_guess       IN NUMBER,
                           pi_solution    IN number,
                           po_white_count OUT NUMBER,
                           po_black_count OUT NUMBER) IS
    lv_black NUMBER;
    lv_white NUMBER;

  BEGIN  
    compute_score (pi_guess       => get_combination_by_id(compute_score.pi_guess),
                   pi_solution    => get_combination_by_id(compute_score.pi_solution),
                   po_white_count => compute_score.lv_white,
                   po_black_count => compute_score.lv_black);

    po_white_count := compute_score.lv_white;
    po_black_count := compute_score.lv_black;

  END compute_score;

  ----------------------------------------------------------
  PROCEDURE eliminate_elements_from_set(pi_game_id IN game_move_record.game_id%TYPE,
                                        pi_move_id IN game_move_record.move_id%TYPE)
  IS 
    lv_prev_guess_perm_id game_move_record.guess_permutation_id%TYPE;
    lv_prev_black_score   game_move_record.score_black%TYPE;
    lv_prev_white_score   game_move_record.score_white%TYPE;
    
  BEGIN
    SELECT guess_permutation_id, score_black, score_white
      INTO lv_prev_guess_perm_id, lv_prev_black_score, lv_prev_white_score
      FROM game_move_record
     WHERE game_id = pi_game_id
       AND move_id = (pi_move_id - 1);  --score for previous turn
    
    /* Secret codes which could not have resulted in the previous score given 
       the previous guess are removed from the set of possible codes. */   
    UPDATE solver_guess_info
       SET still_possible_solution = 'N',
           eliminated_on_guess_id = (pi_move_id - 1)
     WHERE game_id = pi_game_id
       AND still_possible_solution = 'Y'  -- only check ones not already eliminated
       AND compute_score_sql(fi_guess_perm_id    => possible_solution_perm_id,
                             fi_solution_perm_id => lv_prev_guess_perm_id) <> (lv_prev_black_score * 10) + lv_prev_white_score;
       
  END eliminate_elements_from_set;
  
  ----------------------------------------------------------
  PROCEDURE choose_next_guess(pi_game_id       IN  game.game_id%TYPE,
                              po_guess_perm_id OUT game_move_record.guess_permutation_id%TYPE) IS

    lv_next_guess_perm_id solver_guess_info.possible_solution_perm_id%TYPE;

  BEGIN
    /* To minimize the number of guesses required to find the solution, we'd occasionally 
       need to choose a solution which has already been ruled out.  I'm going to ignore 
       that possibility for now and just focus on something simple to get things working. */

    /* This query just picks the first possibility the query optimizer cares to return. */
    SELECT possible_solution_perm_id
      INTO lv_next_guess_perm_id
      FROM solver_guess_info
     WHERE game_id = pi_game_id
       AND still_possible_solution = 'Y'
       AND ROWNUM = 1;
       
    po_guess_perm_id := lv_next_guess_perm_id;

  END choose_next_guess;

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

    /* Initialize solver records */
    INSERT INTO solver_guess_info (game_id, possible_solution_perm_id)
    SELECT lv_game_id, permutation_id 
      FROM permutation_list;

    po_game_id := lv_game_id;

    COMMIT;
      
  END start_game;
  
  ----------------------------------------------------------
  PROCEDURE make_guess (pi_game_id IN NUMBER) IS
    
    lv_move_id          game_move_record.move_id%TYPE;
    lv_solution_perm_id game.solution_permutation_id%TYPE;
    lv_completed_game   game.game_completed_flag%TYPE;
    lv_guess_combo      combination;
    lv_guess_perm_id    game_move_record.guess_permutation_id%TYPE;
    lv_white_score      game_move_record.score_white%TYPE;
    lv_black_score      game_move_record.score_black%TYPE;

  BEGIN
    /* get solution perm ID.  Also check for complete games.  ToDo: add no_data_found handler. */
    SELECT solution_permutation_id, game_completed_flag
      INTO lv_solution_perm_id, lv_completed_game
      FROM game
     WHERE game_id = pi_game_id; 
     
    IF lv_completed_game = 'Y' 
    THEN 
      raise_application_error(-20001, 'That game was already completed');
    END IF;
    
    /* figure out what turn it is */
    SELECT nvl(MAX(move_id), 0) + 1
      INTO lv_move_id
      FROM game_move_record
     WHERE game_id = pi_game_id; 

    IF lv_move_id = 1
    THEN
      /* first guess of game */
      lv_guess_perm_id := get_permutation_id_by_combo(get_combination_from_pegs(1,1,2,2));  --use fixed initial guess
      compute_score(pi_guess       => lv_guess_perm_id,
                    pi_solution    => lv_solution_perm_id,
                    po_white_count => lv_white_score, 
                    po_black_count => lv_black_score);
      
    ELSE
      /* second guess or later */
      eliminate_elements_from_set(pi_game_id => make_guess.pi_game_id,
                                  pi_move_id => make_guess.lv_move_id);
      choose_next_guess(pi_game_id       => make_guess.pi_game_id,
                        po_guess_perm_id => make_guess.lv_guess_perm_id);
      compute_score(pi_guess       => make_guess.lv_guess_perm_id,
                    pi_solution    => make_guess.lv_solution_perm_id,
                    po_white_count => make_guess.lv_white_score, 
                    po_black_count => make_guess.lv_black_score);

    END IF;
    
    INSERT INTO game_move_record
      (game_id, move_id, guess_permutation_id, score_black, score_white)
    VALUES 
      (pi_game_id, lv_move_id, lv_guess_perm_id, lv_black_score, lv_white_score);
      
    /* check for completed games - correct solution or too many turns */
    IF (lv_move_id = 10 OR lv_black_score = 4)
    THEN
      UPDATE game
         SET game_completed_flag = 'Y'
       WHERE game_id = pi_game_id;

    END IF;  

    COMMIT;

  END make_guess;

END mastermind;
/

