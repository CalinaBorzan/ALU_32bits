

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity full_adder is
Port ( 
  a:in std_logic;
  b:in std_logic;
  cin:in std_logic;
  cout:out std_logic;
  s:out std_logic
);
end full_adder;

architecture Behavioral of full_adder is

begin

    s <= a xor b xor cin;
    cout <= (a and b) or ((a or b) and cin);
 
end Behavioral;
