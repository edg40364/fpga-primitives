LIBRARY test;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.math_real.ALL;

ENTITY rnd_stream_sink IS
GENERIC(
  test_words   : POSITIVE;
  data_bits    : POSITIVE;
  seed1, seed2 : POSITIVE;
  data_rate    : REAL := 1.0
);
PORT(
  clk          : IN  std_ulogic;
  reset        : IN  std_ulogic;
  data         : IN  std_ulogic_vector(data_bits-1 DOWNTO 0);
  valid        : IN  std_ulogic;
  ack          : OUT std_ulogic;
  done         : OUT std_ulogic
);
END ENTITY;

ARCHITECTURE rlt OF rnd_stream_sink IS

  SIGNAL ready : std_ulogic;

BEGIN

  back_pressure : PROCESS(clk, reset)
    VARIABLE rate1, rate2 : POSITIVE;
    VARIABLE rand         : REAL;
  BEGIN
    IF reset = '1' THEN
      ready <= '0';
    ELSIF rising_edge(clk) THEN
      UNIFORM(rate1, rate2, rand);
      IF rand < data_rate THEN
        ready <= '1';
      ELSE
        ready <= '0';
      END IF;
    END IF;
  END PROCESS;

  ack <= valid AND ready;

  verify : PROCESS(clk, reset)
    VARIABLE data1, data2 : POSITIVE;
    VARIABLE expected     : std_ulogic_vector(data'RANGE);
    VARIABLE count        : NATURAL;
  BEGIN
    IF reset = '1' THEN
      data1 := seed1;
      data2 := seed2;
      count := 0;
      done  <= '0';
      -- Have first expected value ready
      test.helpers.rnd_vec(data1, data2, expected);
    ELSIF rising_edge(clk) THEN
      IF valid = '1' THEN
        -- Even if we aren't acknowledging this word, it should be correct
        ASSERT data = expected REPORT "Data mismatch at word " &
          INTEGER'IMAGE(count) & ", expected " &
          test.helpers.vec2hex(expected) & ", got " &
          test.helpers.vec2hex(data) SEVERITY ERROR;
      END IF;
      IF ack = '1' THEN
        -- Last observation of this data, work out next expected value
        test.helpers.rnd_vec(data1, data2, expected);
        count := count + 1;
      END IF;
      IF count >= test_words THEN
        done <= '1';
      END IF;
    END IF;
  END PROCESS;

END ARCHITECTURE;
