LIBRARY test;
USE test.helpers.vec2hex;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

ENTITY rnd_pkt_stream_sink IS
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
  meta         : IN  std_ulogic_vector(meta_bits-1 DOWNTO 0);
  data         : IN  std_ulogic_vector(symbol_bits*2**width_power-1 DOWNTO 0);
  stop         : IN  std_ulogic;
  empty        : IN  std_ulogic_vector(width_power-1 DOWNTO 0);
  valid        : IN  std_ulogic;
  ack          : OUT std_ulogic;
  done         : OUT std_ulogic
);
END ENTITY;

ARCHITECTURE rlt OF rnd_pkt_stream_sink IS

  CONSTANT word_symbols : POSITIVE := 2**width_power;
  SIGNAL ready          : std_ulogic;

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
    VARIABLE len1, len2   : POSITIVE;
    VARIABLE meta1, meta2 : POSITIVE;
    VARIABLE data1, data2 : POSITIVE;
    VARIABLE chk1, chk2   : POSITIVE;
    VARIABLE length       : POSITIVE;
    VARIABLE offset       : NATURAL;
    VARIABLE exp_meta     : std_ulogic_vector(meta_bits-1 DOWNTO 0);
    VARIABLE exp_symbol   : std_ulogic_vector(symbol_bits-1 DOWNTO 0);
    VARIABLE exp_empty    : NATURAL RANGE 0 TO word_symbols-1;
    VARIABLE count        : NATURAL;
  BEGIN
    IF reset = '1' THEN
      -- Use same seeds for all verification
      len1 := seed1;
      len2 := seed2;
      meta1 := seed1;
      meta2 := seed2;
      data1 := seed1;
      data2 := seed2;
      -- Start with details of the first expected packet
      test.helpers.rnd_no(len1, len2, min_symbols, max_symbols, length);
      test.helpers.rnd_vec(meta1, meta2, exp_meta);
      offset := 0;
      count  := 0;
      done   <= '0';
    ELSIF rising_edge(clk) THEN
      IF valid = '1' THEN
        -- Even if we aren't acknowledging this word, it should be correct
        -- Check meta
        ASSERT meta = exp_meta REPORT "Meta mismatch, expected " &
          vec2hex(exp_meta) & ", got " & vec2hex(meta) SEVERITY ERROR;
        -- Check stop
        IF offset + word_symbols >= length THEN
          ASSERT stop = '1' REPORT "Missing stop" SEVERITY ERROR;
          exp_empty := word_symbols - (length - offset);
          ASSERT UNSIGNED(empty) = exp_empty REPORT
            "Empty mismatch, expected " &
            INTEGER'IMAGE(exp_empty) & ", got " &
            INTEGER'IMAGE(TO_INTEGER(UNSIGNED(empty))) SEVERITY ERROR;
        ELSE
          ASSERT stop = '0' REPORT "Unexpected stop, length = " &
            INTEGER'IMAGE(length) & ", offset = " &
            INTEGER'IMAGE(offset) SEVERITY ERROR;
        END IF;

        -- Take a copy of the data seeds, so that they can be used hypothetically
        chk1 := data1;
        chk2 := data2;

        FOR i IN 0 TO word_symbols-1 LOOP
          -- Avoid checking beyond end of packet
          IF offset + i < length THEN
            test.helpers.rnd_vec(chk1, chk2, exp_symbol);
            ASSERT data(i*symbol_bits+symbol_bits-1 DOWNTO i*symbol_bits) =
              exp_symbol REPORT "Symbol mismatch at offset " & INTEGER'IMAGE(i)
              & ", expected " & vec2hex(exp_symbol) & ", got " &
              vec2hex(data(i*symbol_bits+symbol_bits-1 DOWNTO i*symbol_bits))
              SEVERITY ERROR;
          END IF;
        END LOOP;
      END IF;

      IF ack = '1' THEN
        -- Last observation of this data, update seeds
        data1 := chk1;
        data2 := chk2;
        -- And the offset within the packet
        offset := offset + word_symbols;
        IF stop = '1' THEN
          test.helpers.rnd_no(len1, len2, min_symbols, max_symbols, length);
          test.helpers.rnd_vec(meta1, meta2, exp_meta);
          offset := 0;
          count := count + 1;
        END IF;
      END IF;

      IF count >= test_pkts THEN
        done <= '1';
      END IF;
    END IF;
  END PROCESS;

END ARCHITECTURE;
