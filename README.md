# Car_parking_space
Tracks the number of cars entering and leaving a parking lot, showing available slots.
##NOTE
Building a basic car parking automation system on Vivado (using FPGAs) is an exciting project that combines hardware description languages (HDLs) like VHDL or Verilog with digital logic design. This type of system could be designed for tasks such as detecting available parking spots, guiding cars into parking spaces, and monitoring parking occupancy.

Here’s an overview of the steps and components you'll need for such a project.

### Steps for Building a Basic Car Parking Automation System on Vivado:

#### 1. **Define the System Requirements**
   - **Input Signals**:
     - Sensors to detect the presence of cars (e.g., ultrasonic sensors, infrared sensors, or cameras).
     - Manual control inputs (if needed, e.g., for system testing or override).
   - **Output Signals**:
     - LED indicators to show whether a parking spot is occupied or available.
     - Servo motors or stepper motors for moving a barrier or guiding a car into the parking spot.
     - A display system (e.g., 7-segment displays, or an LCD for showing parking status).
   - **System Behavior**:
     - Detect free and occupied spots.
     - Assign parking spots to incoming cars.
     - Provide guiding signals (e.g., lights, arrows) to help drivers park in available spots.
     - Monitor parking area status in real-time.

#### 2. **Choose the Components**
   To implement a basic car parking automation system, you'll need both hardware and software components:
   - **FPGA Development Board** (e.g., Xilinx Spartan-6, Artix-7, or Zynq).
   - **Sensors**: Ultrasonic distance sensors or IR sensors to detect whether a parking spot is occupied.
   - **Motors**: Stepper motors or servo motors for mechanical control (e.g., to open/close barriers).
   - **Display**: 7-segment display or an LED matrix for showing the status.
   - **Power Supply**: Ensure a reliable and stable power source for both the FPGA and the motors/sensors.

#### 3. **Design the Digital Logic**
   In Vivado, you’ll need to design the digital logic using either VHDL or Verilog. The primary tasks you need to implement are:

   - **Sensor Interface**:
     - Connect and configure ultrasonic sensors to detect car presence.
     - Interface with GPIO pins on the FPGA to get data from the sensors.
     - Create logic to debounce or filter out noisy sensor signals.

   - **Parking Spot Management**:
     - Use a finite state machine (FSM) or other logic to track the status of each parking spot (free/occupied).
     - Create logic to assign a parking spot to a car and update its status.
     - Display the status of the parking lot (free spots, occupied spots) on an LED or 7-segment display.

   - **Servo Motor Control**:
     - If you are controlling barriers or guiding the car into the parking spot, use PWM (pulse-width modulation) signals to control servo motors.
     - For a more sophisticated design, you could control stepper motors for more precise movements.
   
   - **Display Output**:
     - Create logic for driving the display (LEDs or 7-segment displays) to indicate parking spot status.

Sure! Here’s the same basic car parking automation system code in **Verilog**. This version will include the following components:

1. **Sensor Input Logic**: Simple detection of whether a car is present or not.
2. **Parking Spot Management**: A simple finite state machine (FSM) to manage the parking spots (free/occupied).
3. **Servo Motor Control**: Simple PWM generation to control a servo motor (e.g., for controlling parking barriers).
4. **Display Output**: Show status using a single LED to represent whether the parking spot is free or occupied.

### Verilog Code for Car Parking Automation System

#### 1. **Sensor Input Logic**
This part handles the input from a sensor (e.g., ultrasonic or IR) and provides a signal indicating whether a parking spot is occupied or not.

```verilog
module parking_sensor (
    input clk,               // Clock signal
    input sensor_input,      // Sensor input (e.g., ultrasonic or IR)
    output reg car_detected  // Output signal to indicate car detection
);

always @(posedge clk) begin
    car_detected <= sensor_input;  // Update the car_detected status based on the sensor input
end

endmodule
```

#### 2. **Parking Spot Management (FSM)**

This simple finite state machine (FSM) keeps track of parking spot occupancy. It checks whether a spot is free or occupied and updates its state.

