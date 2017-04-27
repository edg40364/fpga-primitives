LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE storage IS

  COMPONENT fifo IS
  GENERIC(
    depth_power   : POSITIVE := 9;
    data_bits     : POSITIVE := 32
  );
  PORT(
    clk           : IN  std_ulogic;
    reset         : IN  std_ulogic;
    in_data       : IN  std_ulogic_vector(data_bits-1 DOWNTO 0);
    in_valid      : IN  std_ulogic;
    in_ack        : OUT std_ulogic;
    out_data      : OUT std_ulogic_vector(data_bits-1 DOWNTO 0);
    out_valid     : OUT std_ulogic;
    out_ack       : IN  std_ulogic
  );
  END COMPONENT;

END PACKAGE;
