SET timing ON

DECLARE
  lv_game_id   NUMBER;
  lv_game_done BOOLEAN;
  le_game_done EXCEPTION;
  PRAGMA EXCEPTION_INIT(le_game_done, -20001);

BEGIN
  FOR i IN 1 .. 1000 LOOP
    lv_game_done := FALSE;
    lv_game_id := game_seq.nextval;

    mastermind.start_game(lv_game_id);
    LOOP
      BEGIN
        mastermind.make_guess(lv_game_id);
      EXCEPTION
        WHEN le_game_done
          THEN lv_game_done := TRUE;
      END;
      EXIT WHEN lv_game_done;
    END LOOP;

  END LOOP;

END;
/

--- this query shows the average number of moves it took to find the code.
--- It ASSUMES that all games are completed AND all games completed because 
--- the code was found.
SELECT count(*) AS games, 
       avg(moves_to_complete)
  FROM (SELECT game_id, 
               count(*) AS moves_to_complete
          FROM game_move_record
         GROUP BY game_id);

