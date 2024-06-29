# 4-Digit-Counter-on-7-segment-Display

This project implements a simple four-digit counter on a 7-segment display using VHDL. The counter increments by pressing a button. The target hardware is the Basys 3 FPGA board (Artix-7, Xilinx).

## VHDL Code Overview

The processes in this code synchronizes the button input to the clock domain and debounces it to produce a stable signal. Moreover, a button press detection process detects the falling edge of the debounced button signal to increment the counter. A state machine is also built to manage the 7 segment display counter.


### Entity Declaration
```
library IEEE;
use IEEE.std_logic_1164.all;

entity SevenSegmentDisplay is
    port (
        reset       : in std_logic;
        clk         : in std_logic;
        btnC        : in std_logic;
        segments    : out std_logic_vector(6 downto 0);   -- Segments a - g
        dp          : out std_logic := '1';               -- Decimal point
        anode       : out std_logic_vector(3 downto 0)    -- Anodes for 4 digits
    );
end entity;
```

This entity declaration defines the input and output ports for the module. The inputs include reset, clk (clock), and btnC (button). The outputs are segments (to control the 7-segment display), dp (decimal point), and anode (to select the digit to display).

Following the entity are button specific processes. These processes handle button synchronization and debouncing. _buttonSync_ synchronizes the button input to the clock domain. _buttonDebounce_ debounces the synchronized button input, and _detectButton_ detects a falling edge of the debounced signal, indicating a valid button press.

### Counter Logic

The process _countButtonPresses_ increments the counter each time the button is pressed. The counter is represented by four digits (firstDigit, secondDigit, thirdDigit, fourthDigit). Each digit increments from 0 to 9, and the next digit increments when the current digit rolls over from 9 to 0.

### 7-Segment Display Decoder
```
SSdecoder : process(clk, reset)
begin
    if reset = '1' then
        segments_int <= "0000000";
    elsif rising_edge(clk) then
        case Number is
            when 0 => segments_int <= "0111111";
            when 1 => segments_int <= "0000110";
            when 2 => segments_int <= "1011011";
            when 3 => segments_int <= "1001111";
            when 4 => segments_int <= "1100110";
            when 5 => segments_int <= "1101101";
            when 6 => segments_int <= "1111001";
            when 7 => segments_int <= "0000111";
            when 8 => segments_int <= "1111111";
            when 9 => segments_int <= "1100111";
            when others => segments_int <= "0000000";
        end case;
    end if;
end process;
```

This process decodes the current digit (Number) to the appropriate 7-segment display pattern. The output _segments_int_ controls the segments a to g of the 7-segment display.

### State Machine for Display Control

This state machine controls which digit is currently being displayed on the 7-segment display. It cycles through the four digits (digit1, digit2, digit3, digit4) and sets the anode signal to select the active digit. The _waitCounter_ ensures that each digit is displayed long enough to be visible.

## Acknowledgments 

- Xilinx for providing the Vivado Design Suite.
- Digilent for the Basys 3 board.
- L Athukorala from Udemy for code idea
