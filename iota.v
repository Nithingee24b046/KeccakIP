module iota(input [0:1599]S,
        input [7:0] current_round,
        output [0:1599]S_out);

wire A[0:4][0:4][0:63];
wire A_out[0:4][0:4][0:63];

reg [0:63]RC;
reg [0:7]R;
reg [0:8]R2, R2_temp;
reg [7:0]t;
integer i,j;

always@(*)begin
    RC = 64'd0;
   
    for(j=0;j<=6;j=j+1)begin
        t = j+(current_round+(current_round<<2)+(current_round<<1)); //t=j+7*ir
        R = 8'b10000000;

        if(t==0)begin   //if t%255=0 return 1, but tmax<255 => t=0 => 0%255=0
            RC[(2**j)-1] = 1;
        end
        else begin
            for(i=1;i<=t;i=i+1)begin
                R2 = {1'b0,{R}};
                R2_temp = R2;
                R2_temp[0]=R2[0]^R2[8];
                R2_temp[4]=R2[4]^R2[8];
                R2_temp[5]=R2[5]^R2[8];
                R2_temp[6]=R2[6]^R2[8];
                R = R2_temp[0:7];
            end
            RC[(2**j)-1] = R[0];
        end
    end
end

generate //str to state array (A[x][y][z]=S[64*(5*y+x)+z])
    for (genvar Z=0; Z<64; Z++) begin : z_conv
        for (genvar Y=0; Y<5; Y++) begin : y_conv 
            for (genvar X=0;  X<5; X++) begin : x_conv
                assign A[X][Y][Z] = S[64*(5*Y + X) + Z];
            end
        end
    end
endgenerate

//A_out[0][0][z1]=Aout4[0][0][z1] ^ RC[z1];
generate
        for(genvar i0=0;i0<64;i0=i0+1)begin: Lane00
                assign A_out[0][0][i0]=A[0][0][i0] ^ RC[i0];
        end
endgenerate

generate
    for(genvar i1=0; i1<64; i1++) begin: otherLane_z
        for(genvar yy=0; yy<5; yy++) begin: otherLane_y
            for(genvar xx=0; xx<5; xx++) begin: otherLane_x
                if(xx != 0 || yy != 0) begin  : skip_00 // skip (0,0)
                    assign A_out[xx][yy][i1] = A[xx][yy][i1];
                end
            end
        end
    end
endgenerate

//construct back the state array to str
generate 
    for (genvar Z=0; Z<64; Z++) begin : z_conv_back
        for (genvar Y=0; Y<5; Y++) begin : y_conv_back 
            for (genvar X=0;  X<5; X++) begin : x_conv_back
                assign S_out[Z + 64*(5*Y + X)] = A_out[X][Y][Z];
            end
        end
    end
endgenerate

endmodule