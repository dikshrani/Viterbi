library ieee;
use ieee.std_logic_1164.all;

entity viterbi is
port (
	clk :in std_logic;
	InBits :in std_logic_vector (1 downto 0);
	OutBits :out std_logic 
);
end viterbi;

architecture behav of viterbi is
type BIT_ARRAY_ENCODER is array (8 downto 0) of std_logic;
type datain is array (0 to 15) of BIT_ARRAY_ENCODER;

type BIT_ARRAY is array (2 downto 0) of std_logic;
type OUTPUT is array (0 to 6) of std_logic;
type MEM1 is array (0 to 1) of BIT_ARRAY;
type MEM2 is array (0 to 3) of BIT_ARRAY;
type MEM3 is array (0 to 7) of BIT_ARRAY;
type MEM4 is array (0 to 15) of BIT_ARRAY;

type INT_ARRAY is array (integer range <>) of integer;
type ALL_METRICS is array (0 to 7) of INT_ARRAY(0 to 6);

--array of hamming distances upto 2 values fr each state
--type path_metric is array(0 to 7) of INT_ARRAY(0 to 2);
type path_metric is array(0 to 15) of INT_ARRAY(0 to 1);

signal instates : datain :=    (("000000000"),
								("100011100"),
								("000111000"),
								("100100100"),
								("001010001"),
								("101001101"),
								("001101001"),
								("101110101"),
								("010011010"),
								("110000110"),
								("010100010"),
								("110111110"),
								("011001011"),
								("111010111"),
								("011110011"),
								("111101111")); 
                                
subtype T_2 is std_logic_vector(3 downto 0);
subtype T_1 is std_logic_vector(2 downto 0);

--function to convert std_logic_vector to int
function conv_int(state : BIT_ARRAY) return integer is
begin  
  case state is
	  when "000" =>
		  return 0;
	  when "001" =>
		  return 1;
	  when "010" =>
		  return 2;
	  when "011" =>
		  return 3;
      when "100" =>
		  return 4;
	  when "101" =>
		  return 5;
	  when "110" =>
		  return 6;
	  when "111" =>
		  return 7;
	  when others => 
		 return -1; --invalid operation
 end case; 
end conv_int;

--function to give output bits corresponding to input state 
function find_output(state : integer) return std_logic is
begin  
if state < 4 then
return '0';
else
return '1';
end if;  
end find_output;

--function to convert int to std_logic_vector 
function conv_bit(state : integer) return BIT_ARRAY is
begin  
  case state is
	  when 0 =>
		  return "000";
	  when 1 =>
		  return "001";
	  when 2 =>
		  return "010";
	  when 3 =>
		  return "011";
      when 4 =>
		  return "100";
	  when 5 =>
		  return "101";
	  when 6 =>
		  return "110";
	  when 7 =>
		  return "111";
	  when others => 
		 return "000"; --invalid operation
 end case; 
end conv_bit;

--function to calculate hamming distance/path metric
-- c & d => input bits a & d state output bits
function pathMetric(a : std_logic; b : std_logic; c : std_logic; d : std_logic) return integer is
variable o: std_logic_vector(1 downto 0) ;
begin
 o := (a & b) xnor (c & d);
case o is
	  when "00" =>
		  return 0;
	  when "01" =>
		  return 1;
	  when "10" =>
		  return 1;
	  when "11" =>
		  return 2;
      when others => 
	  return -1; --invalid operation
end case;
end pathMetric;

--function to calculate maximum hamming distance/path metric
function calc_max_path(inputarray : path_metric) return INT_ARRAY is
variable maxpath:integer:=inputarray(0)(0); --init
variable max_arr: INT_ARRAY(0 to 7);
begin
	for i in 0 to 7 loop
    maxpath := inputarray(i)(0);
      for j in 0 to 1 loop
		if inputarray(i)(j)  > maxpath then        	
			maxpath := inputarray(i)(j);            
		end if; 
        max_arr(i) := maxpath;
      end loop;
	end loop;
