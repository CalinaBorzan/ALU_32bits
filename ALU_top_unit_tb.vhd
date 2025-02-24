library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ALU_top_unit_tb is
end ALU_top_unit_tb;

architecture Behavioral of ALU_top_unit_tb is
    component ALU_top_unit is
        Port (
            clk              : in std_logic;
            reset            : in std_logic;
            addr1            : in std_logic_vector(3 downto 0);
            addr2            : in std_logic_vector(3 downto 0);
            op_select        : in std_logic_vector(3 downto 0);
            CIN              : in std_logic;
            start            : in std_logic;   
            overflow_flag    : out std_logic;
            carry_out_flag   : out std_logic;
            div_by_zero_flag : out std_logic;
            load_acc         : in std_logic;
            quotient_fin     : out std_logic_vector(31 downto 0);
            result           : out std_logic_vector(31 downto 0);
            
            debug_operand1          : out std_logic_vector(31 downto 0);
            debug_operand2          : out std_logic_vector(31 downto 0);
            debug_temp_result       : out std_logic_vector(31 downto 0);
            debug_temp_carry_out    : out std_logic;
            debug_temp_overflow     : out std_logic;
                    div_remainder_debug     : out std_logic_vector(31 downto 0)  

        );
    end component;

    -- Signal Declarations
    signal clk              : std_logic := '0';
    signal reset            : std_logic := '1';
    signal addr1            : std_logic_vector(3 downto 0) := (others => '0');
    signal addr2            : std_logic_vector(3 downto 0) := (others => '0');
    signal op_select        : std_logic_vector(3 downto 0) := (others => '0');
    signal CIN              : std_logic := '0';
    signal load_acc         : std_logic := '0';
    signal start            : std_logic := '0';  
    signal result           : std_logic_vector(31 downto 0);
    signal overflow_flag    : std_logic;
    signal carry_out_flag   : std_logic;
    signal div_by_zero_flag : std_logic;
    signal quotient_fin     : std_logic_vector(31 downto 0);
    
    signal debug_operand1, div_remainder_debug           : std_logic_vector(31 downto 0);
    signal debug_operand2          : std_logic_vector(31 downto 0);
    signal debug_temp_result       : std_logic_vector(31 downto 0);
    signal debug_temp_carry_out    : std_logic;
    signal debug_temp_overflow     : std_logic;

    constant clk_period : time := 0.05 ns;

begin
    uut: ALU_top_unit
        Port map (
            clk              => clk,
            reset            => reset,
            addr1            => addr1,
            addr2            => addr2,
            op_select        => op_select,
            CIN              => CIN,
            start            => start,  
            overflow_flag    => overflow_flag,
            carry_out_flag   => carry_out_flag,
            div_by_zero_flag => div_by_zero_flag,
            load_acc         => load_acc,
            result           => result,
            quotient_fin     => quotient_fin,
            
            debug_operand1          => debug_operand1,
            debug_operand2          => debug_operand2,
            debug_temp_result       => debug_temp_result,
            debug_temp_carry_out    => debug_temp_carry_out,
            debug_temp_overflow     => debug_temp_overflow,
                    div_remainder_debug  =>  div_remainder_debug 

        );

    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;



    stimulus_process : process
    begin
        reset <= '1';
        wait for 1 ns;
        reset <= '0';
        wait for 1 ns;
        
      load_acc<='1';
        -- ADD1
        addr2 <= "1100"; 
        addr1 <= "1000"; 
        op_select <= "0010"; -- Addition
        start <= '1';  
        wait for 1 ns;
        start <= '0';  
         wait for 5 ns;
       
        -- Add
        addr2 <= "0110"; 
        op_select <= "0010";  -- Addition
        start <= '1'; 
        wait for 1 ns;
        start <= '0';  
        wait for 5 ns;
        
      -- Add operand 2 negative
        addr2 <= "0011"; 
        op_select <= "0010";  -- Addition
        start <= '1';  
        wait for 1 ns;
        start <= '0';  
        wait for 5 ns;
        
             
     -- Add both operand negative
        addr2 <= "1111"; 
        op_select <= "0010";  -- Addition
        start <= '1';  
        wait for 1 ns;
        start <= '0';  
        wait for 5 ns;
        
           -- Sub both negative
        addr2 <= "0011"; 
        op_select <= "0011";  -- Subtraction
        start <= '1';  
        wait for 1 ns;
        start <= '0';  
        wait for 5 ns;
        
              -- Sub both positive
        addr2 <= "0110"; 
        op_select <= "0011";  -- Subtraction
        start <= '1';  
        wait for 1 ns;
        start <= '0';  
        wait for 5 ns;
        
              
       -- Sub one positive one negative
        addr2 <= "1111"; 
        op_select <= "0011";  -- Subtraction
        start <= '1'; 
        wait for 1 ns;
        start <= '0';  
        wait for 5 ns;
        
        --AND
        addr2 <= "1010"; 
        op_select <= "1001";  -- AND
        start <= '1'; 
        wait for 1 ns;
        start <= '0';  
        wait for 5 ns;
        
         --OR
        addr2 <= "1000"; 
        op_select <= "1010";  -- OR
        start <= '1'; 
        wait for 1 ns;
        start <= '0'; 
        wait for 5 ns;
        
              --OR negative
        addr2 <= "1001"; 
        op_select <= "1010";  -- OR
        start <= '1';  
        wait for 1 ns;
        start <= '0'; 
        wait for 5 ns;

              --NOT negative
  
        op_select <= "1011";  -- NOT
        start <= '1'; 
        wait for 1 ns;
        start <= '0';  
        wait for 5 ns;
        
        op_select <= "1100";  -- NOT
        start <= '1'; 
        wait for 1 ns;
        start <= '0';  
        wait for 5 ns;
        
        op_select <= "1101";  -- DEC
        start <= '1'; 
        wait for 1 ns;
        start <= '0'; 
        wait for 5 ns;
        
        
        op_select <= "1111";  -- NEG
        start <= '1'; 
        wait for 1 ns;
        start <= '0';  
        wait for 5 ns;
     
        op_select <= "1100";  -- INC
        start <= '1';  
        wait for 1 ns;
        start <= '0';  
        wait for 5 ns;
        
        op_select <= "1101";  -- DEC
        start <= '1';  
        wait for 1 ns;
        start <= '0';  
        wait for 5 ns;
     
     
        op_select <= "0110";  --ROT RIGHT
        start <= '1';  
        wait for 1 ns;
        start <= '0';  
        wait for 5 ns;
        
        
        op_select <= "0111";  --ROT LEFT
        start <= '1'; 
        wait for 2 ns;
        start <= '0';  
        wait for 5 ns;
        
        addr2 <= "0001"; 
        op_select <= "0101";  -- DIv
        start <= '1';  
        wait for 2 ns;
        start <= '0'; 
        wait for 220 ns;
        

        op_select <= "0101";  -- Div
        start <= '1'; 
        wait for 2 ns;
        start <= '0'; 
        wait for 220 ns;
        
