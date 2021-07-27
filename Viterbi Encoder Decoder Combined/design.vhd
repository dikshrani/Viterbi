library ieee;
use ieee.std_logic_1164.all;

entity top_entity is
    port (
        top_input: in std_logic;
        top_clk: in std_logic;
        top_output: out std_logic
    );
end entity top_entity;

architecture struct of top_entity is

signal top_OutBit1: std_logic_vector(1 downto 0);
--signal top_OutBit2: std_logic;


component convo_encoder
port (
InBit: in std_logic;
clk:  in std_logic;
OutBit1: out std_logic_vector(1 downto 0)
--OutBit2: out std_logic
);
end component convo_encoder;


component viterbi
port (
    clk :in std_logic;
	InBits :in std_logic_vector (1 downto 0);
	OutBits :out std_logic 
);
end component viterbi;

begin

U0:
component convo_encoder
port map(
clk  => top_clk,
InBit => top_input,
OutBit1 => top_OutBit1
--OutBit2 => top_OutBit2
);

U1: 
component viterbi
port map (
clk => top_clk,
OutBits => top_output,
InBits => top_OutBit1
--InBits(0) => top_OutBit2
);

end architecture struct;

   
    