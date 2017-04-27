LIBRARY test;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.math_real.ALL;

ENTITY rnd_stream_src IS
GENERIC(
  test_words   : POSITIVE;
  data_bits    : POSITIVE;
  seed1, seed2 : POSITIVE;
  data_rate    : REAL := 1.0
);
PORT(
  clk          : IN  std_ulogic;
  reset        : IN  std_ulogic;
  data         : OUT std_ulogic_vector(data_bits-1 DOWNTO 0);
  valid        : OUT std_ulogic;
  ack          : IN  std_ulogic;
  done         : OUT std_ulogic
);
END ENTITY;

ARCHITECTURE rlt OF rnd_stream_src IS

BEGIN

  PROCESS(clk, reset)
    VARIABLE rate1, rate2 : POSITIVE;
    VARIABLE data1, data2 : POSITIVE;
    VARIABLE rand         : REAL;
    VARIABLE value        : std_ulogic_vector(data'RANGE);
    VARIABLE count        : NATURAL;
    PROCEDURE init IS
    BEGIN
      data  <= (OTHERS => '-');
      valid <= '0';
    END PROCEDURE;
  BEGIN
    IF reset = '1' THEN
      init;
      data1 := seed1;
      data2 := seed2;
      count := 0;
      done <= '0';
    ELSIF rising_edge(clk) THEN
      IF valid = '0' OR ack = '1' THEN
        UNIFORM(rate1, rate2, rand);
        IF rand < data_rate AND count < test_words THEN
          test.helpers.rnd_vec(data1, data2, value);
          data  <= value;
          valid <= '1';
          count := count + 1;
        ELSE
          init;
        END IF;
      END IF;

      IF count >= test_words THEN
        done <= '1';
      END IF;
    END IF;
  END PROCESS;

END ARCHITECTURE;
