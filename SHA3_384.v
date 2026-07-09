module SHA3_256(input [0:255] M, 
                input start, clk, rst,
                input [4:0] nr, 
                output reg [0: 383] Z);

parameter d_SIZE = 384;    // output digest size (SHA3-384 → 384 bits)
parameter c_SIZE = 768;    // capacity = 2 × d_SIZE = 2 × 384 = 768 bits
parameter r_SIZE = 832;    // rate = 1600 - c_SIZE = 1600 - 768 = 832 bits
parameter M_SIZE = 256;    // input message size
parameter j = 574;         // padding zeros = r_SIZE - (M_SIZE + 2)
                           //              = 832 - (256 + 2)
                           //              = 832 - 258
                           //              = 574

wire [0:r_SIZE - 1] N; //constructing the actual r
reg [1:0]    cs, ns;
reg [0:1599] str_temp;
reg [0:d_SIZE-1] Z_temp;
reg          string_val;
reg [4:0]    counter_f;
wire [0:1599] str_out;    

parameter s0 = 2'b00,
          s1 = 2'b01,
          s2 = 2'b10,
          s3 = 2'b11;

assign N = {M,1'b1,{j{1'b0}},1'b1}; //padding mechanism

KECCAK_p keccak_p( .S(str_temp),
                   .nr(nr),
                   .string_val(string_val),
                   .clk(clk), .rst(rst),
                   .S_out(str_out));

always@(posedge clk or posedge rst)begin
    if (rst) begin
        cs <= s0;
        str_temp <= 1600'd0;
        Z_temp <= {d_SIZE{1'b0}};
        counter_f <= 5'd0;
    end
    else begin
        cs <= ns;
        if(ns == s1)
            str_temp <= {N, {c_SIZE{1'b0}}};
        else
            str_temp <= str_temp;    // explicit hold
        if (cs==s2) begin
            counter_f <= counter_f + 5'd1;
        end 
        else 
            counter_f <= 5'd0;
        if(ns == s3) begin
            Z_temp <= str_out[0:d_SIZE-1];
        end
    end
end

always@(start or counter_f or cs or nr)begin
    case (cs) // combinatorial block
        s0 : ns = (start) ? s1 : s0;
        s1 : ns = s2;
        s2 : ns = (counter_f > nr) ? s3 : s2;
        s3 : ns = s3;
        default : ns = s0;
    endcase
end

always@(*)begin
    case (cs)
        s0 : begin 
                Z = Z_temp[0:d_SIZE-1];
                string_val = 1'b0;
            end
        s1 : begin
                Z = Z_temp[0:d_SIZE-1];
                string_val = 1'b1;
            end
        s2 : begin
                Z = Z_temp[0:d_SIZE-1];
                string_val = 1'b1;
            end
        s3 : begin
                Z = Z_temp[0:d_SIZE-1];
                string_val = 1'b0;
            end
            default: begin
                Z          = {d_SIZE{1'b0}};
                string_val = 1'b0;
            end
    endcase
end 


endmodule