```verilog
module parking_spot_manager (
    input clk,                // Clock signal
    input car_detected,       // Car detection signal from sensor
    output reg spot_status    // Output signal indicating whether the parking spot is free (0) or occupied (1)
);

// FSM States
typedef enum reg [1:0] {
    IDLE = 2'b00,
    PARKING = 2'b01,
    OCCUPIED = 2'b10
} state_t;

state_t state, next_state;

always @(posedge clk) begin
    state <= next_state;  // Update state on clock edge
end

// Next state logic
always @(*) begin
    case (state)
        IDLE: begin
            if (car_detected) begin
                next_state = PARKING;  // If a car is detected, move to PARKING state
            end else begin
                next_state = IDLE;     // Otherwise, stay in IDLE state
            end
        end
        
        PARKING: begin
            next_state = OCCUPIED;  // Once a car is parked, move to OCCUPIED state
        end
        
        OCCUPIED: begin
            next_state = OCCUPIED;  // Once the spot is occupied, stay in OCCUPIED state
        end
        
        default: begin
            next_state = IDLE;  // Default state
        end
    endcase
end

// Output logic to indicate spot occupancy
always @(state) begin
    case (state)
        IDLE: spot_status = 0;  // Spot is free
        OCCUPIED: spot_status = 1;  // Spot is occupied
        default: spot_status = 0;  // Default to free spot
    endcase
end

endmodule
```

#### 3. **Servo Motor PWM Control**

This part of the code generates a PWM signal to control a servo motor. It assumes that the duty cycle can be controlled to move the motor.

```verilog
module pwm_generator (
    input clk,                 // Clock signal
    input [7:0] pwm_duty,      // Duty cycle for PWM (range 0-255)
    output reg pwm_out         // PWM output signal to control servo motor
);

reg [7:0] pwm_counter;  // Counter for PWM signal

always @(posedge clk) begin
    pwm_counter <= pwm_counter + 1;  // Increment counter on each clock cycle
    if (pwm_counter < pwm_duty) begin
        pwm_out <= 1;  // High signal for the duty cycle duration
    end else begin
        pwm_out <= 0;  // Low signal for the remaining period
    end
end

endmodule
```

#### 4. **Top-Level Module**

This top-level module integrates all the components: sensor logic, FSM for parking spot management, and PWM generation for the servo motor.

```verilog
module car_parking_automation (
    input clk,               // Clock signal
    input sensor_input,      // Car presence detection from sensor
    input [7:0] pwm_duty,    // Duty cycle for the servo motor
    output spot_status,      // Parking spot status (0 = free, 1 = occupied)
    output pwm_out           // PWM signal to control the servo motor
);

// Internal signals
wire car_detected;          // Signal indicating car detection

// Instantiate parking sensor logic
parking_sensor ps (
    .clk(clk),
    .sensor_input(sensor_input),
    .car_detected(car_detected)
);

// Instantiate parking spot manager
parking_spot_manager psm (
    .clk(clk),
    .car_detected(car_detected),
    .spot_status(spot_status)
);

// Instantiate PWM generator for controlling the servo motor
pwm_generator pwm (
    .clk(clk),
    .pwm_duty(pwm_duty),
    .pwm_out(pwm_out)
);

endmodule
```

### Key Points in the Verilog Design:
- **Parking Sensor Logic**: Detects whether a car is present in a parking spot using an input signal.
- **FSM for Parking Spot**: Manages the state of a parking spot (free, occupied). When a car is detected, the FSM transitions through different states (IDLE -> PARKING -> OCCUPIED).
- **PWM Generation**: Generates a PWM signal for controlling a servo motor, which could be used to open/close a barrier or guide the car into the spot.
- **Top-Level Integration**: Combines the modules to create the full system. The parking spot status is displayed via `spot_status`, and the PWM signal for the servo motor is output on `pwm_out`.

### Testing the Design:

1. **Simulation**: You can simulate this Verilog code in Vivado to check the behavior of the FSM, sensor logic, and PWM signal.
2. **Synthesis and Implementation**: After simulation, synthesize the design to generate the bitstream and upload it to an FPGA board.
3. **Hardware Testing**: After loading the design to the FPGA, test the system with actual sensors and motors.

This basic car parking automation system should be a good starting point for further enhancements, such as adding more parking spots, incorporating more advanced sensor types (e.g., cameras or RFID), and improving the motor control system for more precise actions.

Let me know if you need further clarification on any part!
