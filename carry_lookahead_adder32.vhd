library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 

entity carry_lookahead_adder_32bit is
    Port ( 
        A: in std_logic_vector(31 downto 0);  
        B: in std_logic_vector(31 downto 0); 
        OP: in std_logic;                      
        CIN: in std_logic;                    
        COUT: out std_logic;                 
        S: out std_logic_vector(31 downto 0); 
        overflow_flag: out std_logic               
    );
end carry_lookahead_adder_32bit;

architecture Behavioral of carry_lookahead_adder_32bit is
    component carry_lookahead_adder is
        Port ( 
            A: in std_logic_vector(3 downto 0);  
            B: in std_logic_vector(3 downto 0); 
            CIN: in std_logic;                    
            COUT: out std_logic;                 
            S: out std_logic_vector(3 downto 0)   
        );
    end component;

    signal S_internal: std_logic_vector(31 downto 0); 
    signal C_internal: std_logic_vector(7 downto 0); 
    signal B_modified: std_logic_vector(31 downto 0); 
    signal CIN_temp: std_logic_vector(8 downto 0); 

begin
    process(B, OP)
    begin
        if OP = '1' then
            B_modified <= (not B) + "00000000000000000000000000000001";  
        else
            B_modified <= B;
        end if;
    end process;

    CIN_temp(0) <= CIN;  
    

    gen_adder: for i in 0 to 7 generate
        carry_lookahead_adder_inst: carry_lookahead_adder 
            port map(
                A => A(4*i+3 downto 4*i), 
                B => B_modified(4*i+3 downto 4*i), 
                CIN => CIN_temp(i),  
                COUT => CIN_temp(i+1), 
                S => S_internal(4*i+3 downto 4*i)
            );
    end generate;

    S <= S_internal;
    COUT <= CIN_temp(8); 
    overflow_flag <= CIN_temp(8) xor CIN_temp(7);


end Behavioral;
