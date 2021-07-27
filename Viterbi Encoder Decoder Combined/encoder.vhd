library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

--------------------------------------------------
----------------------Encoder---------------------
--------------------------------------------------
entity convo_encoder is
    port (
        InBit: in std_logic;
        clk: in std_logic;
        OutBit1: out std_logic_vector(1 downto 0)
        --OutBit2: out std_logic
    );
end entity convo_encoder;

architecture behav of convo_encoder is
--4 memory registers
signal reg1: std_logic := '0';
signal reg2: std_logic := '0';
signal reg3: std_logic := '0';
signal reg4: std_logic := '0';
begin
Encoder: process(clk) is
begin
reg1 <= InBit;
--run process on positive clock
if clk = '1' and clk'event then
-- report "InBit=" & std_logic'image(InBit);
-- report "reg2=" & std_logic'image(reg2);
-- report "reg3=" & std_logic'image(reg3);
-- report "reg4=" & std_logic'image(reg4);

OutBit1(1) <= (reg1 xor reg2 xor reg3 xor reg4);
OutBit1(0) <= (reg1 xor reg2 xor reg4);
reg4<=reg3;
reg3<=reg2;
reg2<=reg1; 
-- report "OutBit1=" & std_logic'image(OutBit1);
-- report "OutBit2=" & std_logic'image(OutBit2);
-- report "reg2=" & std_logic'image(reg2);
-- report "reg3=" & std_logic'image(reg3);
-- report "reg4=" & std_logic'image(reg4);

end if;
end process Encoder;
--reg1 <= InBit;


end behav;
