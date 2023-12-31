// fpga4student.com: FPGA projects, Verilog projects, VHDL projects
// FPGA tutorial: seven-segment LED display controller on Basys  3 FPGA
module Seven_segment_LED_Display_Controller(
    //input clock_100Mhz, // 100 Mhz clock source on Basys 3 FPGA
    input clk,
    input reset, // reset
    input [7:0] ascii_code,
    output reg [3:0] Anode_Activate, // anode signals of the 7-segment LED display
    output reg [6:0] LED_out// cathode patterns of the 7-segment LED display
    );
    reg [26:0] one_second_counter; // counter for generating 1 second clock enable
    wire one_second_enable;// one second enable for counting numbers
    reg [15:0] displayed_number; // counting number to be displayed
    reg [7:0] LED_BCD;
    reg [19:0] refresh_counter; // 20-bit for creating 10.5ms refresh period or 380Hz refresh rate
             // the first 2 MSB bits for creating 4 LED-activating signals with 2.6ms digit period
    wire [1:0] LED_activating_counter; 
                 // count     0    ->  1  ->  2  ->  3
              // activates    LED1    LED2   LED3   LED4
             // and repeat
    //always @(posedge clock_100Mhz or posedge reset)
    always @(posedge clk or posedge reset)
    begin
        if(reset==1)
            one_second_counter <= 0;
        else begin
            if(one_second_counter>=99999999) 
                 one_second_counter <= 0;
            else
                one_second_counter <= one_second_counter + 1;
        end
    end 
    assign one_second_enable = (one_second_counter==99999999)?1:0;
    //always @(posedge clock_100Mhz or posedge reset)
    always @(posedge clk or posedge reset)
    begin
        if(reset==1)
            displayed_number <= 0;
        else if(one_second_enable==1)
            displayed_number <= displayed_number + 1;
    end
    //always @(posedge clock_100Mhz or posedge reset)
    always @(posedge clk or posedge reset)
    begin 
        if(reset==1)
            refresh_counter <= 0;
        else
            refresh_counter <= refresh_counter + 1;
    end 
    assign LED_activating_counter = refresh_counter[19:18];
    // anode activating signals for 4 LEDs, digit period of 2.6ms
    // decoder to generate anode signals 
    always @(*)
    begin
        case(LED_activating_counter)
        2'b00: begin
            Anode_Activate = 4'b0111; 
            // activate LED1 and Deactivate LED2, LED3, LED4
            //LED_BCD = displayed_number/1000;
            if (ascii_code[7:0] == 8'h2A) 
            Anode_Activate = 4'b1111; 
            else 
            LED_BCD = 8'b10000000;
            // the first digit of the 16-bit number
              end
        2'b01: begin
            Anode_Activate = 4'b1011; 
            // activate LED2 and Deactivate LED1, LED3, LED4
            //LED_BCD = (displayed_number % 1000)/100; 4'b0010
            if (ascii_code == 8'h2A) 
            Anode_Activate = 4'b1111; 
            else 
            LED_BCD = ascii_code[7:4];
            // the second digit of the 16-bit number
              end
        2'b10: begin
            Anode_Activate = 4'b1101; 
            // activate LED3 and Deactivate LED2, LED1, LED4
            //LED_BCD = ((displayed_number % 1000)%100)/10;
            if (ascii_code == 8'h2A) 
            Anode_Activate = 4'b1111; 
            else 
            LED_BCD = ascii_code[3:0]; 
            // the third digit of the 16-bit number
                end
        2'b11: begin
            Anode_Activate = 4'b1110; 
            // activate LED4 and Deactivate LED2, LED3, LED1
            //LED_BCD = ((displayed_number % 1000)%100)%10;
            if (ascii_code[7:0] == 8'h2A) 
            Anode_Activate = 4'b1111; 
            else 
            LED_BCD = 8'b10000000;
            // the fourth digit of the 16-bit number    
               end
        endcase
    end
    // Cathode patterns of the 7-segment LED display 
    always @(*)
    begin
        case(LED_BCD)
        8'b00000000: LED_out = 7'b0000001; // "0"  // abcdefg       a
        8'b00000001: LED_out = 7'b1001111; // "1"                  ?
        8'b00000010: LED_out = 7'b0010010; // "2"               f?g?b
        8'b00000011: LED_out = 7'b0000110; // "3"                 ?
        8'b00000100: LED_out = 7'b1001100; // "4"              e? ?c
        8'b00000101: LED_out = 7'b0100100; // "5"                ?
        8'b00000110: LED_out = 7'b0100000; // "6"                d
        8'b00000111: LED_out = 7'b0001111; // "7"  
        8'b00001000: LED_out = 7'b0000000; // "8"     
        8'b00001001: LED_out = 7'b0000100; // "9" 
        
        8'b00001010: LED_out = 7'b0001000; // "A"  // abcdefg       a
        8'b00001011: LED_out = 7'b1100000; // "b"                  ?
        8'b00001100: LED_out = 7'b0110001; // "C"               f?g?b
        8'b00001101: LED_out = 7'b1000010; // "d"                 ?
        8'b00001110: LED_out = 7'b0110000; // "E"              e? ?c
        8'b00001111: LED_out = 7'b0111000; // "F"                ?
                                       //                    d
        8'b10000000: LED_out = 7'b1111110; // "-"
        8'b11000000: LED_out = 7'b1111111; // " "
            default: LED_out = 7'b1111110; // "0"                   
   endcase                                              
   end
 endmodule