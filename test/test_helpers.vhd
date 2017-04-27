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

  check_clocks : PROCESS
  BEGIN
    WAIT FOR 110 ns;
    stop_clock;
    ASSERT count_0 = 3
      REPORT "Cycle count doesn't match expected" SEVERITY ERROR;
    ASSERT count_0 = count_90 + 1
      REPORT "Phase shift count doesn't match expected" SEVERITY ERROR;
    WAIT;
  END PROCESS;

  check_random : PROCESS
    VARIABLE seed1, seed2 : POSITIVE;
    TYPE count_array IS ARRAY (NATURAL RANGE <>) OF NATURAL;

    CONSTANT min        : INTEGER := -30;
    CONSTANT max        : INTEGER := 50;
    VARIABLE popularity : count_array(0 TO max - min);
    VARIABLE rand       : INTEGER;
    VARIABLE high, low  : NATURAL;
  BEGIN
    FOR i IN 1 TO 10000 LOOP
      rnd_no(seed1, seed2, min, max, rand);
      popularity(rand - min) := popularity(rand - min) + 1;
    END LOOP;
    low  := NATURAL'HIGH;
    high := NATURAL'LOW;
    FOR i IN popularity'RANGE LOOP
      IF popularity(i) < low THEN
        low := popularity(i);
      END IF;
      IF popularity(i) > high THEN
        high := popularity(i);
      END IF;
    END LOOP;

    REPORT "popularity ranged from " &
      INTEGER'IMAGE(low) & " to " &
      INTEGER'IMAGE(high) SEVERITY NOTE;
    ASSERT low * 3 >= high REPORT
      "Range of random values varies more than expected" SEVERITY ERROR;
    WAIT;
  END PROCESS;

  check_hex : PROCESS
    CONSTANT expected : STRING := "3BADCAFE";
    CONSTANT vector   : std_ulogic_vector(31 DOWNTO 0) := x"BBADCAFE";
    VARIABLE result   : STRING(1 TO 8);
  BEGIN
    result := vec2hex(vector(30 DOWNTO 0));
    ASSERT result = expected REPORT "Hex mismatch, expected " &
      expected & ", got " & result SEVERITY ERROR;
    WAIT;
  END PROCESS;

END ARCHITECTURE;
