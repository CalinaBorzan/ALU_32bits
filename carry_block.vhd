library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity carry_block is
   
    Port ( 
        a: in std_logic_vector(3 downto 0); 
        b: in std_logic_vector(3 downto 0);  
        cin: in std_logic;                      
        cout: out std_logic_vector(3 downto 0)                    
    );
end carry_block;

architecture Behavioral of carry_block is
    signal p, g: std_logic_vector(3 downto 0); 
    signal cout_aux: std_logic_vector(3 downto 0);
   begin
    g <= a and b;                   
    p <= a or b;                  
    cout_aux(0) <= g(0) or (p(0) and cin);  
    cout_aux(1) <= g(1) or (p(1) and cout_aux(0));
    cout_aux(2) <= g(2) or (p(2) and cout_aux(1));
    cout_aux(3) <= g(3) or (p(3) and cout_aux(2));
    cout <= cout_aux;      
end Behavioral;
