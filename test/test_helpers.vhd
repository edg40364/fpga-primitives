LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

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
    REPORT "Clock testing completed" SEVERITY NOTE;
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
    REPORT "Random testing completed" SEVERITY NOTE;
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
    REPORT "Hex testing completed" SEVERITY NOTE;
    WAIT;
  END PROCESS;

  check_graycode : PROCESS
    VARIABLE original  : std_ulogic_vector(7 DOWNTO 0);
    VARIABLE last      : std_ulogic_vector(original'RANGE);
    VARIABLE gray      : std_ulogic_vector(original'RANGE);
    VARIABLE reverted  : std_ulogic_vector(original'RANGE);
    FUNCTION bitdiff(a : std_ulogic_vector(original'RANGE);
                     b : std_ulogic_vector(original'RANGE)) RETURN NATURAL IS
      VARIABLE diff : NATURAL := 0;
    BEGIN
      FOR i IN a'RANGE LOOP
        IF a(i) /= b(i) THEN
          diff := diff + 1;
        END IF;
      END LOOP;
      RETURN diff;
    END FUNCTION;
    VARIABLE changed   : NATURAL;
  BEGIN
    original := (OTHERS => '1');
    last := bin2gray(original);
    FOR i IN 0 TO 2**original'LENGTH-1 LOOP
      original := std_ulogic_vector(TO_UNSIGNED(i, original'LENGTH));
      gray     := bin2gray(original);
      changed  := bitdiff(gray, last);
      ASSERT changed = 1 REPORT "bin2gray failure, " & INTEGER'IMAGE(changed) &
        " bits changed from " & vec2hex(last) & " to " & vec2hex(gray)
        SEVERITY ERROR;
      reverted := gray2bin(gray);
      ASSERT reverted = original REPORT "gray2bin failure, expected " &
        vec2hex(original) & ", got " & vec2hex(reverted) SEVERITY ERROR;
      last := gray;
    END LOOP;
    REPORT "Graycode testing completed" SEVERITY NOTE;
    WAIT;
  END PROCESS;

END ARCHITECTURE;