--            addr2 <= "1010"; 
        op_select <= "0101";  -- DIV
        start <= '1';  
        wait for 2 ns;
        start <= '0';  
        wait for 220 ns;
        
          reset <= '1';
        wait for 1 ns;
        reset <= '0';
        wait for 1 ns;
        
      load_acc<='1';
      
         addr2 <= "0110"; 
        op_select <= "0010";  -- Addition
        start <= '1';  
        wait for 1 ns;
        start <= '0';  
        wait for 3 ns;
        
        addr2 <= "1010"; 
        op_select <= "0100";  -- MUL
        start <= '1';  
        wait for 2 ns;
        start <= '0';  
        wait for 220 ns;
        
         addr2 <= "0110"; 
        op_select <= "0100";  -- MUL
        start <= '1';
        wait for 2 ns;
        start <= '0';  
        wait for 220 ns;
        
        
                
          reset <= '1';
        wait for 1 ns;
        reset <= '0';
        wait for 1 ns;
        
      load_acc<='1';
      
      
             addr2 <= "0110"; 
        op_select <= "0010";  
        start <= '1';  
        wait for 1 ns;
        start <= '0'; 
        wait for 3 ns;
        
             addr2 <= "0000"; 
        op_select <= "0010"; 
        start <= '1';
        wait for 1 ns;
        start <= '0';  
        wait for 3 ns;
        
  
----                    addr2 <= "1010"; 
--        op_select <= "0101";  -- Multiplication
--        start <= '1';  -- Simulate pressing the start button
--        wait for 2 ns;
--        start <= '0';  -- Release the button
--        wait for 800 ns;
--                 -- Division (Here we use start)
--        addr2 <= "1010"; 
--        op_select <= "0100";  -- Multiplication
--        start <= '1';  -- Simulate pressing the start button
--        wait for 2 ns;
--        start <= '0';  -- Release the button
--        wait for 220 ns;
        
--                      -- Multiply (Here we use start)
--        addr2 <= "1010"; 
--        op_select <= "0101";  -- Multiplication
--        start <= '1';  -- Simulate pressing the start button
--        wait for 2 ns;
--        start <= '0';  -- Release the button
--        wait for 220 ns;
        
--             addr2 <= "1010"; 
--        op_select <= "0101";  -- Multiplication
--        start <= '1';  -- Simulate pressing the start button
--        wait for 2 ns;
--        start <= '0';  -- Release the button
--        wait for 320 ns;
        
--                         -- Multiply (Here we use start)
----        addr2 <= "1010"; 
--        op_select <= "0101";  -- Multiplication
--        start <= '1';  -- Simulate pressing the start button
--        wait for 2 ns;
--        start <= '0';  -- Release the button
--        wait for 10 ns;
        
--        -- Divide (optional start if desired)
--        addr1 <= "0010"; 
--        addr2 <= "0011"; 
--        op_select <= "0101"; -- Division
--        start <= '1';  -- Simulate pressing the start button
--        wait for 3 ns;
--        start <= '0';  -- Release the button
--        wait for 370 ns;

