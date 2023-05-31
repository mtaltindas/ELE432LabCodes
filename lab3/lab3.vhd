library IEEE;
use IEEE.std_logic_1164.all;

entity lab3 is
   generic (
		c_clkfreq	:integer:= 50_000_000;
		c_baudrate	:integer:= 115_200;
		c_stopbit	:integer:= 2

	);
   port (
		
		clk      		: in  std_logic;            
		--TX PORTS 
		data_in			: in  std_logic_vector(7 downto 0);
		tx_start_i     : in  std_logic;    		
		tx_o				: out std_logic;
		tx_done_tick_o	: out std_logic;
		
		--RX PORTS
		rx_i				: in std_logic;
		dout_o			: out std_logic_vector (7 downto 0);
		rx_done_tick_o	: out std_logic	
	);
end lab3;

architecture Behavioral of lab3 is
	signal c_bittimerlimit	:integer		:= c_clkfreq/c_baudrate;
	signal c_stopbitlimit	:integer		:= (c_clkfreq/c_baudrate)*c_stopbit;

	type states is (S_IDLE,S_START,S_DATA,S_STOP);
	signal txstate:states:=S_IDLE;
	signal rxstate:states:=S_IDLE;
	
	signal txbittimer		:integer range 0 to c_stopbitlimit		:=0;
	signal txbitcounter	:integer range 0 to 7						:=0;	
	signal txshreg			: std_logic_vector(7 downto 0)			:=(others=>'0');
	
	signal rxbittimer		:integer range 0 to c_bittimerlimit		:=0;
	signal rxbitcounter	:integer range 0 to 7						:=0;	
	signal rxshreg			: std_logic_vector(7 downto 0)			:=(others=>'0');
begin

	P_TRANSMITTER:process(clk) begin

		if(rising_edge(clk))then
			case txstate is
			------------------------------------------------------------------------
				when S_IDLE=>
					txbitcounter<=0;
					tx_o<='1';
					tx_done_tick_o<='0';
					if(tx_start_i='1')then
						txstate<=S_START;
						tx_o<='0';
						txshreg	<= data_in;
					end if;
			------------------------------------------------------------------------		
				when S_START=>
					if(txbittimer=c_bittimerlimit-1)then
						txstate<=S_DATA;
						tx_o<=txshreg(0);
						txshreg(7)			<= txshreg(0);
						txshreg(6 downto 0)	<= txshreg(7 downto 1);
						txbittimer<=0;
					else 
						txbittimer<=txbittimer+1;
					end if;
			------------------------------------------------------------------------	
				when S_DATA=>

					if (txbitcounter = 7) then
						if (txbittimer = c_bittimerlimit-1) then
							txbitcounter				<= 0;
							txstate						<= S_STOP;
							tx_o							<= '1';
							txbittimer					<= 0;
						else
							txbittimer					<= txbittimer + 1;					
						end if;			
					else
						if (txbittimer = c_bittimerlimit-1) then
							txshreg(7)					<= txshreg(0);
							txshreg(6 downto 0)		<= txshreg(7 downto 1);					
							tx_o							<= txshreg(0);
							txbitcounter				<= txbitcounter + 1;
							txbittimer					<= 0;
						else
							txbittimer					<= txbittimer + 1;					
						end if;
					end if;
			------------------------------------------------------------------------
				when S_STOP=>
					if(txbittimer=c_stopbitlimit)then
						txstate<=S_IDLE;
						tx_done_tick_o<='1';
						txbittimer<=0;
					else 
						txbittimer<=txbittimer+1;					
					end if;			
			------------------------------------------------------------------------
				end case;
		end if;
	end process P_TRANSMITTER;  

	P_RECEIVER:process (clk) begin
		if (rising_edge(clk)) then

			case rxstate is
			------------------------------------------------------------------------
				when S_IDLE =>
					
					rx_done_tick_o	<='0';
					rxbittimer		<= 0;
					
					if (rx_i = '0') then
						rxstate	<= S_START;
					end if;
			------------------------------------------------------------------------	
				when S_START =>
				
					if (rxbittimer = c_bittimerlimit/2-1) then
						rxstate		<= S_DATA;
						rxbittimer	<= 0;
					else
						rxbittimer	<= rxbittimer + 1;
					end if;
			------------------------------------------------------------------------	
				when S_DATA =>
				
					if (rxbittimer = c_bittimerlimit-1) then
						if (rxbitcounter = 7) then
							rxstate	<= S_STOP;
							rxbitcounter	<= 0;
						else
							rxbitcounter	<= rxbitcounter + 1;
						end if;
						rxshreg		<= rx_i & (rxshreg(7 downto 1));
						rxbittimer	<= 0;
					else
						rxbittimer	<= rxbittimer + 1;
					end if;
				------------------------------------------------------------------------
				when S_STOP =>
				
					if (rxbittimer = c_bittimerlimit-1) then
						rxstate			<= S_IDLE;
						rxbittimer		<= 0;
						rx_done_tick_o	<= '1';
					else
						rxbittimer	<= rxbittimer + 1;
					end if;			
				------------------------------------------------------------------------
				end case;
		end if;
	end process P_RECEIVER;

dout_o	<= rxshreg;


end Behavioral;
