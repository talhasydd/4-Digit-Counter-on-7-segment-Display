library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;  -- Import for integer operations

entity SevenSegmentDisplay is
    port (
        reset       : in std_logic;
        clk         : in std_logic;
        btnC        : in std_logic;
        segments    : out std_logic_vector(6 downto 0);  		-- segments a - g
        dp          : out std_logic := '1';  					-- decimal point
        anode       : out std_logic_vector(3 downto 0)
    );
end entity;

architecture RTL of SevenSegmentDisplay is
    type states is (digit1, digit2, digit3, digit4);

    constant debouncePeriod : integer := 2500000;
    signal debounceCounter  : integer := 0;  
    signal sync             : std_logic_vector(1 downto 0) := "00";  
    signal syncedButton     : std_logic;
    signal debouncedButton  : std_logic := '0';  
    signal button_prev      : std_logic := '0';  
    signal finalButton      : std_logic := '0';    

    signal segments_int     : std_logic_vector(6 downto 0) := "0000000";    
    signal state            : states := digit1;  --  
    signal Number           : integer := 0;  --    
    signal firstDigit, secondDigit, thirdDigit, fourthDigit : integer := 0;   
    signal waitCounter      : integer := 0;    

begin
    segments <= segments_int;
    syncedButton <= sync(1);

    -- Button synchronization process
    buttonSync: process(clk, reset)
    begin
        if reset = '1' then
		
            sync <= "00";
			
        elsif rising_edge(clk) then  
		
            sync(0) <= btnC;
            sync(1) <= sync(0);
			
        end if;
    end process;

    -- Button detection process
    detectButton: process(clk, reset)
    begin
        if reset = '1' then
		
            button_prev <= '1'; 
            finalButton <= '0';
			
        elsif rising_edge(clk) then  
		
            button_prev <= debouncedButton;
			
            if debouncedButton = '0' and button_prev = '1' then  
                finalButton <= '1';
            else
                finalButton <= '0';
            end if;
        end if;
    end process;

    -- Button debounce process
    buttonDebounce: process(clk, reset)
    begin
        if reset = '1' then
		
            debounceCounter <= 0;
            debouncedButton <= '0';
			
        elsif rising_edge(clk) then  
		
            if syncedButton = '1' then
                if debounceCounter < debouncePeriod then  
				
                    debounceCounter <= debounceCounter + 1;
					
                end if;
            else
                if debounceCounter > 0 then  
				
                    debounceCounter <= debounceCounter - 1;
					
                end if;
            end if;
			
            if debounceCounter = debouncePeriod then
			
                debouncedButton <= '1';
				
            elsif debounceCounter = 0 then
			
                debouncedButton <= '0';
				
            end if;
        end if;
    end process;

    -- Button press count process
    countButtonPresses: process(clk, reset)
    begin
        if reset = '1' then
		
            firstDigit <= 0;
            secondDigit <= 0;
            thirdDigit <= 0;
            fourthDigit <= 0;
			
        elsif rising_edge(clk) then  
		
            if finalButton = '1' then
			
                if firstDigit < 9 then
                    firstDigit <= firstDigit + 1;
                else
                    firstDigit <= 0;
					
                    if secondDigit < 9 then
                        secondDigit <= secondDigit + 1;
                    else
                        secondDigit <= 0;
						
                        if thirdDigit < 9 then
                            thirdDigit <= thirdDigit + 1;
                        else
                            thirdDigit <= 0;
							
                            if fourthDigit < 9 then
                                fourthDigit <= fourthDigit + 1;
                            else
                                fourthDigit <= 9;  
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Seven-segment decoder process
    SSdecoder : process(clk, reset)
    begin
        if reset = '1' then
		
            segments_int <= "0000000";
			
        elsif rising_edge(clk) then  
            case Number is
			
                when 0 => segments_int 		<= "1000000";
                when 1 => segments_int 		<= "1111001";
                when 2 => segments_int 		<= "0100100";
                when 3 => segments_int 		<= "0110000";
                when 4 => segments_int 		<= "0011001";
                when 5 => segments_int 		<= "0010010";
                when 6 => segments_int 		<= "0000010";
                when 7 => segments_int 		<= "1111000";
                when 8 => segments_int 		<= "0000000";
                when 9 => segments_int 		<= "0011000";
                when others => segments_int <= "1111111";
				
            end case;
        end if;
    end process;

    -- State machine process
    statemachine : process(clk, reset)
    begin
        if reset = '1' then
            state <= digit1;
            anode <= "1111";
            waitCounter <= 0;
			
        elsif rising_edge(clk) then 
            case state is
                when digit1 =>
				
                    anode <= "1110";
                    Number <= firstDigit;
                    waitCounter <= waitCounter + 1;
					
                    if waitCounter = 450000 then
                        state <= digit2;
                        waitCounter <= 0;
                    end if;
					
                when digit2 =>
				
                    anode <= "1101";
                    Number <= secondDigit;
                    waitCounter <= waitCounter + 1;
					
                    if waitCounter = 450000 then
                        state <= digit3;
                        waitCounter <= 0;
                    end if;
					
                when digit3 =>
				
                    anode <= "1011";
                    Number <= thirdDigit;
                    waitCounter <= waitCounter + 1;
					
                    if waitCounter = 450000 then
                        state <= digit4;
                        waitCounter <= 0;
                    end if;
					
                when digit4 =>
				
                    anode <= "0111";
                    Number <= fourthDigit;
                    waitCounter <= waitCounter + 1;
					
                    if waitCounter = 450000 then
                        state <= digit1;
                        waitCounter <= 0;
                    end if;
					
                when others =>
                    state <= digit1;
            end case;
        end if;
    end process;
end RTL;
