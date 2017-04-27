LIBRARY test;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.math_real.ALL;

ENTITY test_rnd_pkt_stream IS
GENERIC(
  test_pkts    : POSITIVE := 1000;
  max_symbols  : POSITIVE := 100;
  min_symbols  : POSITIVE := 1;
  symbol_bits  : POSITIVE := 9;
  width_power  : NATURAL  := 3;
  meta_bits    : NATURAL  := 32;
  seed1        : POSITIVE := 348932;
  seed2        : POSITIVE := 94348
);
END ENTITY;

ARCHITECTURE testbench OF test_rnd_pkt_stream IS

  CONSTANT word_symbols : POSITIVE := 2**width_power;
  SIGNAL clk          : std_ulogic;
  SIGNAL reset        : std_ulogic;
  SIGNAL meta         : std_ulogic_vector(meta_bits-1 DOWNTO 0);
  SIGNAL data         : std_ulogic_vector(symbol_bits*word_symbols-1 DOWNTO 0);
  SIGNAL stop         : std_ulogic;
  SIGNAL empty        : std_ulogic_vector(width_power-1 DOWNTO 0);
  SIGNAL valid        : std_ulogic;
  SIGNAL ack          : std_ulogic;
  SIGNAL src_done     : std_ulogic;
  SIGNAL sink_done    : std_ulogic;

BEGIN

  test.helpers.clock(clk, 5 ns, 5 ns);
  reset <= '1', '0' AFTER 13 ns;

  src : work.stream.rnd_pkt_stream_src
  GENERIC MAP(
    test_pkts    => test_pkts,
    max_symbols  => max_symbols,
    min_symbols  => min_symbols,
    symbol_bits  => symbol_bits,
    width_power  => width_power,
    meta_bits    => meta_bits,
    seed1        => seed1,
    seed2        => seed2,
    data_rate    => 0.8
  )
  PORT MAP(
    clk          => clk,
    reset        => reset,
    meta         => meta,
    data         => data,
    stop         => stop,
    empty        => empty,
    valid        => valid,
    ack          => ack,
    done         => src_done
  );

  sink : work.stream.rnd_pkt_stream_sink
  GENERIC MAP(
    test_pkts    => test_pkts,
    max_symbols  => max_symbols,
    min_symbols  => min_symbols,
    symbol_bits  => symbol_bits,
    width_power  => width_power,
    meta_bits    => meta_bits,
    seed1        => seed1,
    seed2        => seed2,
    data_rate    => 0.5
  )
  PORT MAP(
    clk          => clk,
    reset        => reset,
    meta         => meta,
    data         => data,
    stop         => stop,
    empty        => empty,
    valid        => valid,
    ack          => ack,
    done         => sink_done
  );

  ctrl : PROCESS
  BEGIN
    WAIT UNTIL sink_done = '1';
    ASSERT src_done = '1' REPORT
      "Source doesn't report completion" SEVERITY ERROR;
    test.helpers.stop_clock;
    REPORT "Test complete" SEVERITY NOTE;
    WAIT;
  END PROCESS;

END ARCHITECTURE;