return max_arr;
end calc_max_path;

--function to calculate maximum hamming distance/path metric and corresponding state at each stage for backtracing
function calc_maxpath_backtrace(inputarray : INT_ARRAY(0 to 7)) return path_metric is
variable state : integer := 0;
variable maxvalue : integer := 0;
variable index : integer := 0;
variable output : path_metric := (others => (others => 0));
begin
	for state in 0 to 7 loop
		if inputarray(state)  > maxvalue then        	
			maxvalue := inputarray(state); 
		end if; 
    end loop;
	for state in 0 to 7 loop
		if inputarray(state)  = maxvalue then        	
			output(index)(1) := state; 
            output(index)(0) := maxvalue; 
            index := index + 1;
		end if; 
    end loop;
return output;
end calc_maxpath_backtrace;


--function to calculate hamming distance for each state
function calc_hamming_dist(inputarray : path_metric) return path_metric is
variable index : integer := 0;
variable value : integer := 0;
variable hamming : path_metric := (others => (others => 0));
begin
	for i in 0 to inputarray'high loop		
       index := inputarray(i)(1);
       value := inputarray(i)(0);
       if hamming(index)(0) > 0 then       
        hamming(index)(1) := value;        
       else
        hamming(index)(0) := value;	   	
	   end if; 
	end loop;
  return hamming;
end calc_hamming_dist;

begin
Decoder: process(clk) is

