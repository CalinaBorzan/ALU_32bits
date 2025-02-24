# Arithmetic-Logical Unit (ALU) 

## Overview
The **Arithmetic-Logical Unit (ALU)** is a fundamental component of modern processors, designed to perform arithmetic and logical operations. This project implements a **32-bit ALU** using **VHDL**, capable of handling operations such as **addition, subtraction, multiplication, division, bitwise operations, and more**. The ALU is designed for integration into an **FPGA**, with results displayed on a **seven-segment display**.

## Key Features
- **Arithmetic Operations**: Addition, subtraction, multiplication, and division using **two's complement representation**.
- **Logical Operations**: Bitwise **AND, OR, NOT, negation**, and **rotation (left and right)**.
- **Error Handling**: Detects **overflow, carry-out, and division by zero**, with flags to indicate errors.
- **Accumulator Register**: Stores intermediate results for **sequential operations**.
- **FPGA Integration**: Designed for implementation on an **FPGA board**, with results displayed on a **seven-segment display**.

## Technologies Used
- **Hardware Description Language**: VHDL
- **FPGA Development Tools**: Xilinx Vivado
- **Simulation and Testing**: Waveform analysis using Vivado's built-in simulator
- **FPGA Board**: Basys3 for hardware implementation

## Key Functionalities
### 1. Arithmetic Operations
- **Addition and Subtraction**: Implemented using a **32-bit Carry Lookahead Adder (CLA)** for efficient computation.
- **Multiplication**: Uses a **Shift-and-Add algorithm** for **32-bit signed integers**, producing a **64-bit result**.
- **Division**: Implements a **Restoring Division Algorithm** for **32-bit signed integers**, yielding a **32-bit quotient and remainder**.

### 2. Logical Operations
- **Bitwise Operations**: AND, OR, NOT, and negation.
- **Rotation**: Left and right rotation of 32-bit operands.

### 3. Error Detection
- **Overflow**: Detects overflow in arithmetic operations.
- **Carry-Out**: Indicates when the result exceeds **32 bits**.
- **Division by Zero**: Detects and flags **division by zero** errors.

### 4. Accumulator Register
- Stores **intermediate results**, enabling **sequential operations** without reloading operands.

## Design and Implementation
### 1. Black Box
#### **Inputs:**
- **Operands**: `addr1`, `addr2`
- **Operation Selection**: `op_select`
- **Clock**: `clk`
- **Reset**: `reset`
- **Carry-In**: `CIN`
- **Load Accumulator**: `load_acc`

#### **Outputs:**
- **Result**: `result`
- **Overflow Flag**: `overflow_flag`
- **Carry-Out Flag**: `cout_flag`
- **Division by Zero Flag**: `div_by_zero_flag`

### 2. Key Components
- **Carry Lookahead Adder (CLA)**: Used for addition and subtraction.
- **Shift-and-Add Multiplier**: Implements **32-bit multiplication**.
- **Restoring Division Unit**: Implements **32-bit division**.
- **Logical Operations Unit**: Handles **bitwise operations and rotation**.
- **Accumulator Register**: Stores **intermediate results for sequential operations**.

### 3. Finite State Machine (FSM)
- Governs the **execution flow**, ensuring **structured and error-free operation**.
- Transitions through states to **load operands, execute operations, and finalize results**.

## Testing and Validation
The ALU was rigorously tested using **Vivado's simulation tools**. Test cases included:
- **Addition and Subtraction**: Positive and negative operands.
- **Multiplication**: Positive, negative, and mixed operands.
- **Division**: Positive, negative, and division by zero.
- **Logical Operations**: AND, OR, NOT, and rotation.

All operations were validated to ensure **correct results** and **proper error handling**.

## Future Developments
- **Extended Bit Width**: Support for **64-bit operations**.
- **Floating-Point Operations**: Add support for **floating-point arithmetic**.
- **Optimization**: Improve **performance and reduce resource usage** on the FPGA.
- **User Interface**: Enhance the FPGA interface for **easier operation selection and result display**.

## Why This Project?
This project demonstrates strong skills in **digital design, VHDL programming, and FPGA implementation**. It showcases the ability to design and implement a **complex arithmetic-logical unit** with **error handling** and **sequential operation support**. This project is a valuable addition to my portfolio for roles in **hardware design, embedded systems, and digital logic engineering**.

For any questions or feedback, feel free to reach out:

**Name**: [Your Name]  
**Email**: [Your Email]  
**GitHub**: [Your GitHub Profile]

