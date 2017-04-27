LIBRARY test, bfm;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY test_fifo IS
GENERIC(
  depth_power   : POSITIVE := 9;
  data_bits     : POSITIVE := 32;
  test_words    : POSITIVE := 10000;
  seed1         : POSITIVE := 89423;
  seed2         : POSITIVE := 58342
);
END ENTITY;

ARCHITECTURE testbench OF test_fifo IS
  SIGNAL clk           : std_ulogic;
  SIGNAL reset         : std_ulogic;
  SIGNAL in_data       : std_ulogic_vector(data_bits-1 DOWNTO 0);
  SIGNAL in_valid      : std_ulogic;
  SIGNAL in_ack        : std_ulogic;
  SIGNAL out_data      : std_ulogic_vector(data_bits-1 DOWNTO 0);
  SIGNAL out_valid     : std_ulogic;
  SIGNAL out_ack       : std_ulogic;
  SIGNAL src_done      : std_ulogic;
  SIGNAL sink_done     : std_ulogic;

BEGIN

  test.helpers.clock(clk, 5 ns, 5 ns);
  reset <= '1', '0' AFTER 13 ns;

  src : bfm.bfm.rnd_stream_src
  GENERIC MAP(
    test_words   => test_words,
    data_bits    => data_bits,
    seed1        => seed1,
    seed2        => seed2,
    data_rate    => 0.8
  )
  PORT MAP(
    clk         => clk,
    reset       => reset,
    data        => in_data,
    valid       => in_valid,
    ack         => in_ack,
    done        => src_done
  );

  dut : work.storage.fifo
  GENERIC MAP(
    depth_power => depth_power,
    data_bits   => data_bits
  )
  PORT MAP(
    clk         => clk,
    reset       => reset,
    in_data     => in_data,
    in_valid    => in_valid,
    in_ack      => in_ack,
    out_data    => out_data,
    out_valid   => out_valid,
    out_ack     => out_ack
  );

  sink : bfm.bfm.rnd_stream_sink
  GENERIC MAP(
    test_words   => test_words,
    data_bits    => data_bits,
    seed1        => seed1,
    seed2        => seed2,
    data_rate    => 0.6
  )
  PORT MAP(
    clk         => clk,
    reset       => reset,
    data        => out_data,
    valid       => out_valid,
    ack         => out_ack,
    done        => sink_done
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
