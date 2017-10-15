CREATE OR REPLACE PACKAGE mastermind
AS
  TYPE combination IS VARRAY(4) OF integer;

  FUNCTION combination_to_string(fi_combo combination) RETURN VARCHAR2;

  PROCEDURE compute_score (pi_guess       IN  combination,
                           pi_solution    IN  combination,
                           po_white_count OUT NUMBER,
                           po_black_count OUT NUMBER);
                           
  FUNCTION compute_score_sql(fi_guess_peg1    IN peg_list.ID%TYPE,
                             fi_guess_peg2    IN peg_list.ID%TYPE,
                             fi_guess_peg3    IN peg_list.ID%TYPE,
                             fi_guess_peg4    IN peg_list.ID%TYPE,
                             fi_solution_peg1 IN peg_list.ID%TYPE,
                             fi_solution_peg2 IN peg_list.ID%TYPE,
                             fi_solution_peg3 IN peg_list.ID%TYPE,
                             fi_solution_peg4 IN peg_list.ID%TYPE) RETURN NUMBER;

  PROCEDURE start_game (po_game_id OUT NUMBER);
  
  PROCEDURE player_guess (pi_game_id IN NUMBER,
                          pi_guess   IN combination);

  PROCEDURE computer_guess (pi_game_id IN NUMBER);

END mastermind;
/