variable stage1 : MEM1; --2 output states at stage 1
variable stage2 : MEM2; --4 output states at stage 2
variable stage3 : MEM3; --8 output states at stage 3
variable stage4 : MEM4; --16 output states at stage 4
--after 4th stage every stage has 8 input states and 16 output states corresponding to bit 0 and 1
---------------------------------------------------------------------
variable spm : INT_ARRAY(0 to 15); --to store path metric at each stage for all output states
variable stage_count : integer := 0; --for iteration up to 7 stages 
variable stage_back : integer := 6; --for iteration up to 7 stages
variable inputdata: BIT_ARRAY;
variable outstate: BIT_ARRAY;
variable metrices : INT_ARRAY(0 to 7);
variable index: integer := 0;
variable hamm_dist : ALL_METRICS := (others => (others => 0));
variable hamming_dist4 : path_metric := (others => (others => 0));
variable hamming_dist : path_metric := (others => (others => 0));
variable metrics_check : path_metric := (others => (others => 0));
variable hamming_dist_after_rejection : INT_ARRAY(0 to 7) := (others => 0);
variable curr_state  : integer := 0;
variable prev_state  : integer := 0;
variable output_bits : OUTPUT; --to store all output bits
variable DECODED : std_logic := '0'; --check this bit to send output bits from next clock cycle
begin
	 
	if clk = '1' and clk'event and DECODED = '0' and InBits /= "UU" then --run process on positive clock		
		case stage_count is	
        --STAGE 1
		    when 0 =>           
			inputdata := "000";
            --give 0 to state 000
			for i in 0 to 15 loop --traverse the instates look up table
				if T_2'("0" & inputdata(2) & inputdata(1) & inputdata(0)) = (instates(i)(8) & instates(i)(7) & instates(i)(6) & instates(i)(5)) then
					stage1(0) := instates(i)(2) & instates(i)(1) & instates(i)(0);--store output state to give input to the next stage                     
 					spm (0) := pathMetric(instates(i)(4), instates(i)(3),InBits(1),InBits(0)); --to store path metric at each stage for all output states                   
                    curr_state := conv_int(stage1(0));                    
                    hamm_dist(curr_state)(stage_count) := spm (0); --store hamming distances/path metrics                 
                end if;
            end loop;
           --give 1 to state 000 
            for i in 0 to 15 loop --traverse the instates look up table
              if T_2'("1" & inputdata(2) & inputdata(1) & inputdata(0)) = instates(i)(8) & instates(i)(7) & instates(i)(6) & instates(i)(5) then
                  stage1(1) := instates(i)(2) & instates(i)(1) & instates(i)(0);                
                  spm (1) := pathMetric(instates(i)(4), instates(i)(3),InBits(1),InBits(0));                      
                  curr_state := conv_int(stage1(1));
                  hamm_dist(curr_state)(stage_count) := spm (1);
              end if;                 
			end loop;

           ----------------------------------------------------------------------------------     
           --STAGE 2
		    when 1 =>
			for j in 0 to 1 loop -- to traverse all input states
				inputdata := stage1(j);
                prev_state := conv_int(inputdata);
				for i in 0 to 15 loop --traverse the instates look up table
                --give 0 to input states
					if T_2'("0" & inputdata(2) & inputdata(1) & inputdata(0)) = (instates(i)(8) & instates(i)(7) & instates(i)(6) & instates(i)(5)) then
						stage2(2*j):= instates(i)(2) & instates(i)(1) & instates(i)(0);
                        spm (2*j) := pathMetric(instates(i)(4), instates(i)(3),InBits(1),InBits(0));                                         
                   		curr_state := conv_int(stage2(2*j));
            			hamm_dist(curr_state)(stage_count) := hamm_dist(prev_state)(stage_count-1) + spm (2*j); --add previous stage's hamming distance to current 

                     end if;
                end loop;
                for i in 0 to 15 loop --traverse the instates look up table
                --give 1 to input states
					if T_2'("1" & inputdata(2) & inputdata(1) & inputdata(0)) = instates(i)(8) & instates(i)(7) & instates(i)(6) & instates(i)(5) then
						stage2(2*j+1):= instates(i)(2) & instates(i)(1) & instates(i)(0);
                        spm (2*j+1) := pathMetric(instates(i)(4), instates(i)(3), InBits(1), InBits(0));
                        curr_state := conv_int(stage2(2*j+1));
                  		hamm_dist(curr_state)(stage_count) := hamm_dist(prev_state)(stage_count-1) + spm (2*j+1);
					end if; 
				end loop;
			end loop;            
          
			----------------------------------------------------------------------------------------------------			
			--STAGE 3
		    when 2 =>
			for j in 0 to 3 loop 
				inputdata := stage2(j);
                prev_state := conv_int(inputdata);
				for i in 0 to 15 loop
                --give 0 to input states
					if T_2'("0" & inputdata(2) & inputdata(1) & inputdata(0)) = (instates(i)(8) & instates(i)(7) & instates(i)(6) & instates(i)(5)) then
						stage3(2*j):= instates(i)(2) & instates(i)(1) & instates(i)(0);
                        spm (2*j) := pathMetric(instates(i)(4), instates(i)(3), InBits(1), InBits(0));
						curr_state := conv_int(stage3(2*j));
                  		hamm_dist(curr_state)(stage_count) := hamm_dist(prev_state)(stage_count-1) +  spm (2*j);                        
                     end if;
                end loop;
                for i in 0 to 15 loop
                --give 1 to input states
					if T_2'("1" & inputdata(2) & inputdata(1) & inputdata(0)) = (instates(i)(8) & instates(i)(7) & instates(i)(6) & instates(i)(5)) then
						stage3(2*j+1):= instates(i)(2) & instates(i)(1) & instates(i)(0);
                        spm (2*j+1) := pathMetric(instates(i)(4), instates(i)(3), InBits(1), InBits(0));
                       
						curr_state := conv_int(stage3(2*j+1));
                  		hamm_dist(curr_state)(stage_count) := hamm_dist(prev_state)(stage_count-1) +  spm (2*j+1);
					end if;                
				end loop;
			end loop;
            
