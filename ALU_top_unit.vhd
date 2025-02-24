library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU_top_unit is
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
end ALU_top_unit;

architecture Behavioral of ALU_top_unit is
    type state_t is (
        Idle,
        Load_Registers,
        Load_Operands,            
        Operation_Start_Loaded,
        Operation_Start,
        Execute_Operation,
        Wait_For_Done,
        Wait_For_Result,
        Finalize,
        Error_State
    );
    
    signal state : state_t := Idle;
    
    constant ADD_OP        : std_logic_vector(3 downto 0) := "0010";
    constant SUB_OP        : std_logic_vector(3 downto 0) := "0011";
    constant MUL_OP        : std_logic_vector(3 downto 0) := "0100";
    constant DIV_OP        : std_logic_vector(3 downto 0) := "0101";
    constant ROT_RIGHT_OP  : std_logic_vector(3 downto 0) := "0110";
    constant ROT_LEFT_OP   : std_logic_vector(3 downto 0) := "0111";
    
    signal operand1, operand2, operand1_mem, operand2_mem : std_logic_vector(31 downto 0);  
    signal add_result, sub_result                           : std_logic_vector(31 downto 0);
    signal logical_result                                   : std_logic_vector(31 downto 0);  
    signal COUT_add, COUT_sub                               : std_logic;                      
    signal overflow_add, overflow_sub                       : std_logic;
    signal rotate_left_result, rotate_right_result         : std_logic_vector(31 downto 0);
    signal shift_amount                                     : std_logic_vector(4 downto 0) := "00001"; 
    signal multiplier_out                                   : std_logic_vector(63 downto 0);
    signal multiplier_done                                  : std_logic := '0';
    signal remainder                                        : std_logic_vector(31 downto 0);
    signal quotient                                         : std_logic_vector(31 downto 0);
    signal division_done                                    : std_logic := '0';
    signal end_division                                     : std_logic := '0';
    signal division_by_zero                                 : std_logic := '0';
    signal quotient_fin_temp                                : std_logic_vector(31 downto 0);
    signal division_by_zero_temp                            : std_logic := '0';
    
    signal temp_result            : std_logic_vector(31 downto 0) := (others => '0');
    signal temp_carry_out         : std_logic := '0';
    signal temp_overflow          : std_logic := '0';
    
    signal start_multiplication    : std_logic := '0';
    signal start_division          : std_logic := '0';
    signal start_rotation          : std_logic := '0';
    signal start_logical_op        : std_logic := '0';
    
    signal logical_op_ready        : std_logic := '0';
    
    signal start_prev              : std_logic := '0';
    signal start_pulse             : std_logic := '0';
    
    signal operand1_data_in             : std_logic_vector(31 downto 0) := (others => '0');
    signal operand2_data_in        : std_logic_vector(31 downto 0) := (others => '0');
    
    signal internal_load_operand   : std_logic := '0';
    
    signal previous_operation_mul  : std_logic := '0';
    signal previous_operation_div  : std_logic := '0';
    
    
    component memory_unit
        Port (
            addr     : in std_logic_vector(3 downto 0);
            data_out : out std_logic_vector(31 downto 0)
        );
    end component;

    component carry_lookahead_adder_32bit
        Port (
            A             : in std_logic_vector(31 downto 0);
            B             : in std_logic_vector(31 downto 0);
            OP            : in std_logic;
            CIN           : in std_logic;
            COUT          : out std_logic;
            S             : out std_logic_vector(31 downto 0);
            overflow_flag : out std_logic   
        );
    end component;

    component logical_op
        Port (
            operand1 : in std_logic_vector(31 downto 0); 
            operand2 : in std_logic_vector(31 downto 0);  
            sel      : in std_logic_vector(2 downto 0);  
            start    : in std_logic;               
            ready    : out std_logic;              
            result   : out std_logic_vector(31 downto 0);
            clk      : in std_logic
        );
    end component;

    component accumulator_reg
        Port (
            clk      : in std_logic;
            reset    : in std_logic;
            load     : in std_logic;
            data_in  : in std_logic_vector(31 downto 0);
            data_out : out std_logic_vector(31 downto 0)
        );
    end component;
     
    component rotate_register is
        Port (
            clk          : in  std_logic;
            rst          : in  std_logic;
            data_in      : in  std_logic_vector(31 downto 0);
            shift_amount : in  std_logic_vector(4 downto 0);
            direction    : in  std_logic;
            data_out     : out std_logic_vector(31 downto 0)
        );
    end component;
   
    component multiplier is
        Port (
            x              : in std_logic_vector(31 downto 0);
            y              : in std_logic_vector(31 downto 0);
            reset          : in std_logic;
            clk            : in std_logic;
            start          : in std_logic;
            result         : out std_logic_vector(63 downto 0);
            end_operations : out std_logic
        );
    end component;

    component restoring_division is
        Port (
            M                : in std_logic_vector(31 downto 0); 
            Q                : in std_logic_vector(31 downto 0); 
            A                : out std_logic_vector(31 downto 0); 
            Q_out            : out std_logic_vector(31 downto 0);
            start            : in std_logic;
            end_division     : out std_logic;
            division_by_zero : out std_logic;
            clk              : in std_logic;                     
            reset            : in std_logic
        );
    end component;

