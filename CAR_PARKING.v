module CAR_PARK(
    input clk,              
    input rst,              
    input car_entered,      
    input [3:0] car_left,   
    output reg [3:0] o,     
    output reg [7:0] fee0,  // Fee for parking space 0
    output reg [7:0] fee1,  // Fee for parking space 1
    output reg [7:0] fee2,  // Fee for parking space 2
    output reg [7:0] fee3   // Fee for parking space 3
);
    parameter RATE = 8'd10;  // Rate per count
    
    reg [7:0] counter [0:3];  // Separate counter for each space
    integer i;

    initial begin
        o = 4'b0;
        fee0 = 0;
        fee1 = 0;
        fee2 = 0;
        fee3 = 0;
        for (i = 0; i < 4; i = i + 1) begin
            counter[i] = 0;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            o <= 4'b0;
            fee0 <= 0;
            fee1 <= 0;
            fee2 <= 0;
            fee3 <= 0;
            for (i = 0; i < 4; i = i + 1) begin
                counter[i] <= 0;
            end
        end else begin
            // Update counters for occupied spaces
            for (i = 0; i < 4; i = i + 1) begin
                if (o[i]) begin
                    counter[i] <= counter[i] + 1;
                end
            end

            // Handle car entry
            if (car_entered) begin
                casez (o)
                    4'b???0: begin 
                        o[0] <= 1;
                        counter[0] <= 0;
                    end
                    4'b??01: begin 
                        o[1] <= 1;
                        counter[1] <= 0;
                    end
                    4'b?011: begin 
                        o[2] <= 1;
                        counter[2] <= 0;
                    end
                    4'b0111: begin 
                        o[3] <= 1;
                        counter[3] <= 0;
                    end
                    default: o <= o;
                endcase
            end
            
            // Update fees continuously for each space
            fee0 <= (o[0]) ? counter[0] * RATE : 0;
            fee1 <= (o[1]) ? counter[1] * RATE : 0;
            fee2 <= (o[2]) ? counter[2] * RATE : 0;
            fee3 <= (o[3]) ? counter[3] * RATE : 0;
            
            // Handle car exit
            if (car_left != 4'b0) begin
                for (i = 0; i < 4; i = i + 1) begin
                    if (car_left[i]) begin
                        counter[i] <= 0;
                        o[i] <= 0;
                    end
                end
            end
        end
    end
endmodule

module car_park_tb;
    reg clk;
    reg rst;
    reg car_entered;
    reg [3:0] car_left;
    wire [3:0] o;
    wire [7:0] fee0, fee1, fee2, fee3;

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    CAR_PARK cp (
        .clk(clk),
        .rst(rst),
        .car_entered(car_entered),
        .car_left(car_left),
        .o(o),
        .fee0(fee0),
        .fee1(fee1),
        .fee2(fee2),
        .fee3(fee3)
    );

    initial begin
        // Initialize
        $monitor("Time=%0t | Spaces=%b | Car_Left=%b | Fees: Space0=%d Space1=%d Space2=%d Space3=%d", 
                 $time, o, car_left, fee0, fee1, fee2, fee3);
        rst = 1;
        car_entered = 0;
        car_left = 4'b0000;
        
        // Release reset
        #10 rst = 0;
        
        // Test sequence
        // First car enters space 0
        #10 car_entered = 1;
        #10 car_entered = 0;
        
        // Second car enters space 1
        #10 car_entered = 1;
        #10 car_entered = 0;
        
        // Wait some time (different for each car)
        #50;
        
        // First car leaves
        car_left = 4'b0001;
        #10 car_left = 4'b0000;
        
        // Wait more time
        #30;
        
        // Second car leaves
        car_left = 4'b0010;
        #10 car_left = 4'b0000;
        
        // Third car enters space 0
        #10 car_entered = 1;
        #10 car_entered = 0;
        
        // Wait some time
        #40;
        
        // Third car leaves
        car_left = 4'b0001;
        
        #10 $finish;
    end
endmodule
