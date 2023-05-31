library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity LAB1 is
	generic(
	MIN_COUNT : natural := 0;
			MAX_COUNT : natural := 9
	);
    port (
			
        clk : in std_logic;
        reset : in std_logic;
       
		  count		  : out integer range MIN_COUNT to MAX_COUNT
    );
end entity;

architecture behavioral of LAB1 is
 
begin
    process (clk, reset)
	 variable   counter: integer range MIN_COUNT to MAX_COUNT;
    begin
        if reset = '1' then
            counter:=0;
        elsif rising_edge(clk) then
            if counter = 9 then
                counter := 0;
            else
                counter := counter + 1;
            end if;
        end if;
			count <= counter;
 end process;
    

end architecture;