---------------------------------------------------------------------------------------------------		  ----STAGE 4
		    when 3 =>
			for j in 0 to 7 loop 
				inputdata := stage3(j);
                prev_state := conv_int(inputdata);
				for i in 0 to 15 loop
                --give 0 to input states
					if T_2'("0" & inputdata(2) & inputdata(1) & inputdata(0)) = (instates(i)(8) & instates(i)(7) & instates(i)(6) & instates(i)(5)) then
						stage4(2*j):= instates(i)(2) & instates(i)(1) & instates(i)(0);
                        spm (2*j) := pathMetric(instates(i)(4), instates(i)(3), InBits(1), InBits(0));
                        curr_state := conv_int(stage4(2*j));
            			hamming_dist(2*j)(0) := hamm_dist(prev_state)(stage_count-1) + spm (2*j);
                        hamming_dist(2*j)(1) := curr_state; --store path metric of each state in 1st column and corresponding state value converted to integer in 2nd column
                    end if;
                end loop;
                for i in 0 to 15 loop  
                --give 1 to input states
					if T_2'("1" & inputdata(2) & inputdata(1) & inputdata(0)) = instates(i)(8) & instates(i)(7) & instates(i)(6) & instates(i)(5) then
					stage4(2*j+1):= instates(i)(2) & instates(i)(1) & instates(i)(0);
                    spm (2*j+1) := pathMetric(instates(i)(4), instates(i)(3), InBits(1), InBits(0));
                    curr_state := conv_int(stage4(2*j+1));
            		hamming_dist(2*j+1)(0) := hamm_dist(prev_state)(stage_count-1) + spm (2*j+1);
                    hamming_dist(2*j+1)(1) := curr_state;   
					end if; 
				end loop;
                hamming_dist4 := calc_hamming_dist(hamming_dist); --store multiple values of path metrics possible for each state in array of arrays 8 x2
                hamming_dist_after_rejection := calc_max_path(hamming_dist4); --keep maximum value of path metric at each state and reject others
			for i in 0 to 7 loop            
            hamm_dist(i)(stage_count) := hamming_dist_after_rejection(i);--store hamming_dist_after_rejection for this stage to 8x7 array 
            end loop;
            
            end loop;
            
---print statements to check                 
            for i in 0 to 7 loop            
            report "hamming 8X7=" & integer'image(hamm_dist(i)(0)) & integer'image(hamm_dist(i)(1)) & integer'image(hamm_dist(i)(2)) & integer'image(hamm_dist(i)(3)) & integer'image(hamm_dist(i)(4)) & integer'image(hamm_dist(i)(5)) & integer'image(hamm_dist(i)(6));
            end loop;
            for i in 0 to 15 loop
            report "hamming 16X2=" & integer'image(hamming_dist(i)(0)) & integer'image(hamming_dist(i)(1));
            end loop;
          for i in 0 to 7 loop           
           report "hammingDISTANCE=" & integer'image(hamming_dist4(i)(0)) & integer'image(hamming_dist4(i)(1));
            --report "After rejection=" & integer'image(hamming_dist_after_rejection(i)) ;
         end loop;    
         for i in 0 to 7 loop           
            report "After rejection=" & integer'image(hamming_dist_after_rejection(i)) ;
         end loop; 
