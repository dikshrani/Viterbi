-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;

entity testbench is
end testbench;

architecture tb of testbench is

signal tb_clk : std_logic;
signal tb_input : std_logic;
signal tb_output : std_logic;


component top_entity is
    port(top_input: in std_logic;
        top_clk: in std_logic;
        top_output: out std_logic
        );
end component;

begin
TOP_DUT:
top_entity port map (
top_input => tb_input,
top_clk => tb_clk,
top_output => tb_output
);

process
begin
-- 	tb_input <= '0';
--     wait for 1 ns;
    tb_input <= '1';
    wait for 2 ns;
    tb_input <= '0';
    wait for 2 ns;
    tb_input <= '0';
    wait for 2 ns;
    tb_input <= '1';
    wait for 2 ns;
    tb_input <= '0';
    wait for 2 ns;
    tb_input <= '0';
    wait for 2 ns;
    tb_input <= '0';
	--wait for 2 ns;
   wait;
end process;
                                                    

ClockGen: process
variable out_reg: std_logic_vector(6 downto 0):="0000000";
variable index: integer:=6; 
  begin
    for j in 0 to 25 loop
      tb_clk <= '0';
      if j > 8 
      then
      out_reg(index):=tb_output;
      if index > 0 then
      index := index-1;
      end if;
      end if;
     wait for 1 NS;
      tb_clk <= '1';
      wait for 1 NS;
    end loop;
    if out_reg = "1011000" then
    report "************Data_Matched";
    else
    report "************Data_Not Matched";
    end if;
    report "Simulation finished";
    wait;
  end process ClockGen;
  
end tb ;