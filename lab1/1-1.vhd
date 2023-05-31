-- Quartus Prime VHDL Template
-- Unsigned Multiply

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity LAB1 is

	generic
	(
		DATA_WIDTH_OP : natural := 2;
		DATA_WIDTH_SEL : natural := 4;

	);

	port 
	(
		a	   : in STD_LOGIC_VECTOR ((DATA_WIDTH_OP-1) downto 0);
		b	   : in STD_LOGIC_VECTOR ((DATA_WIDTH_OP-1) downto 0);

		alu_select: in STD_LOGIC_VECTOR ((DATA_WIDTH_SEL-1) downto 0);
		alu_out  : out STD_LOGIC_VECTOR ((DATA_WIDTH_SEL-1) downto 0)
	);

end entity;

architecture rtl of LAB1 is
signal result : std_logic_vector (3 downto 0);

begin
	process(a,b,alu_select)
	begin
     case alu_select is
				when "0000" => result <= a;
            when "0001" => result <= a+1;
            when "0010" => result <= a-1;
				
				when "0011" => result <= b;
				when "0100" => result <= a+b;
			   when "0101" => result <= a-b;
            when "0110" => result <= std_logic_vector(to_unsigned((to_integer(unsigned(A)) * to_integer(unsigned(B))),8)) ;
            when "0111" => result <= 0;
				
				when "0100" => result := not a;
            when "1001" => result := not b;
            when "1010" => result := a and b;
            when "1011" => result := a or b;
				when "1100" => result := a xnor b;
				when "1101" => result := a xor b;
				when "1110" => result := a nor b;
				when "1111" => result := a nand b;
				
            when others => result := (others => '0');
        end case;
	end process;
	alu_out<=result;
end rtl;
