-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;

entity testbench is
end testbench;

architecture tb of testbench is
   
component convo_encoder is
    port(InBit: in std_logic;
        clk: in std_logic:= '0';
        OutBit1: out std_logic_vector(1 downto 0));
end component;
signal InBit,clk : std_logic;
signal OutBit1: std_logic_vector(1 downto 0);
begin
ViterbiEncoder : convo_encoder port map (InBit,clk,OutBit1);

process
begin
--     InBit <= '0';
--     wait for 1 ns;
    InBit <= '1';
    wait for 2 ns;
    InBit <= '0';
    wait for 2 ns;
    InBit <= '1';
    wait for 2 ns;
    InBit <= '1';
    wait for 2 ns;
    InBit <= '0';
    wait for 2 ns;
    InBit <= '0';
    wait for 2 ns;
    InBit <= '0';
   -- wait for 2 ns;
   wait;
end process;
                                                    

ClockGen: process
  begin
    for j in 0 to 10 loop
      clk <= '0';
     wait for 1 NS;
      clk <= '1';
      wait for 1 NS;
    end loop;
    report "Simulation finished";
    wait;
  end process ClockGen;
  
end tb ;