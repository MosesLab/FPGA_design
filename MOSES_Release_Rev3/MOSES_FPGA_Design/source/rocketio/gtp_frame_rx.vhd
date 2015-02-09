-- MF register bramdatar to ease timing

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity gtp_frame_rx is
generic
(
    c_comma_char     : std_logic_vector(7 downto 0) := x"bc";
	c_start_char	:  std_logic_vector(7 downto 0) := x"ff"
);
port
(
    -- GTP User Interface
    RX_DATA                  : in  std_logic_vector(7 downto 0); 
    RX_ENMCOMMA_ALIGN        : out std_logic;
    RX_ENPCOMMA_ALIGN        : out std_logic;
    RX_ENCHAN_SYNC           : out std_logic; 

    -- Control Interface, not used
    INC_IN                   : in std_logic;   -- MF: mapped to 0
    INC_OUT                  : out std_logic; 
    PATTERN_MATCH_N          : out std_logic;
    RESET_ON_ERROR           : in std_logic; 
    ERROR_COUNT              : out std_logic_vector(7 downto 0);

    -- System Interface
    USER_CLK                 : in std_logic;       
    SYSTEM_RESET             : in std_logic;
	
	-- local bus interface
	lb_a				: in std_logic_vector(5 downto 2);
	lb_di				: in std_logic_vector(31 downto 0);
	lb_do				: out  std_logic_vector(31 downto 0);
	lb_we				: in std_logic_vector(3 downto 0); 
	lb_en				: in std_logic; 
	lb_clk				: in std_logic;  
	
	lb_rx_ok			: in std_logic;
	lb_sz				: out std_logic_vector(7 downto 0);
	lb_done				: out std_logic	
  
);
end gtp_frame_rx;

architecture RTL of gtp_frame_rx is

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

	signal start_detected				: std_logic;
	signal comma_detected 				: std_logic;  
	
	signal start_detected_c				: std_logic;
	signal comma_detected_c 				: std_logic; 
	signal valid_data				: std_logic;

--	signal  tied_to_ground_i            :   std_logic;
--	signal  tied_to_ground_vec_i        :   std_logic_vector(31 downto 0);
--	signal  tied_to_vcc_i               :   std_logic;

	type gtp_rx_state is (IDLE, RX_START, RX_TRACK, RX_DONE);
	signal state : gtp_rx_state;
	signal next_state : gtp_rx_state;

	signal lb_rx_ok_r :   std_logic;
	signal lb_rx_ok_r2 :   std_logic;

	signal done :   std_logic;
	signal done_r :   std_logic;
	--signal done_r2 :   std_logic;

	signal wr_cnt    :   unsigned(6 downto 0);  
	signal wr_cnt_r    :   unsigned(6 downto 0);  
	--signal wr_cnt_r2   :   unsigned(8 downto 0);  

--	signal doa_float : std_logic_vector(7 downto 0);
--	signal dob_float : std_logic_vector(7 downto 0);

	signal rx_data_r : std_logic_vector(7 downto 0);
	signal rx_data_r2 : std_logic_vector(7 downto 0);
