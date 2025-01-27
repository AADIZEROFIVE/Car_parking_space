# Car Park System

A Verilog implementation of a smart car parking system that manages multiple parking spaces and calculates parking fees in real-time.

## Features

- Manages 4 parking spaces
- Real-time fee calculation based on parking duration
- First-come-first-served space allocation
- Automatic space assignment for entering vehicles
- Individual fee tracking for each parking space
- Reset functionality for system initialization

## System Architecture

The system consists of two main modules:
- `CAR_PARK`: The main module implementing the parking system logic
- `car_park_tb`: A testbench module for system verification

### Input Signals

- `clk`: System clock signal
- `rst`: Reset signal (active high)
- `car_entered`: Signal indicating a new car arrival
- `car_left`: 4-bit signal indicating which space is being vacated

### Output Signals

- `o`: 4-bit signal showing occupied spaces
- `fee0` - `fee3`: 8-bit signals showing calculated fees for each space

## Implementation Details

### Main Module (CAR_PARK)

```verilog
module CAR_PARK(
    input clk,              
    input rst,              
    input car_entered,      
    input [3:0] car_left,   
    output reg [3:0] o,     
    output reg [7:0] fee0,  
    output reg [7:0] fee1,  
    output reg [7:0] fee2,  
    output reg [7:0] fee3   
);
```

The module implements:
- Space allocation logic
- Fee calculation based on duration
- Car entry and exit handling
- Individual space tracking

#### Fee Calculation

```verilog
parameter RATE = 8'd10;  // Rate per count
reg [7:0] counter [0:3];  // Separate counter for each space

// Fee calculation logic
fee0 <= (o[0]) ? counter[0] * RATE : 0;
fee1 <= (o[1]) ? counter[1] * RATE : 0;
fee2 <= (o[2]) ? counter[2] * RATE : 0;
fee3 <= (o[3]) ? counter[3] * RATE : 0;
```

### Testbench Module

```verilog
module car_park_tb;
    reg clk;
    reg rst;
    reg car_entered;
    reg [3:0] car_left;
    wire [3:0] o;
    wire [7:0] fee0, fee1, fee2, fee3;
```

The testbench includes:
- Clock generation
- Test sequence generation
- System monitoring
- Various test scenarios

## Test Scenarios

The testbench implements the following test sequence:
1. System initialization with reset
2. First car entry and parking
3. Second car entry and parking
4. Time delay for fee accumulation
5. First car exit
6. Second car exit
7. Third car entry and exit

## Usage

To use this module in your project:

1. Include both the main module and testbench files in your project
2. Compile using a Verilog compiler
3. Connect the following signals to your system:
   - Clock and reset
   - Car entry signal
   - Car exit signals
   - Monitor the output signals for space status and fees

## Simulation

To run the simulation:

```bash
# Using ModelSim
vsim -do run.do

# Using Icarus Verilog
iverilog car_park.v car_park_tb.v
vvp a.out
```

## Timing Diagram

The system operates on the following basic timing:
- Space allocation: 1 clock cycle after car_entered signal
- Fee calculation: Updated every clock cycle
- Space deallocation: 1 clock cycle after car_left signal

## Limitations

- Maximum of 4 parking spaces
- Fixed rate calculation
- No overflow protection for long-term parking
- Basic first-come-first-served allocation

## Future Improvements

- Variable rate calculation based on time of day
- Priority parking allocation
- Multiple entry/exit points
- Overflow protection for counters
- Parking space reservation system

## License

This project is open source and available under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
