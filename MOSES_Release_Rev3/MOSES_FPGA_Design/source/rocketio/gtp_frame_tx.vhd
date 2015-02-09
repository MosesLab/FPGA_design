
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity gtp_frame_tx is
port
(
    -- User Interface
	TX_DATA				: out std_logic_vector(7 downto 0);
	TX_CHARISK			: out std_logic; 

	-- System Interface
	USER_CLK			: in std_logic;      
	SYSTEM_RESET		: in std_logic;

	lb_a				: in std_logic_vector(5 downto 2);
	lb_di				: in std_logic_vector(31 downto 0);
	lb_do				: out  std_logic_vector(31 downto 0);
	lb_we				: in std_logic_vector(3 downto 0); 
	lb_en				: in std_logic; 
	lb_clk				: in std_logic;  
	
	lb_start			: in std_logic;
	lb_sz				: in std_logic_vector(7 downto 0);
	lb_done				: out std_logic
); 
end gtp_frame_tx;

architecture RTL of gtp_frame_tx is

--***********************************Parameter Declarations********************
	component dpa64x8_b16x32 IS
		port (
	clka: IN std_logic;
	dina: IN std_logic_VECTOR(7 downto 0);
	addra: IN std_logic_VECTOR(5 downto 0);
	ena: IN std_logic;
	wea: IN std_logic_VECTOR(0 downto 0);
	douta: OUT std_logic_VECTOR(7 downto 0);
	clkb: IN std_logic;
	dinb: IN std_logic_VECTOR(31 downto 0);
	addrb: IN std_logic_VECTOR(3 downto 0);
	enb: IN std_logic;
	web: IN std_logic_VECTOR(3 downto 0);
	doutb: OUT std_logic_VECTOR(31 downto 0));
	END component dpa64x8_b16x32;

    constant DLY : time := 1 ns;

--********************************* Wire Declarations************************** 

    --signal  tied_to_ground_vec_i    :   std_logic_vector(7 downto 0);
    --signal  tied_to_ground_i        :   std_logic;
    --signal  tied_to_vcc_i           :   std_logic;
    --signal  tied_to_vcc_vec_i       :   std_logic_vector(15 downto 0);
	--signal dob_float : std_logic_vector(7 downto 0);

--***************************Internal signalister Declarations******************** 

    signal  rd_cnt          :   unsigned(6 downto 0);    

    signal doa             : std_logic_vector(7 downto 0);
    

--*********************************Main Body of Code***************************

	
	signal done_r2 : std_logic;
	signal done_r  : std_logic;
	
	
	signal start_r	: std_logic;
	signal start_r2 : std_logic;
	signal start_r3 : std_logic;
	signal start_r4 : std_logic;
	
	signal sz_r : std_logic_vector(7 downto 0);
	signal sz_r2 : std_logic_vector(7 downto 0);
	
	signal tx_last : std_logic;
	signal tx_last_r : std_logic;
	signal tx_last_r2 : std_logic;
	signal tx_last_r3 : std_logic;
	
	signal doa_r				:  std_logic_vector(7 downto 0);
	signal TX_CHARISK_r			:  std_logic; 
	
	signal doa_r2				:  std_logic_vector(7 downto 0);
	signal TX_CHARISK_r2			:  std_logic; 	
begin

	-- clock domain crossing

	process(user_clk)
	begin
		if rising_edge(user_clk) then
			start_r <= lb_start;
			start_r2 <= start_r;
			
			sz_r <= lb_sz;
			sz_r2 <= sz_r;
		end if; 
	end process;
	
	process(lb_CLK)
	begin
		if rising_edge(lb_CLK) then
			done_r <= (tx_last_r3 and start_r2);
			done_r2 <= done_r;
		end if; 
	end process;	
	
	lb_done <= done_r2;
	
	------------------------------------------------

    --tied_to_ground_vec_i    <=   (others=>'0');
    --tied_to_ground_i        <=   '0';
--    tied_to_vcc_i           <=   '1';
            
    -- Counter to read from BRAM   
    
    process( USER_CLK )
    begin
        if(USER_CLK'event and USER_CLK = '1') then
            if (SYSTEM_RESET='1') or  (start_r2 = '0')then
                rd_cnt <= (others => '0') after DLY;
            else
				if (start_r2 = '1') and (rd_cnt < unsigned('0' & sz_r2)) then
					rd_cnt <= rd_cnt + 1 after DLY;
				end if;
            end if;
        end if;
    end process;
	
    process( USER_CLK )
    begin
        if( rising_edge(USER_CLK) ) then
			if system_reset = '1' then
				tx_last_r <= '0';
				tx_last_r2 <= '0';
				tx_last_r3 <= '0';
				
				start_r3 <= '0';
				start_r4 <= '0';
			else
				tx_last_r <= tx_last;
				tx_last_r2 <= tx_last_r;
				tx_last_r3 <= tx_last_r2;
			
				start_r3 <= start_r2;
				start_r4 <= start_r3;
			
			end if;
        end if;
    end process;	
	
	tx_last <= '1' when (rd_cnt = unsigned('0' & sz_r2)) else '0';

    -- BRAM Instantiation 

	-- can only address 2^6 = 64 locations from the lb side,


	
    --dual_port_block_ram_i  :  RAMB16_S36_S36 
	u_dp : dpa64x8_b16x32
    port map 
    (
        addra            	=>  std_logic_vector(rd_cnt(5 downto 0)),
        dina              	=>  x"00", --tied_to_ground_vec_i(7 downto 0),
        douta              	=>  doa,
        wea(0)             	=>  '0',
        ena              	=>  '1',
        clka             	=>  USER_CLK,
                         
        addrb		 		=>  lb_a,
        dinb			  	=>  lb_di,
        doutb  				=>  lb_do,  
        WEB              =>  lb_we,
        ENB             	=>  lb_en,
        CLKB            	=>  lb_CLK       
    );                   

-- * note there is a two cycle latency on a read from the block memory
-- cycle 1 to get data from mem
-- cycle 2 to get data from emebedded reg


 -- * done and start had to be delay one cycle to align with this output register.
	process(USER_CLK)
	begin
		if rising_edge(USER_CLK) then
			if start_r4 = '1' and tx_last_r3 = '0' then
				doa_r <= doa;
				tx_charisk_r <= '0';
			else
				doa_r <= x"BC";
				tx_charisk_r <= '1';
			end if;
		end if;
	end process;

	process(USER_CLK)
	begin
		if rising_edge(USER_CLK) then
		
			if SYSTEM_RESET = '1' then
				--doa_r2 <= (others => '0');
				--tx_charisk_r2 <= '0';
		
				tx_data <= (others => '0');
				tx_charisk <= '0';			
			else
				--doa_r2 <= tx_data_r;
				--tx_charisk_r2 <= TX_CHARISK_r;
		
				tx_data <= doa_r;
				tx_charisk <= TX_CHARISK_r;
			end if;
		end if;
	end process;

end RTL;

