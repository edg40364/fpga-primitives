LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ARCHITECTURE infer OF fifo IS

  SIGNAL wr_ptr, rd_ptr : UNSIGNED(depth_power-1 DOWNTO 0);
  SIGNAL used, free     : UNSIGNED(depth_power DOWNTO 0);
  SIGNAL full, empty    : std_ulogic;
  SIGNAL wr_en, rd_en   : std_ulogic;

  TYPE store_array IS ARRAY (NATURAL RANGE <>) OF std_ulogic_vector(in_data'RANGE);

  SIGNAL store          : store_array(0 TO 2**depth_power-1);

  SIGNAL out_hungry     : std_ulogic;

BEGIN

  wr_en <= in_valid AND NOT full;
  in_ack <= wr_en;

  writes : PROCESS(clk, reset)
  BEGIN
    IF rising_edge(clk) THEN
      IF wr_en = '1' THEN
        wr_ptr <= wr_ptr + 1;
      END IF;
      IF rd_en = '1' THEN
        rd_ptr <= rd_ptr + 1;
      END IF;
      used <= used + wr_en - rd_en;
      free <= free + rd_en - wr_en;

      out_valid <= rd_en OR (out_valid AND NOT out_ack);
    END IF;
    IF reset = '1' THEN
      wr_ptr    <= (OTHERS => '0');
      rd_ptr    <= (OTHERS => '0');
      used      <= (OTHERS => '0');
      free      <= TO_UNSIGNED(2**depth_power, depth_power+1);
      out_valid <= '0';
    END IF;
  END PROCESS;

  full  <= used(depth_power);
  empty <= free(depth_power);

  out_hungry <= out_ack OR NOT out_valid;
  rd_en <= out_hungry AND NOT empty;

  ram : PROCESS(clk)
  BEGIN
    IF rising_edge(clk) THEN
      IF wr_en = '1' THEN
        store(TO_INTEGER(wr_ptr)) <= in_data;
      END IF;
      IF rd_en = '1' THEN
        out_data <= store(TO_INTEGER(rd_ptr));
      END IF;
    END IF;
  END PROCESS;

END ARCHITECTURE;
