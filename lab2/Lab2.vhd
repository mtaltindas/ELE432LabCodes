
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Lab2 is
    port 
    (
	clk        	:in STD_LOGIC;
        a          	:in STD_LOGIC_VECTOR((3) downto 0) := (others => '0');
        b          	:in STD_LOGIC_VECTOR((3) downto 0) := (others => '0');
        opcode 		:in STD_LOGIC_VECTOR((3) downto 0) := (others => '0');
	sel	   	:in STD_LOGIC := ('1');
	reset	   	:in STD_LOGIC:= ('0');
	load_A		:in STD_LOGIC:= ('1');
	load_B		:in STD_LOGIC:= ('1');

	A_out 		:out std_logic_vector(3 downto 0) := (others => '0');
	B_out 		:out std_logic_vector(3 downto 0) := (others => '0');
        alu_out    	:out STD_LOGIC_VECTOR(3 downto 0) := (others => '0')
    );
end entity;

architecture rtl of Lab2 is
        
	signal MuxA_out 	: std_logic_vector(3 downto 0) 	:= (others => '0');
	signal MuxB_out 	: std_logic_vector(3 downto 0) 	:= (others => '0');
	signal RegA_out		: std_logic_vector(3 downto 0) 	:= (others => '0');
	signal RegB_out		: std_logic_vector(3 downto 0) 	:= (others => '0');
    	signal result 		: std_logic_vector(3 downto 0) 	:= (others => '0');
		
	signal SELB: std_logic_vector(6 downto 0);		
	component hex2led IS
	PORT (
		HEX : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		LED : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
	);
	END component;			
		
begin
HEX0: hex2led port map (b, SELB);
---------------------------------------------------------------------
    	--MUX_A PROCESS
	process (a,result,sel)begin
		if sel='0' then
			MuxA_out<=result;
		else 
			MuxA_out<=a;
		end if;
	end process;
    	--MUX_B PROCESS
	process (b,result,sel)
	begin
		if sel='0' then
			MuxB_out<=result;
		else 
			MuxB_out<=b;
		end if;
	end process;
---------------------------------------------------------------------
	--Reg_A & Reg_B PROCESS
	process (clk, reset) begin
 		if (reset = '1')  then 
			RegA_out <= "0000"; 
			RegB_out <= "0000"; 
		end if;
		if (load_A = '1') then 
			RegA_out <= MuxA_out;
		end if;
		if (load_B = '1') then 
			RegB_out <= MuxB_out;
		end if;
	end process;
	A_out<=RegA_out;
	B_out<=RegB_out;
---------------------------------------------------------------------
---------------------------------------------------------------------
    	--ALU PROCESS
    	process(RegA_out,RegB_out,opcode)
    	begin
        	case(opcode) is
		--arithmetic operators
            	when "0000" => result <= (RegA_out);
            	when "0001" => result <= (RegA_out+1);
            	when "0010" => result <= (RegA_out-1);
            	when "0011" => result <= (RegB_out);
            	when "0100" => result <= (RegA_out)+(RegB_out);
            	when "0101" => result <= (RegA_out+ (not (RegB_out)+"001"));
            	when "0110" => result <= std_logic_vector(to_unsigned((to_integer(unsigned(a)) 
							* to_integer(unsigned(b))),4));
            	when "0111" => result <= "0000";
		--logical operators
            	when "1000" => result <= not (RegA_out);
            	when "1001" => result <= not (RegB_out);
            	when "1010" => result <= (RegA_out) and (RegB_out);
            	when "1011" => result <= (RegA_out) or (RegB_out);
            	when "1100" => result <= (RegA_out) nand (RegB_out);
            	when "1101" => result <= (RegA_out) nor (RegB_out);
            	when "1110" => result <= (RegA_out) xor (RegB_out);
            	when "1111" => result <= (RegA_out) xnor (RegB_out);
            	when others => result <= (others => '0');
        	end case;
    	end process;
    alu_out <= result;
end rtl;