begin

    memory_nr1 : memory_unit
        Port map (
            addr     => addr1,
            data_out => operand1_mem
        );

    memory_nr2 : memory_unit
        Port map (
            addr     => addr2,
            data_out => operand2_mem
        );

    acc_reg : accumulator_reg
        Port map (
            clk      => clk,
            reset    => reset,
            load     => '1',                   
            data_in  => operand1_data_in,          
            data_out => operand1
        );

    operand2_register : accumulator_reg
        Port map (
            clk      => clk,
            reset    => reset,
            load     => internal_load_operand,  
            data_in  => operand2_data_in,       
            data_out => operand2
        );

    multiplier_instance : multiplier
        Port map (
            x              => operand1,
            y              => operand2,
            clk            => clk,
            reset          => reset,
            start          => start_multiplication, 
            result         => multiplier_out,
            end_operations => multiplier_done
        );

    division_unit : restoring_division
        Port map (
            M                => operand1,
            Q                => operand2,
            A                => remainder,          
            Q_out            => quotient,           
            start            => start_division,     
            end_division     => end_division,
            division_by_zero => division_by_zero,
            clk              => clk,
            reset            => reset
        );

    adder_add : carry_lookahead_adder_32bit
        Port map (
            A             => operand1,
            B             => operand2,
            OP            => '0',                 
            CIN           => CIN,
            COUT          => COUT_add,
            S             => add_result,
            overflow_flag => overflow_add
        );

    adder_sub : carry_lookahead_adder_32bit
        Port map (
            A             => operand1,
            B             => operand2,
            OP            => '1',                 
            CIN           => CIN,
            COUT          => COUT_sub,
            S             => sub_result,
            overflow_flag => overflow_sub
        );

    logical_ops : logical_op
        Port map (
            operand1 => operand1,
            operand2 => operand2,
            sel      => op_select(2 downto 0),
            start    => start_logical_op,       
            ready    => logical_op_ready,      
            result   => logical_result,
            clk      => clk
        );

    rotate_left_nr : rotate_register
        port map (
            clk          => clk,
            rst          => reset,                
            data_in      => operand1,
            shift_amount => shift_amount,
            direction    => '1',                  
            data_out     => rotate_left_result
        );

    rotate_right_nr : rotate_register
        port map (
            clk          => clk,
            rst          => reset,                
            data_in      => operand1,
            shift_amount => shift_amount,
            direction    => '0',                  
            data_out     => rotate_right_result
        );

    process(clk, reset)
    begin
        if reset = '1' then
            state                  <= Idle;
            temp_result            <= (others => '0');
            temp_carry_out         <= '0';
            temp_overflow          <= '0';
            division_by_zero_temp  <= '0';
            quotient_fin_temp      <= (others => '0');
            start_multiplication   <= '0';
            start_division         <= '0';
            start_rotation         <= '0';
            start_logical_op       <= '0';
            start_prev             <= '0';
            start_pulse            <= '0';
            operand1_data_in       <= (others => '0');
            operand2_data_in       <= (others => '0');
            internal_load_operand  <= '0';
            previous_operation_mul <= '0';
            previous_operation_div <= '0';
            
        elsif rising_edge(clk) then
            start_pulse <= '0';
            if (start_prev = '0') and (start = '1') then
                start_pulse <= '1';
            end if;
            start_prev <= start;
            
            case state is
                when Idle =>
                    internal_load_operand <= '0';
                    
                    if start_pulse = '1' then
                        if load_acc = '0' then
                            state <= Load_Registers;
                        else
                            state <= Load_Operands;
                        end if;
                    end if;
                    
                when Load_Registers =>
                    operand1_data_in <= operand1_mem;
                    operand2_data_in <= operand2_mem;
                    internal_load_operand <= '1';
                    state <= Operation_Start_Loaded;
                    
                when Load_Operands =>
                    if previous_operation_div = '1' then
                        operand2_data_in <= remainder;
                    elsif previous_operation_mul = '1' then
                        operand2_data_in <= multiplier_out(63 downto 32);
                    else
                        operand2_data_in <= operand2_mem;
                    end if;
                    internal_load_operand <= '1';
                    state <= Operation_Start_Loaded;
                    
                when Operation_Start_Loaded =>
                    internal_load_operand <= '0';
                    state <= Operation_Start;
                    
                when Operation_Start =>
                    if op_select = ADD_OP then
                        state <= Execute_Operation;
                    elsif op_select = SUB_OP then
                        state <= Execute_Operation;
                    elsif op_select = MUL_OP then
                        start_multiplication <= '1';
                        previous_operation_mul <= '1';
                        state <= Wait_For_Done;
                    elsif op_select = DIV_OP then
                        if operand2 = x"00000000" then
                            state <= Error_State;
                        else
                            start_division <= '1';
                            previous_operation_div <= '1';
                            state <= Wait_For_Done;
                        end if;
                    elsif op_select = ROT_LEFT_OP or op_select = ROT_RIGHT_OP then
                        start_rotation <= '1';
                        state <= Wait_For_Result;
                    elsif op_select(3) = '1' then
                        start_logical_op <= '1';
                        state <= Wait_For_Result;
                    else
                        state <= Idle;
                    end if;
                    
                when Execute_Operation =>
                    if op_select = ADD_OP then
                        temp_result    <= add_result;
                        temp_carry_out <= COUT_add;
                        temp_overflow  <= overflow_add;
                    elsif op_select = SUB_OP then
                        temp_result     <= sub_result;
                        temp_carry_out  <= COUT_sub;
                        temp_overflow   <= overflow_sub;
                    end if;
                    state <= Finalize;
                    
                when Wait_For_Done =>
                    if previous_operation_mul = '1' then
                        if multiplier_done = '1' then
                            temp_result          <= multiplier_out(31 downto 0);
                            start_multiplication <= '0';
                            state <= Finalize;
                        end if;
                    elsif previous_operation_div = '1' then
                        if end_division = '1' then
                            quotient_fin_temp    <= quotient;
                            temp_result          <= quotient;
                            division_by_zero_temp <= division_by_zero;
                            start_division       <= '0';
                            state <= Finalize;
                        end if;
                    end if;
                    
                when Wait_For_Result =>
                    if op_select(3) = '1' then
                        if logical_op_ready = '1' then
                            temp_result        <= logical_result;
                            start_logical_op   <= '0';
                            state <= Finalize;
                        end if;
                    elsif op_select = ROT_LEFT_OP then
                        temp_result       <= rotate_left_result;
                        start_rotation    <= '0';
                        state <= Finalize;
                    elsif op_select = ROT_RIGHT_OP then
                        temp_result       <= rotate_right_result;
                        start_rotation    <= '0';
                        state <= Finalize;
                    else
                        state <= Idle;
                    end if;
                    
                when Finalize =>
                    if op_select = DIV_OP then
                        if load_acc = '1' then
                            operand1_data_in <= quotient_fin_temp;
                            operand2_data_in <= remainder;
                            internal_load_operand <= '1';
                        else
                            operand1_data_in <= operand1_mem;
                            operand2_data_in <= operand2_mem;
                            internal_load_operand <= '1';
                        end if;
                    else
                        if load_acc = '1' then
                            operand1_data_in <= temp_result;
                            if previous_operation_mul = '1' then
                                operand2_data_in <= multiplier_out(63 downto 32);
                               
                            elsif previous_operation_div = '1' then
                                operand2_data_in <= remainder;
                            else
                                operand2_data_in <= operand2_mem;
                            end if;
                            internal_load_operand <= '1';
                        else
                            operand1_data_in <= operand1_mem;
                            operand2_data_in <= operand2_mem;
                            internal_load_operand <= '1';
                        end if;
                    end if;
                    
                    if op_select = DIV_OP then
                        result         <= quotient_fin_temp;
                        if division_by_zero_temp = '1' then
                               div_by_zero_flag <= '1';
                         else
                                 div_by_zero_flag <= '0';
                              end if;
                        quotient_fin <= quotient_fin_temp;
                          overflow_flag  <= '0';
                         carry_out_flag <= '0';
                    else
                        result         <= temp_result;
                        overflow_flag  <= temp_overflow; 
                          carry_out_flag <= temp_carry_out;
                         div_by_zero_flag <= '0';  
                    end if;
                    
                    start_multiplication <= '0';
                    start_division       <= '0';
                    start_rotation       <= '0';
                    start_logical_op     <= '0';
                    state <= Idle;
                    
                when Error_State =>
                    temp_result            <= (others => '0');
                    division_by_zero_temp  <= '1';
                    quotient_fin           <= (others => '0');  
                    result                 <= temp_result;
                    div_by_zero_flag <= '1';
                    overflow_flag    <= '0';
                    carry_out_flag   <= '0';
                    state                  <= Finalize;
                    
                when others =>
                    state <= Idle;
                    
            end case;
        end if;
    end process;

--    overflow_flag    <= temp_overflow;        
--    carry_out_flag   <= temp_carry_out;       
--    div_by_zero_flag <= division_by_zero_temp; 

    debug_operand1          <= operand1;
    debug_operand2          <= operand2;
    debug_temp_result       <= temp_result;
    debug_temp_carry_out    <= temp_carry_out;
    debug_temp_overflow     <= temp_overflow;
    div_remainder_debug     <= remainder;

end Behavioral;