---------------------------------------------------------------------------------------
			--STAGE 5
		    when 4 =>
			for j in 0 to 7 loop 
				inputdata :=stage3(j);
                prev_state := conv_int(inputdata);
				for i in 0 to 15 loop
                --give 0 to input states
					if T_2'("0" & inputdata(2) & inputdata(1) & inputdata(0)) = (instates(i)(8) & instates(i)(7) & instates(i)(6) & instates(i)(5)) then
					   stage4(2*j):= instates(i)(2) & instates(i)(1) & instates(i)(0);
                       spm (2*j) := pathMetric(instates(i)(4), instates(i)(3), InBits(1), InBits(0));
                       curr_state := conv_int(stage4(2*j));
            		   hamming_dist(2*j)(0) := hamming_dist_after_rejection(prev_state) + spm (2*j);
                       hamming_dist(2*j)(1) := curr_state;
					end if;
                end loop;
                
                for i in 0 to 15 loop
                --give 1 to input states
                    if T_2'("1" & inputdata(2) & inputdata(1) & inputdata(0)) = instates(i)(8) & instates(i)(7) & instates(i)(6) & instates(i)(5) then
						stage4(2*j+1):= instates(i)(2) & instates(i)(1) & instates(i)(0);
                       spm (2*j+1) :=  pathMetric(instates(i)(4), instates(i)(3), InBits(1), InBits(0));
                    curr_state := conv_int(stage4(2*j+1));
            		hamming_dist(2*j+1)(0) := hamming_dist_after_rejection(prev_state) + spm (2*j+1);
                    hamming_dist(2*j+1)(1) := curr_state;
					end if; 
				end loop;
                hamming_dist4 := calc_hamming_dist(hamming_dist);
                hamming_dist_after_rejection := calc_max_path(hamming_dist4);
            for i in 0 to 7 loop            
            hamm_dist(i)(stage_count) := hamming_dist_after_rejection(i);
            end loop;
            
			end loop;
            
----------------------------------------------------------------------------------------------------     
            --STAGE 6		  
		    when 5 =>
			for j in 0 to 7 loop 
				inputdata := stage3(j);
                prev_state := conv_int(inputdata);
				for i in 0 to 15 loop 
                --give 0 to input states
					if T_2'("0" & inputdata(2) & inputdata(1) & inputdata(0)) = (instates(i)(8) & instates(i)(7) & instates(i)(6) & instates(i)(5)) then 
						stage4(2*j):= instates(i)(2) & instates(i)(1) & instates(i)(0);
                        spm (2*j) := pathMetric(instates(i)(4), instates(i)(3), InBits(1), InBits(0));
                       curr_state := conv_int(stage4(2*j));
            		   hamming_dist(2*j)(0) := hamming_dist_after_rejection(prev_state) + spm (2*j);
                       hamming_dist(2*j)(1) := curr_state;
                     end if;
                 end loop;
                 for i in 0 to 15 loop
                 --give 1 to input states
					if T_2'("1" & inputdata(2) & inputdata(1) & inputdata(0)) = instates(i)(8) & instates(i)(7) & instates(i)(6) & instates(i)(5) then
						stage4(2*j+1):= instates(i)(2) & instates(i)(1) & instates(i)(0);
                       spm (2*j+1) := pathMetric(instates(i)(4), instates(i)(3), InBits(1), InBits(0));      
                    curr_state := conv_int(stage4(2*j+1));
            		hamming_dist(2*j+1)(0) := hamming_dist_after_rejection(prev_state) + spm (2*j+1);
                    hamming_dist(2*j+1)(1) := curr_state;
					end if; 
				end loop;
                hamming_dist4 := calc_hamming_dist(hamming_dist);
                hamming_dist_after_rejection := calc_max_path(hamming_dist4);
                
            for i in 0 to 7 loop            
            hamm_dist(i)(stage_count) := hamming_dist_after_rejection(i);
            end loop;
                
			end loop;

