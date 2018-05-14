CREATE OR REPLACE PACKAGE mastermind
AUTHID DEFINER
AS
  TYPE combination IS VARRAY(4) OF integer;

  FUNCTION combination_to_string(fi_combo combination) RETURN VARCHAR2;

  PROCEDURE compute_score (pi_guess       IN  combination,
                           pi_solution    IN  combination,
                           po_white_count OUT NUMBER,
                           po_black_count OUT NUMBER);
                           
  FUNCTION compute_score_sql(fi_guess_perm_id    IN permutation_list.permutation_id%TYPE,
                             fi_solution_perm_id IN permutation_list.permutation_id%TYPE) RETURN NUMBER;

  PROCEDURE print_game_history(pi_game_id        IN game.game_id%TYPE,
                               pi_print_solution IN BOOLEAN DEFAULT FALSE);

  PROCEDURE start_game (po_game_id OUT NUMBER);
  
  PROCEDURE make_guess (pi_game_id IN NUMBER);

END mastermind;
/

