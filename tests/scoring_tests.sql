set serveroutput on
DECLARE 
  TYPE test_rec_type IS RECORD
    (solution            mastermind.combination,
     guess               mastermind.combination,
     correct_black_count NUMBER,
     correct_white_count NUMBER);

  TYPE test_array_type IS TABLE OF test_rec_type INDEX BY pls_integer;

  test_array test_array_type;

  lv_black_result NUMBER;
  lv_white_result NUMBER;
  lv_fail_count   NUMBER := 0;

BEGIN
  test_array(1).solution := mastermind.combination(5, 1, 2, 4);
  test_array(1).guess    := mastermind.combination(5, 1, 2, 4);
  test_array(1).correct_black_count := 4;
  test_array(1).correct_white_count := 0;

  test_array(2).solution := mastermind.combination(3, 3, 1, 2);
  test_array(2).guess    := mastermind.combination(1, 2, 3, 3);
  test_array(2).correct_black_count := 0;
  test_array(2).correct_white_count := 4;

  test_array(3).solution := mastermind.combination(5, 1, 2, 4);
  test_array(3).guess    := mastermind.combination(1, 2, 3, 1);
  test_array(3).correct_black_count := 0;
  test_array(3).correct_white_count := 2;

  test_array(4).solution := mastermind.combination(3, 1, 2, 4);
  test_array(4).guess    := mastermind.combination(1, 1, 3, 1);
  test_array(4).correct_black_count := 1;
  test_array(4).correct_white_count := 1;

  test_array(5).solution := mastermind.combination(5, 1, 1, 4);
  test_array(5).guess    := mastermind.combination(1, 1, 3, 1);
  test_array(5).correct_black_count := 1;
  test_array(5).correct_white_count := 1;

  test_array(6).solution := mastermind.combination(3, 1, 2, 4);
  test_array(6).guess    := mastermind.combination(5, 6, 5, 5);
  test_array(6).correct_black_count := 0;
  test_array(6).correct_white_count := 0;

  test_array(7).solution := mastermind.combination(2, 1, 5, 6);
  test_array(7).guess    := mastermind.combination(1, 2, 6, 5);
  test_array(7).correct_black_count := 0;
  test_array(7).correct_white_count := 4;

  test_array(8).solution := mastermind.combination(4, 2, 1, 3);
  test_array(8).guess    := mastermind.combination(1, 3, 1, 1);
  test_array(8).correct_black_count := 1;
  test_array(8).correct_white_count := 1;

  test_array(9).solution := mastermind.combination(5, 6, 5, 5);
  test_array(9).guess    := mastermind.combination(1, 5, 5, 6);
  test_array(9).correct_black_count := 1;
  test_array(9).correct_white_count := 2;

  FOR i IN test_array.FIRST .. test_array.LAST LOOP
    lv_black_result := 0;
    lv_white_result := 0;
    dbms_output.put_line('**** Test ' || to_char(i) || ' ****');
    dbms_output.put_line('solution: ' || mastermind.combination_to_string(test_array(i).solution));
    dbms_output.put_line('guess   : ' || mastermind.combination_to_string(test_array(i).guess));

    mastermind.compute_score(pi_guess       => test_array(i).guess, 
                             pi_solution    => test_array(i).solution,
                             po_white_count => lv_white_result,
                             po_black_count => lv_black_result);

    dbms_output.put_line('returned black count ' || to_char(lv_black_result));
    dbms_output.put_line('returned white count ' || to_char(lv_white_result));

    IF (lv_black_result = test_array(i).correct_black_count AND 
        lv_white_result = test_array(i).correct_white_count)
      THEN
        /* test passes */
        dbms_output.put_line('PASS');
      ELSE
        /* test fails */
        lv_fail_count := lv_fail_count + 1;
        dbms_output.put_line('FAIL');

    END IF;

  END LOOP;

  IF lv_fail_count > 0
    THEN raise_application_error(-20001, to_char(lv_fail_count) || ' tests have failed!');
  END IF;

END;
/