---------------------------------------------------------------------------------------------   
			--STAGE 7
		    when 6 =>
			for j in 0 to 7 loop
				inputdata := stage3(j);
				for i in 0 to 15 loop
                --give 0 to input states
					if T_2'("0" & inputdata(2) & inputdata(1) & inputdata(0)) = (instates(i)(8) & instates(i)(7) & instates(i)(6) & instates(i)(5)) then
					stage4(2*j):= instates(i)(2) & instates(i)(1) & instates(i)(0);
                     spm (2*j) := pathMetric(instates(i)(4), instates(i)(3), InBits(1), InBits(0));
					curr_state := conv_int(stage4(2*j));
            		hamming_dist(2*j)(0) := hamming_dist_after_rejection(prev_state) + spm (2*j);
                    hamming_dist(2*j)(1) := curr_state;
                    end if;
                end loop;
                for i in 0 to 15 loop
                --give 1 to input states
                    if T_2'("1" & inputdata(2) & inputdata(1) & inputdata(0)) = instates(i)(8) & instates(i)(7) & instates(i)(6) & instates(i)(5) then
					stage4(2*j+1):= instates(i)(2) & instates(i)(1) & instates(i)(0);
                    spm (2*j+1) := pathMetric(instates(i)(4), instates(i)(3), InBits(1), InBits(0));
                    curr_state := conv_int(stage4(2*j+1));
            		hamming_dist(2*j+1)(0) := hamming_dist_after_rejection(prev_state) + spm (2*j+1);
                    hamming_dist(2*j+1)(1) := curr_state;
					end if; 
				end loop;
                hamming_dist4 := calc_hamming_dist(hamming_dist); 
                hamming_dist_after_rejection := calc_max_path(hamming_dist4);
                
            for i in 0 to 7 loop            
            hamm_dist(i)(stage_count) := hamming_dist_after_rejection(i);
            end loop;
            hamm_dist(0)(stage_count) := hamming_dist_after_rejection(7)+2;
			end loop;
            
            for i in 0 to 7 loop            
            report "hamming 8X7=" & integer'image(hamm_dist(i)(0)) & integer'image(hamm_dist(i)(1)) & integer'image(hamm_dist(i)(2)) & integer'image(hamm_dist(i)(3)) & integer'image(hamm_dist(i)(4)) & integer'image(hamm_dist(i)(5)) & integer'image(hamm_dist(i)(6));
            end loop; 
            
---backtracing from 6th to 2nd stages             
for i in 6 downto 2 loop
stage_back:= i;
      for i in 0 to 7 loop            
      metrices(i) := hamm_dist(i)(stage_back);
      end loop;
      
	  metrics_check :=  calc_maxpath_backtrace(metrices); --contains max path metric on 1st column and corresponding state (bits converted to integer format) in 2nd column
--       report "MAXIMUM METRICS=" & integer'image(metrics_check(0)(0)) & integer'image(metrics_check(0)(1)) ;
--       report "MAXIMUM METRICS=" & integer'image(metrics_check(1)(0)) & integer'image(metrics_check(1)(1)) ;
	              
      outstate := conv_bit(metrics_check(0)(1));--convert state to std_logic vector form
      
      if metrics_check(1)(0) = 0 then --check if only one maximum path metric at this stage
      output_bits(stage_back) := find_output(metrics_check(0)(1));--assign 0 or 1 as output bit based on state
      
      else --if 2 maximum path metric values at this stage
      --select one state and reject others   
      	--check if there is a path to previous stage's state with maximum path metric        
      		for i in 0 to 7 loop            
      		metrices(i) := hamm_dist(i)(stage_back-1);
      		end loop;
	  		metrics_check :=  calc_maxpath_backtrace(metrices);
           
      		inputdata := conv_bit(metrics_check(0)(1)); --store previous state and check if path exists to it from current states with max path metric values
      
      		for j in 0 to 15 loop --traverse in LUT to check if path exists
      		if (T_1'(inputdata(2) & inputdata(1) & inputdata(0)) = (instates(j)(7) & instates(j)(6) & instates(j)(5))) and (T_1'(outstate(2) & outstate(1) & outstate(0)) = (instates(j)(2) & instates(j)(1) & instates(j)(0))) then
      		output_bits(stage_back) := find_output(metrics_check(0)(1));
      		else
      		output_bits(stage_back) := find_output(metrics_check(1)(1));
      		end if;
      		end loop;
     end if;  --only one maximum 
end loop;

---backtracing to 1st stage. for stages 1 and 0 there are less than 8 output states for every input state. These stages are be checked with respect to next stages rather than previous.           
stage_back:= 1;      
      for i in 0 to 7 loop            
      metrices(i) := hamm_dist(i)(stage_back);
      end loop;
      
	  metrics_check :=  calc_maxpath_backtrace(metrices);
