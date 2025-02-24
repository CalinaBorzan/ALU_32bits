library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_carry_lookahead_adder_32bit is
end tb_carry_lookahead_adder_32bit;

architecture Behavioral of tb_carry_lookahead_adder_32bit is

    component carry_lookahead_adder_32bit is
        Port ( 
            A: in std_logic_vector(31 downto 0);  
            B: in std_logic_vector(31 downto 0); 
            OP: in std_logic;                     
            CIN: in std_logic;                    
            COUT: out std_logic;                  
            S: out std_logic_vector(31 downto 0) 
        );
    end component;

    signal A: std_logic_vector(31 downto 0);
    signal B: std_logic_vector(31 downto 0);
    signal OP: std_logic;                     
    signal CIN: std_logic;                    
    signal COUT: std_logic;                   
    signal S: std_logic_vector(31 downto 0);  

begin

    uut: carry_lookahead_adder_32bit
        port map (
            A => A,
            B => B,
            OP => OP,
            CIN => CIN,
            COUT => COUT,
            S => S
        );

    process
    begin
        -- Test 1: Addition of two numbers
        A <= "00000000000000000000000000000001";  -- 1
        B <= "00000000000000000000000000000001";  -- 1
        OP <= '0';  -- Addition
        CIN <= '0'; 
        wait for 10 ns;  

        -- Test 2: Addition with carry
        A <= "00000000000000000000000000000001";  -- 1
        B <= "00000000000000000000000000000011";  -- 3
        OP <= '0';  -- Addition
        CIN <= '0'; 
        wait for 10 ns;  

        -- Test 3: Subtraction of two numbers
        A <= "00000000000000000000000000000100";  -- 4
        B <= "00000000000000000000000000000001";  -- 1
        OP <= '1';  -- Subtraction
        CIN <= '0'; 
        wait for 10 ns;  

        -- Test 4: Subtraction resulting in negative (two's complement)
        A <= "00000000000000000000000000000001";  -- 1
        B <= "00000000000000000000000000000100";  -- 4
        OP <= '1';  -- Subtraction
        CIN <= '0';
        wait for 10 ns;  

        -- Test 5: Addition with carry input
        A <= "00000000000000000000000000000001";  -- 1
        B <= "00000000000000000000000000000001";  -- 1
        OP <= '0';  -- Addition
        CIN <= '1'; 
        wait for 10 ns;  

        -- Test 6: -5 + 5 (2's complement)
        A <= "11111111111111111111111111111011";  -- -5 (2's complement)
        B <= "00000000000000000000000000000101";  -- 5 (2's complement)
        OP <= '0';  -- Addition
        CIN <= '0'; 
        wait for 10 ns;  

        -- Test 7: 5 + (-5) (2's complement)
        A <= "00000000000000000000000000000101";  -- 5 (2's complement)
        B <= "11111111111111111111111111111011";  -- -5 (2's complement)
        OP <= '0';  
        CIN <= '0'; 
        wait for 10 ns;  
        
      -- Test 8: -3 + (-5) (2's complement)
       A <= "11111111111111111111111111111101";  -- -3 (2's complement)
       B <= "11111111111111111111111111111011";  -- -5 (2's complement)
       OP <= '0';  
       CIN <= '0'; 
       wait for 10 ns;  

     A <= "11111111111111111111111111111101";  -- -3 (2's complement)
     B <= "11111111111111111111111111111011";  -- -5 (2's complement)
     OP <= '1';  -- Subtraction
     CIN <= '0'; 
     wait for 10 ns;  
        wait;
    end process;

end Behavioral;
