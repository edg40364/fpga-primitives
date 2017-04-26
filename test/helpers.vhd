LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE helpers IS

  PROCEDURE clock(SIGNAL sig : INOUT std_ulogic;
                  high : TIME;
                  low : TIME;
                  phase : TIME := 0 ns);
  PROCEDURE stop_clock;

END PACKAGE;

PACKAGE BODY helpers IS

  TYPE clock_status_type IS PROTECTED
    PROCEDURE stop;
    IMPURE FUNCTION running RETURN BOOLEAN;
  END PROTECTED;

  TYPE clock_status_type IS PROTECTED BODY
    VARIABLE stopped : BOOLEAN := FALSE;

    PROCEDURE stop IS
    BEGIN
      stopped := TRUE;
    END PROCEDURE;

    IMPURE FUNCTION running RETURN BOOLEAN IS
    BEGIN
      RETURN NOT stopped;
    END FUNCTION;
  END PROTECTED BODY;

  SHARED VARIABLE clocks_status : clock_status_type;

  PROCEDURE clock(SIGNAL sig : INOUT std_ulogic;
                  high : TIME;
                  low : TIME;
                  phase : TIME := 0 ns) IS
  BEGIN
    sig <= '0';
    WAIT FOR phase;
    WHILE clocks_status.running LOOP
      sig <= '0';
      WAIT FOR low;
      sig <= '1';
      WAIT FOR high;
    END LOOP;
    WAIT;
    END PROCEDURE;

    PROCEDURE stop_clock IS
    BEGIN
      clocks_status.stop;
    END PROCEDURE;

END PACKAGE BODY;
