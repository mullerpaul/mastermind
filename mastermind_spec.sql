CREATE OR REPLACE PACKAGE mastermind
AS
  TYPE combination IS VARRAY(4) OF integer;

  FUNCTION combination_to_string(fi_combo combination) RETURN VARCHAR2;

  PROCEDURE compute_score (pi_guess       IN  combination,
                           pi_solution    IN  combination,
                           po_white_count OUT NUMBER,
                           po_black_count OUT NUMBER);

END mastermind;
/

