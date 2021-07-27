-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;

entity testbench is
end testbench;

architecture tb of testbench is

signal clk : std_logic;
signal InBits : std_logic_vector (1 downto 0);
signal OutBits : std_logic;

component viterbi is
    port(clk: in std_logic;
        InBits: in std_logic_vector(1 downto 0);
        OutBits: out std_logic
        );
end component;

begin
ViterbiDecoder : viterbi port map (clk, InBits,OutBits);

-- process --2 bit error
-- begin
--     InBits <= "00";
--     wait for 1 ns;
--     InBits <= "01";
--     wait for 2 ns;
--     InBits <= "11";
--     wait for 2 ns;
--     InBits <= "01";
--     wait for 2 ns;
--     InBits <= "11";
--     wait for 2 ns;
--     InBits <= "01";
--     wait for 2 ns;
--     InBits <= "11";
--     wait for 2 ns;
--     InBits <= "11";
--    wait;
-- end process;

-- process --2 bit error
-- begin
--     InBits <= "00";
--     wait for 1 ns;
--     InBits <= "11";
--     wait for 2 ns;
--     InBits <= "11";
--     wait for 2 ns;
--     InBits <= "01";
--     wait for 2 ns;
--     InBits <= "11";
--     wait for 2 ns;
--     InBits <= "01";
--     wait for 2 ns;
--     InBits <= "11";
--     wait for 2 ns;
--     InBits <= "01";
--    wait;
-- end process;

-- process --3 bit error
-- begin
--     InBits <= "00";
--     wait for 1 ns;
--     InBits <= "01";
--     wait for 2 ns;
--     InBits <= "11";
--     wait for 2 ns;
--     InBits <= "01";
--     wait for 2 ns;
--     InBits <= "11";
--     wait for 2 ns;
--     InBits <= "01";
--     wait for 2 ns;
--     InBits <= "11";
--     wait for 2 ns;
--     InBits <= "01";
--    wait;
-- end process;

process --normal sequence

begin
    InBits <= "11";
    wait for 2 ns;
    InBits <= "11";
    wait for 2 ns;
    InBits <= "01";
    wait for 2 ns;
    InBits <= "11";
    wait for 2 ns;
    InBits <= "01";
    wait for 2 ns;
    InBits <= "01";
    wait for 2 ns;
    InBits <= "11";
   wait;
end process;


ClockGen: process
type output_array_type is array (0 to 6) of std_logic; 
--expected Output
	constant output_seq : output_array_type :=('1','0','1','1','0','0','0');
variable index : integer := 0;
  begin
    for j in 0 to 15 loop
      clk <= '0';
     wait for 1 NS;
      clk <= '1';      
     wait for 1 NS;
     
     if j>6 then      
      	if OutBits = output_seq(index) then
      		report " PASS for input : "& Integer'image(index);
        else
        	assert false report "Fail in input sequence : " & Integer'image(index) severity error;
      	end if;
      	if index < 6 then
      		index := index +1;
      	end if;
      end if;
      
    end loop;
    report "Simulation finished";
    wait;
  end process ClockGen;
  
end tb ;