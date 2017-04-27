LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE stream IS

  COMPONENT rnd_stream_src IS
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
  END COMPONENT;

  COMPONENT rnd_stream_sink IS
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
  END COMPONENT;

  COMPONENT rnd_pkt_stream_src IS
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
  END COMPONENT;

  COMPONENT rnd_pkt_stream_sink IS
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
  END COMPONENT;
END PACKAGE;
