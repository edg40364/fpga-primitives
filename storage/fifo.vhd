LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY fifo IS
GENERIC(
  depth_power   : POSITIVE;
  symbol_bits   : POSITIVE;
  width_power   : NATURAL;
  meta_bits     : NATURAL
);
PORT(
  clk           : IN  std_ulogic;
  reset         : IN  std_ulogic;
  in_data       : IN  std_ulogic_vector(symbol_bits*2**width_power-1 DOWNTO 0);
  in_meta       : IN  std_ulogic_vector(meta_bits-1 DOWNTO 0);
  in_stop       : IN  std_ulogic                                := '1';
  in_empty      : IN  std_ulogic_vector(width_power-1 DOWNTO 0) := (OTHERS => '1');
  in_valid      : IN  std_ulogic;
  in_ack        : OUT std_ulogic;
  out_data      : OUT std_ulogic_vector(symbol_bits*2**width_power-1 DOWNTO 0);
  out_meta      : OUT std_ulogic_vector(meta_bits-1 DOWNTO 0);
  out_stop      : OUT std_ulogic;
  out_empty     : OUT std_ulogic_vector(width_power-1 DOWNTO 0);
  out_valid     : OUT std_ulogic;
  out_ack       : IN  std_ulogic
);
END ENTITY;
