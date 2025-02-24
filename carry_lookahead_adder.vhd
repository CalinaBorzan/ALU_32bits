library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity carry_lookahead_adder is
    Port ( 
        A: in std_logic_vector(3 downto 0);  
        B: in std_logic_vector(3 downto 0); 
        CIN: in std_logic;                   
        COUT: out std_logic;                 
        S: out std_logic_vector(3 downto 0) 
    );
end carry_lookahead_adder;

architecture Behavioral of carry_lookahead_adder is
    component full_adder is
        Port ( 
            a: in std_logic;
            b: in std_logic;                   
            cin: in std_logic;                 
            cout: out std_logic;               
            s: out std_logic                    
        );
    end component full_adder;

    component carry_block is
        Port ( 
            a: in std_logic_vector(3 downto 0);  
            b: in std_logic_vector(3 downto 0);  
            cin: in std_logic;                       
            cout: out std_logic_vector(3 downto 0)                    
        );
    end component carry_block;

    signal C_internal: std_logic_vector(3 downto 0); 
    signal C0: std_logic; 

begin
     C0 <= CIN; 

    carry_block_inst: carry_block 
        port map(a => A, b => B, cin => C0, cout => C_internal); 

    full_adder0: full_adder port map(a => A(0), b => B(0), cin => C0, cout => open, s => S(0));
    full_adder1: full_adder port map(a => A(1), b => B(1), cin => C_internal(0), cout => open, s => S(1));
    full_adder2: full_adder port map(a => A(2), b => B(2), cin => C_internal(1), cout => open, s => S(2));
    full_adder3: full_adder port map(a => A(3), b => B(3), cin => C_internal(2), cout => open, s => S(3));
    COUT<=C_internal(3);
end Behavioral;
