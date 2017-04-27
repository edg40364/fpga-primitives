LIBRARY test;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.math_real.ALL;

ENTITY test_rnd_stream IS
GENERIC(
  test_words   : POSITIVE := 1000;
  data_bits    : POSITIVE := 62;
  seed1        : POSITIVE := 348932;
  seed2        : POSITIVE := 94348
);
END ENTITY;

ARCHITECTURE testbench OF test_rnd_stream IS

  SIGNAL clk          : std_ulogic;
  SIGNAL reset        : std_ulogic;
  SIGNAL data         : std_ulogic_vector(data_bits-1 DOWNTO 0);
  SIGNAL valid        : std_ulogic;
  SIGNAL ack          : std_ulogic;
  SIGNAL src_done     : std_ulogic;
  SIGNAL sink_done    : std_ulogic;

BEGIN

  test.helpers.clock(clk, 5 ns, 5 ns);
  reset <= '1', '0' AFTER 13 ns;

  src : work.stream.rnd_stream_src
  GENERIC MAP(
    test_words   => test_words,
    data_bits    => data_bits,
    seed1        => seed1,
    seed2        => seed2,
    data_rate    => 0.8
  )
  PORT MAP(
    clk          => clk,
    reset        => reset,
    data         => data,
    valid        => valid,
    ack          => ack,
    done         => src_done
  );

  sink : work.stream.rnd_stream_sink
  GENERIC MAP(
    test_words   => test_words,
    data_bits    => data_bits,
    seed1        => seed1,
    seed2        => seed2,
    data_rate    => 0.5
  )
  PORT MAP(
    clk          => clk,
    reset        => reset,
    data         => data,
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
