library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity logical_op is
    Port (
        operand1 : in  std_logic_vector(31 downto 0); 
        operand2 : in  std_logic_vector(31 downto 0);  
        sel      : in  std_logic_vector(2 downto 0);  
        start    : in  std_logic;                 
        ready    : out std_logic;                 
        result   : out std_logic_vector(31 downto 0);
        clk      : in  std_logic
    );
end logical_op;
architecture Behavioral of logical_op is

    type state_type is (Idle, Execute, Finish);
    signal state : state_type := Idle;

    signal incremented, decremented, negate_result : std_logic_vector(31 downto 0);
    signal and_result, or_result, not_result       : std_logic_vector(31 downto 0);
    signal carry_out_add                           : std_logic;

    component carry_lookahead_adder_32bit
        Port (
            A     : in  std_logic_vector(31 downto 0);
            B     : in  std_logic_vector(31 downto 0);
            OP    : in  std_logic;                
            CIN   : in  std_logic;                
            COUT  : out std_logic;               
            S     : out std_logic_vector(31 downto 0)
        );
    end component;

begin

    increment_nr : carry_lookahead_adder_32bit
        port map (
            A     => operand1,
            B     => (others => '0'),       
            OP    => '0',                   
            CIN   => '1',                   
            COUT  => open,                  
            S     => incremented
        );

    decrement_nr : carry_lookahead_adder_32bit
        port map (
            A     => operand1,
            B     => (others => '1'),        
            OP    => '0',                   
            CIN   => '0',                 
            COUT  => open,                 
            S     => decremented
        );

    negate_nr : carry_lookahead_adder_32bit
        port map (
            A     => not_result,         
            B     => (others => '0'),        
            OP    => '0',                   
            CIN   => '1',                   
            COUT  => carry_out_add,         
            S     => negate_result
        );

    not_result <= not operand1;

    and_result <= operand1 and operand2;
    or_result  <= operand1 or operand2;

    process(clk)
    begin
        if rising_edge(clk) then
            case state is
                when Idle =>
                    if start = '1' then
                        state <= Execute;
                        ready <= '0';
                    else
                        ready <= '0';
                    end if;

                when Execute =>
                    
                    state <= Finish;

                when Finish =>
                    case sel is 
                        when "001" =>  -- AND operation
                            result <= and_result;
                        when "010" =>  -- OR operation
                            result <= or_result;
                        when "011" =>  -- NOT operation
                            result <= not_result;
                        when "100" =>  -- Increment
                            result <= incremented;
                        when "101" =>  -- Decrement
                            result <= decremented;
                        when "111" =>  -- Negation
                            result <= negate_result;
                        when others =>  
                            result <= (others => '0');
                    end case;
                    ready <= '1';  
                    state <= Idle;

                when others =>
                    state <= Idle;
            end case;
        end if;
    end process;

end Behavioral;