begin
    -- Static signal Assigments

    -- tied_to_ground_i        <= '0';
    -- tied_to_ground_vec_i    <= (others=>'0');
    -- tied_to_vcc_i           <= '1';
	
	-- register inputs from GTP to help with timing
	process(user_clk)
	begin
		if rising_edge(user_clk) then	
			if( SYSTEM_RESET = '1') then
				rx_data_r <= (others => '0');
				rx_data_r2 <= (others => '0');
			else
				rx_data_r <= rx_data;
				rx_data_r2 <= rx_data_r;
			end if;
		end if;
	end process;
	
	-- clock domain crosssing
	
	process(user_clk)
	begin
		if rising_edge(user_clk) then
			lb_rx_ok_r <= lb_rx_ok;
			lb_rx_ok_r2 <= lb_rx_ok_r;
		end if;
	end process;

	process(lb_clk)
	begin
		if rising_edge(lb_clk) then
		if( SYSTEM_RESET = '1') then
			done_r <= '0';
			lb_done <= '0';
			
			wr_cnt_r <= (others =>'0');
			lb_sz <=(others =>'0') ;	
		else
			done_r <= done;
			lb_done <= done_r;
			
			wr_cnt_r <= wr_cnt;
			lb_sz(6 downto 0) <= std_logic_vector( wr_cnt_r );
			lb_sz(7) <= '0';
		end if;
		end if;
	end process;

	-- State machine, register
	
	p_statereg : process(USER_CLK)
	begin
		if rising_edge(USER_CLK) then
			if(RESET_ON_ERROR ='1' or SYSTEM_RESET = '1') then
				state <= IDLE;
			else
				state <= next_state;
			end if;
		end if;
	end process;

	-- State machine, next state
	
	p_next_state : process(
								state,
								comma_detected,
								start_detected,
								wr_cnt,
								lb_rx_ok_r2
							)
	begin
		case state is 			
			
			when IDLE =>
				if (comma_detected = '0') or (lb_rx_ok_r2 = '0') then
					next_state <= IDLE;
				else
					next_state <= RX_START;
				end if;

			when RX_START =>
				if (start_detected = '1') then
					next_state <= RX_TRACK;
				else
					next_state <= RX_START;
				end if;
				
			when RX_TRACK =>
				if (comma_detected = '1') or (wr_cnt(6) = '1' ) then
					next_state <= RX_DONE;
				else
					next_state <= RX_TRACK;
				end if;
			
			when RX_DONE =>
				if lb_rx_ok_r2 = '1' then
					next_state <= RX_DONE;
				else
					next_state <= IDLE;
				end if;
				
		end case;
	end process;
	
	comma_detected_c 	<=   '1' when ( rx_data_r = c_comma_char ) else '0';
	start_detected_c 	<=   '1' when ( rx_data_r = c_start_char ) else '0';
			
	-- state machine inputs
	process( user_clk)
	begin
		if rising_edge(user_clk) then
			comma_detected 	<=   comma_detected_c;
			start_detected 	<=   start_detected_c;
		end if;
	end process;
	
	
	-- state machine outputs
	valid_data      <= '1' when (state = RX_START and start_detected = '1') or
											(state = RX_TRACK and comma_detected = '0') else '0' after DLY;
	done			<= '1' when (state = RX_DONE) else '0' after DLY;
    INC_OUT			<=  comma_detected;   
    PATTERN_MATCH_N	<=  '0';   
	ERROR_COUNT		<= (others => '0');

    -- Drive the enamcommaalign port of the mgt for alignment
    process( USER_CLK )
    begin
    if(USER_CLK'event and USER_CLK = '1') then
        if(SYSTEM_RESET = '1') then 
            RX_ENMCOMMA_ALIGN   <= '0' after DLY;
        else              
            RX_ENMCOMMA_ALIGN   <= '1' after DLY;
        end if;
    end if;    
    end process;

    -- Drive the enapcommaalign port of the mgt for alignment
    process( USER_CLK )
    begin
    if(USER_CLK'event and USER_CLK = '1') then
        if(SYSTEM_RESET = '1') then  
            RX_ENPCOMMA_ALIGN   <= '0' after DLY;
        else              
            RX_ENPCOMMA_ALIGN   <= '1' after DLY;
        end if;
    end if;    
    end process;

    -- Drive the enchansync port of the mgt for channel bonding
    process( USER_CLK )
    begin
    if(USER_CLK'event and USER_CLK = '1') then
        if(SYSTEM_RESET = '1') then 
            RX_ENCHAN_SYNC   <= '0' after DLY;
        else              
            RX_ENCHAN_SYNC   <= '1' after DLY;
        end if;
    end if;    
    end process;

    -- Counter to write to BRAM

    process( USER_CLK )
    begin
    if(USER_CLK'event and USER_CLK = '1') then
        if( state = IDLE )  then
            wr_cnt   <=  (others => '0') after DLY;
        else 
			if (valid_data = '1') then
				wr_cnt  <=  wr_cnt + 1 after DLY;
			end if;
        end if;
    end if;
    end process;

    -- BRAM Instantiation

	-- can only address 2^6 = 64 locations from the lb side,
    --dual_port_block_ram_i  :  RAMB16_S36_S36 
	u_dp : dpa64x8_b16x32
    port map 
    (
        ADDRA           	=>  std_logic_vector(wr_cnt(5 downto 0)),
        DInA			  	=>  rx_data_r2,
        DOutA              	=>  open,
        WEA(0)              =>  valid_data,
        ENA              	=>  valid_data,
        CLKA             	=>  USER_CLK,
                  
        ADDRB 				=>  lb_a,
        DInB     			=> 	lb_di,
        DOutB     			=>  lb_do,  
        WEB             	=>  lb_we,
        ENB              	=>  lb_en,
        CLKB             	=>  lb_clk       
    );       
    
end RTL;           

