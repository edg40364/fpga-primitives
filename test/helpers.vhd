LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE helpers IS

  PROCEDURE clock(SIGNAL sig : INOUT std_ulogic;
                  high : TIME;
                  low : TIME;
                  phase : TIME := 0 ns);
  PROCEDURE stop_clock;

  PROCEDURE rnd_no(seed1 : INOUT POSITIVE;
                   seed2 : INOUT POSITIVE;
                   min   : INTEGER;
                   max   : INTEGER;
                   value : OUT INTEGER);

  PROCEDURE rnd_vec(seed1 : INOUT POSITIVE;
                    seed2 : INOUT POSITIVE;
                    value : OUT std_ulogic_vector);

  FUNCTION div_ceil(dividend : NATURAL; divisor : POSITIVE) RETURN NATURAL;

  FUNCTION vec2hex(vec : std_ulogic_vector) RETURN STRING;

END PACKAGE;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

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

  PROCEDURE rnd_no(seed1 : INOUT POSITIVE;
                   seed2 : INOUT POSITIVE;
                   min   : INTEGER;
                   max   : INTEGER;
                   value : OUT INTEGER) IS
    CONSTANT rng  : POSITIVE := max - min;
    VARIABLE rand : REAL;
  BEGIN
    UNIFORM(seed1, seed2, rand);
    value := INTEGER(rand * REAL(rng)) + min;
  END PROCEDURE;

  PROCEDURE rnd_unsigned(seed1 : INOUT POSITIVE;
                         seed2 : INOUT POSITIVE;
                         value : OUT UNSIGNED) IS
    CONSTANT num_bytes : POSITIVE := div_ceil(value'LENGTH, 8);
    VARIABLE byte      : NATURAL RANGE 0 TO 255;
    VARIABLE res       : UNSIGNED(num_bytes*8-1 DOWNTO 0);
  BEGIN
    FOR i IN 0 TO num_bytes-1 LOOP
      rnd_no(seed1, seed2, 0, 255, byte);
      res(i*8+7 DOWNTO i*8) := TO_UNSIGNED(byte, 8);
    END LOOP;
    -- Return just as many bits as asked for
    value := res(value'LENGTH-1 DOWNTO 0);
  END PROCEDURE;

  PROCEDURE rnd_vec(seed1 : INOUT POSITIVE;
                    seed2 : INOUT POSITIVE;
                    value : OUT std_ulogic_vector) IS
    VARIABLE res : UNSIGNED(value'RANGE);
  BEGIN
    rnd_unsigned(seed1, seed2, res);
    value := std_ulogic_vector(res);
  END PROCEDURE;

  FUNCTION div_ceil(dividend : NATURAL; divisor : POSITIVE) RETURN NATURAL IS
  BEGIN
    RETURN (dividend + divisor - 1) / divisor;
  END FUNCTION;

  CONSTANT hex_characters : STRING(1 TO 16) := "0123456789ABCDEF";

  FUNCTION vec2hex(vec : std_ulogic_vector) RETURN STRING IS
    CONSTANT nibbles  : POSITIVE := div_ceil(vec'LENGTH, 4);
    VARIABLE padded   : std_ulogic_vector(nibbles*4-1 DOWNTO 0) := (OTHERS => '0');
    VARIABLE expanded : std_ulogic_vector(0 TO nibbles*4-1);
    VARIABLE nibble   : NATURAL RANGE 0 TO 15;
    VARIABLE res      : STRING(1 TO nibbles);
  BEGIN
    padded(vec'LENGTH-1 DOWNTO 0) := vec;
    expanded := padded; 
    FOR i IN 0 TO nibbles-1 LOOP
      nibble := TO_INTEGER(UNSIGNED(expanded(i*4 TO i*4+3)));
      res(i+1) := hex_characters(nibble+1);
    END LOOP;
    RETURN res;
  END FUNCTION;

END PACKAGE BODY;
