SET SERVEROUTPUT ON

DECLARE
  lv_game_id NUMBER;
BEGIN
  mastermind.start_game(lv_game_id);
  mastermind.print_game_history(lv_game_id, TRUE);

  mastermind.make_guess(lv_game_id);
  mastermind.print_game_history(lv_game_id);
  mastermind.make_guess(lv_game_id);
  mastermind.print_game_history(lv_game_id);
  mastermind.make_guess(lv_game_id);
  mastermind.print_game_history(lv_game_id);
  mastermind.make_guess(lv_game_id);
  mastermind.print_game_history(lv_game_id);
END;
/

