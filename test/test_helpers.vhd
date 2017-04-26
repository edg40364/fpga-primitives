LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

USE work.helpers.ALL;

ENTITY test_helpers IS
END ENTITY;

ARCHITECTURE testbench OF test_helpers IS

  SIGNAL clk100   : std_ulogic;
  SIGNAL clk25_0  : std_ulogic;
  SIGNAL clk25_90 : std_ulogic;

  SIGNAL count_0  : NATURAL;
  SIGNAL count_90 : NATURAL;

BEGIN

  clock(clk100, 5 ns, 5 ns, 5 ns);
  clock(clk25_0, 20 ns, 20 ns);
  clock(clk25_90, 20 ns, 20 ns, 10 ns);

  PROCESS(clk25_0)
  BEGIN
    IF rising_edge(clk25_0) THEN
      count_0 <= count_0 + 1;
    END IF;
  END PROCESS;

  PROCESS(clk25_90)
  BEGIN
    IF rising_edge(clk25_90) THEN
      count_90 <= count_90 + 1;
    END IF;
  END PROCESS;

  check : PROCESS
  BEGIN
    WAIT FOR 110 ns;
    stop_clock;
    ASSERT count_0 = 3
      REPORT "Cycle count doesn't match expected" SEVERITY ERROR;
    ASSERT count_0 = count_90 + 1
      REPORT "Phase shift count doesn't match expected" SEVERITY ERROR;
    WAIT;
  END PROCESS;

END ARCHITECTURE;