--       report "MAXIMUM METRICS=" & integer'image(metrics_check(0)(0)) & integer'image(metrics_check(0)(1)) ;
--       report "MAXIMUM METRICS=" & integer'image(metrics_check(1)(0)) & integer'image(metrics_check(1)(1)) ;
	              
      outstate := conv_bit(metrics_check(0)(1));
            
      if metrics_check(1)(0) = 0 then --only one maximum path metric
      output_bits(stage_back) := find_output(metrics_check(0)(1));     
      
      else --if 2 maximum
      	for i in 0 to 7 loop            
      	metrices(i) := hamm_dist(i)(stage_back+1); --check next stage's maximum path metric and corresponding state
      	end loop;
	  	metrics_check :=  calc_maxpath_backtrace(metrices);
      
      	for i in 0 to 7 loop --check all states in stage 3 (2nd stage if starting from 0)
      		if metrics_check(0)(1) = conv_int(stage3(i))  then
      			if i/2 = 0 then --if max value is at even index at stage3 then for current stage2 selected state will be odd   
                index := (i - 1)/2; --state at odd index is selected for current stage            
        		output_bits(stage_back) := '1';
                hamm_dist(index + 2)(stage_back) := 0; --reset rejected state's hamming distance to 0
        		else
        		output_bits(stage_back) := '0';
                index := i/2;--if max value is at odd index at stage3 then for current stage2 selected state will be even 
                hamm_dist(index + 2)(stage_back) := 0;--reset rejected state's hamming distance to 0
        		end if;
      		end if;
         index := 0;
      	end loop;--check all states in stage 3 
       end if;
       
---backtracing to 1st stage. for stages 1 and 0 there are less than 8 output states for every input state. These stages are be checked with respect to next stages rather than previous.   
stage_back:= 0;      
      for i in 0 to 7 loop            
      metrices(i) := hamm_dist(i)(stage_back);
      end loop;
      
	  metrics_check :=  calc_maxpath_backtrace(metrices);
--       report "MAXIMUM METRICS=" & integer'image(metrics_check(0)(0)) & integer'image(metrics_check(0)(1)) ;
--       report "MAXIMUM METRICS=" & integer'image(metrics_check(1)(0)) & integer'image(metrics_check(1)(1)) ;
	              
      outstate := conv_bit(metrics_check(0)(1));
          
      if metrics_check(1)(0) = 0 then --only one maximum
      output_bits(stage_back) := find_output(metrics_check(0)(1));
      
      else --if 2 maximum
      	for i in 0 to 7 loop            
      	metrices(i) := hamm_dist(i)(stage_back+1);
      	report "hamming 8X1=" & integer'image(metrices(i)) ;
      	end loop;
	  	metrics_check :=  calc_maxpath_backtrace(metrices);
      
      	for i in 0 to 3 loop
      		if metrics_check(0)(1) = conv_int(stage2(i))  then
      		if i/2 = 0 then  --if max value is at even index at stage2 then for current stage1 given input was 0         	
        	output_bits(stage_back) := '0';
        	else        	
        	output_bits(stage_back) := '1';
        	end if;
      		end if;
      	end loop;
      end if; --if 2 maximum	

---print all output bits here    
    for i in 0 to 6 loop            
        report "OUTPUT=" & std_ulogic'image(output_bits(i)) ;
    end loop;
            
	DECODED := '1'; ---all input bits are decoded now send output bits 
           		    
            when others =>null; --invalid stage count
		end case;
        
 	if stage_count < 6 then
 		stage_count := stage_count + 1; --increment stage count until 6th stage starting from 0
    else
        stage_count := 7;
    end if;


elsif  clk = '1' and clk'event and DECODED = '1' then   --run process on positive clock
--     ---all input bits are decoded now send output bits    
    OutBits <= output_bits(index); --assign output bits
    if index < 6 then
    index := index + 1; 
    end if;
    
end if; ----run process on positive clock
	
end process Decoder;
    
end behav;
	
