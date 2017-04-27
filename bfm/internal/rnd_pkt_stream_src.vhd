LIBRARY test;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

ENTITY rnd_pkt_stream_src IS
GENERIC(
  test_pkts    : POSITIVE;
  max_symbols  : POSITIVE := 100;
  min_symbols  : POSITIVE := 1;
  symbol_bits  : POSITIVE;
  width_power  : NATURAL;
  meta_bits    : NATURAL;
  seed1, seed2 : POSITIVE;
  data_rate    : REAL := 1.0
);
PORT(
  clk          : IN  std_ulogic;
  reset        : IN  std_ulogic;
  meta         : OUT std_ulogic_vector(meta_bits-1 DOWNTO 0);
  data         : OUT std_ulogic_vector(symbol_bits*2**width_power-1 DOWNTO 0);
  stop         : OUT std_ulogic;
  empty        : OUT std_ulogic_vector(width_power-1 DOWNTO 0);
  valid        : OUT std_ulogic;
  ack          : IN  std_ulogic;
  done         : OUT std_ulogic
);
END ENTITY;

ARCHITECTURE rlt OF rnd_pkt_stream_src IS

  CONSTANT word_symbols : POSITIVE := 2**width_power;

BEGIN

  PROCESS(clk, reset)
    VARIABLE rate1, rate2 : POSITIVE;
    VARIABLE len1, len2   : POSITIVE;
    VARIABLE meta1, meta2 : POSITIVE;
    VARIABLE data1, data2 : POSITIVE;
    VARIABLE rand         : REAL;
    VARIABLE length       : POSITIVE;
    VARIABLE offset       : NATURAL;
    VARIABLE rnd_meta     : std_ulogic_vector(meta_bits-1 DOWNTO 0);
    VARIABLE symbol       : std_ulogic_vector(symbol_bits-1 DOWNTO 0);
    VARIABLE count        : NATURAL;
    PROCEDURE init IS
    BEGIN
      meta  <= (OTHERS => '-');
      data  <= (OTHERS => '-');
      stop  <= '-';
      empty <= (OTHERS => '-');
      valid <= '0';
    END PROCEDURE;
  BEGIN
    IF reset = '1' THEN
      init;
      -- Use same seeds for all stimulus
      len1 := seed1;
      len2 := seed2;
      meta1 := seed1;
      meta2 := seed2;
      data1 := seed1;
      data2 := seed2;
      -- Start in the out of packet state
      offset := length;
      count := 0;
      done <= '0';
    ELSIF rising_edge(clk) THEN
      IF valid = '0' OR ack = '1' THEN
        UNIFORM(rate1, rate2, rand);
        IF rand < data_rate AND count < test_pkts THEN
          IF offset = length THEN
            -- New packet time
            test.helpers.rnd_no(len1, len2, min_symbols, max_symbols, length);
            test.helpers.rnd_vec(meta1, meta2, rnd_meta);
            offset := 0;
          END IF;

          meta <= rnd_meta;
          -- Defaults:
          data  <= (OTHERS => '-');
          empty <= (OTHERS => '-');
          stop  <= '0';

          -- Generate symbols
          FOR i IN 0 TO word_symbols-1 LOOP
            test.helpers.rnd_vec(data1, data2, symbol);
            data(i*symbol_bits+symbol_bits-1 DOWNTO i*symbol_bits) <= symbol;
            offset := offset + 1;
            -- Stop when we've completed the packet
            IF offset = length THEN
              stop  <= '1';
              empty <= std_ulogic_vector(TO_UNSIGNED(word_symbols-1-i, width_power));
              count := count + 1;
              EXIT;
            END IF;
          END LOOP;
          valid <= '1';
        ELSE
          init;
        END IF;
      END IF;

      IF count >= test_pkts THEN
        done <= '1';
      END IF;
    END IF;
  END PROCESS;

END ARCHITECTURE;