--        reset <= '1';
--        wait for 1 ns;
--        reset <= '0';
--        wait for 1 ns;

--        -- Subtract
--        addr1 <= "0010"; 
--        addr2 <= "0011"; 
--        op_select <= "0011";
--        wait for 5 ns; 
--        start <= '1';  -- Simulate pressing the start button
--        wait for 5 ns;
--        start <= '0';  -- Release the button
--        wait for 10 ns;
       
----        -- Add with overflow
----        addr1 <= "1111"; 
----        addr2 <= "1110"; 
----        op_select <= "0010";
----        wait for 5 ns; 
----        start <= '1';  -- Simulate pressing the start button
----        wait for 5 ns;
----        start <= '0';  -- Release the button 
----        wait for 10 ns; 
       
       
----        reset <= '1';
----        wait for 1 ns;
----        reset <= '0';
----        wait for 1 ns;
        
--        -- Add
--        addr1 <= "0010"; 
--        addr2 <= "0011"; 
--        op_select <= "0010";
--        load_acc <= '1';
--        wait for 5 ns; 
--        start <= '1';  -- Simulate pressing the start button
--        wait for 5 ns;
--        start <= '0';  -- Release the button
--        wait for 10 ns;

--        -- Logical AND
--        addr1 <= "0010";
--        addr2 <= "0011"; 
--        op_select <= "1001"; -- Logical AND
--        wait for 5 ns; 
--        start <= '1';  -- Simulate pressing the start button
--        wait for 5 ns;
--        start <= '0';  -- Release the button
--        wait for 10 ns; 

--        -- Logical OR
--        addr1 <= "0010";
--        addr2 <= "0011";
--        op_select <= "1010"; -- Logical OR
--        wait for 5 ns; 
--        start <= '1';  -- Simulate pressing the start button
--        wait for 5 ns;
--        start <= '0';  -- Release the button
--        wait for 10 ns; 

--        -- Logical NOT
--        addr1 <= "0010"; 
--        addr2 <= "0011"; 
--        op_select <= "1011"; -- Logical NOT
--        wait for 5 ns; 
--        start <= '1';  -- Simulate pressing the start button
--        wait for 5 ns;
--        start <= '0';  -- Release the button 
--        wait for 10 ns;

--        -- Increment
--        addr1 <= "0010"; 
--        op_select <= "1100"; -- Increment
--        wait for 5 ns; 
--        start <= '1';  -- Simulate pressing the start button
--        wait for 5 ns;
--        start <= '0';  -- Release the button
--        wait for 10 ns; 

--        -- Decrement
--        addr1 <= "0010"; 
--        op_select <= "1101"; -- Decrement
--        wait for 5 ns; 
--        start <= '1';  -- Simulate pressing the start button
--        wait for 5 ns;
--        start <= '0';  -- Release the button
--        wait for 10 ns;

--        -- Negation
--        addr1 <= "0010";
--        op_select <= "1111"; -- Negation
--        wait for 5 ns; 
--        start <= '1';  -- Simulate pressing the start button
--        wait for 5 ns;
--        start <= '0';  -- Release the button 
--        wait for 10 ns;

--        addr1 <= "0010"; 
--        addr2 <= "0011"; 
--        op_select <= "0011";
--        wait for 5 ns; 
--        start <= '1';  -- Simulate pressing the start button
--        wait for 5 ns;
--        start <= '0';  -- Release the button
--        wait for 10 ns;
        
--        -- Rotate left
--        addr1 <= "0010";
--        op_select <= "0111"; -- Rotate left
--        wait for 5 ns; 
--        start <= '1';  -- Simulate pressing the start button
--        wait for 5 ns;
--        start <= '0';  -- Release the button
--        wait for 10 ns; 

--        -- Rotate right
--        addr1 <= "0010"; 
--        op_select <= "0110"; 
--        wait for 5 ns; 
--        start <= '1';  -- Simulate pressing the start button
--        wait for 5 ns;
--        start <= '0';  -- Release the button
--        wait for 10 ns;
  
--        -- Divide (optional start if desired)
--        addr1 <= "0010"; 
--        addr2 <= "0100"; 
--        op_select <= "0101"; -- Division
--        start <= '1';  -- Simulate pressing the start button
--        wait for 3 ns;
--        start <= '0';  -- Release the button
--        wait for 370 ns;
      
--         -- Multiply (Here we use start)
--        addr1 <= "0001";
--        addr2 <= "0010"; 
--        op_select <= "0100";  -- Multiplication
--        start <= '1';  -- Simulate pressing the start button
--        wait for 2 ns;
--        start <= '0';  -- Release the button
--        wait for 370 ns;
        
               
--        addr1 <= "0010"; 
--        addr2 <= "0011"; 
--        op_select <= "0010";
--        wait for 5 ns; 
--        start <= '1';  -- Simulate pressing the start button
--        wait for 5 ns;
--        start <= '0';  -- Release the button
--        wait for 10 ns;
        
 

     
            wait for 100 ns; 

        wait;
    end process;

end Behavioral;
