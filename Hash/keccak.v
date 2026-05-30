module keccak(input [0:1599] S,
                input [4:0] nr,
                input string_val, //start condition
                input clk, rst,
                output reg [0:1599] S_out);

wire [7:0] ir;
reg [1:0] cs, ns; //current state, next state
wire [0:1599] S_out1, S_out2, S_out3, S_out4,S_final;
reg [4:0] counter;
reg [0:1599] A_temp;
reg [0:1599] A;

parameter s0 = 2'b00,
          s1 = 2'b01,
          s2 = 2'b10,
          s3 = 2'b11;


assign ir = {3'd0,{counter}}-8'd1; //five step process
theta Theta(.S(A_temp),.S_out(S_out1));
rho Rho(.S(S_out1),.S_out(S_out2));
pi Pi(.S(S_out2),.S_out(S_out3));
chi Chi(.S(S_out3),.S_out(S_out4));
iota Iota(.S(S_out4),.ir(ir),.S_out(S_final));

always@(posedge clk or posedge rst) begin
    if (rst) begin
        cs <= s0; //set to initial state
        counter <= 5'd1; //counter initial
        A_temp <= 1600'd0;
    end
    else begin
        cs <= ns; //updated the current state
        //ns=s2，A => A_temp
        A_temp <= (ns ==s2)? A:A_temp;
        if((cs==s2) && (counter!= nr)) begin
            counter <= counter + 5'd1;
        end //updated counter
        else if(ns == s0) begin
            counter <= 5'd1;
        end
        else begin
            counter <= counter;
        end
    end
end

always@(cs or counter or string_val or nr)begin
    // combinational block to decide next state
    case(cs)
        s0: ns = (string_val) ? s1 : s0;
        s1: ns = s2;
        s2: ns = (counter>=nr) ? s3 : s2;
        s3: ns = s0;
        default: ns = s0;
    endcase
end

always@(*) begin
    case(cs)
        s0: begin
            S_out = S_final;   // don't care in idle
            A     = A_temp;    // hold current state
        end
        s1: begin
            S_out = S_final;   // don't care yet
            A     = S;         // ← LOAD: capture input into A
        end
        s2: begin
            S_out = S_final;   // intermediate (not valid yet)
            A     = S_final;   // ← FEEDBACK: round output → next round input
        end
        s3: begin
            S_out = S_final;   // ← VALID OUTPUT here!
            A     = S_final;   // hold final value
        end
        default: begin
            S_out = 1600'd0;
            A     = 1600'd0;
        end
    endcase
end

endmodule




