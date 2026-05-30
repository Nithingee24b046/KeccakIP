module chi(input [0:1599]S,output  [0:1599]S_out);

wire A[0:4][0:4][0:63];
wire A_out[0:4][0:4][0:63];

generate //str to state array (A[x][y][z]=S[64*(5*y+x)+z])
    for (genvar Z=0; Z<64; Z++) begin : z_conv
        for (genvar Y=0; Y<5; Y++) begin : y_conv 
            for (genvar X=0;  X<5; X++) begin : x_conv
                assign A[X][Y][Z] = S[64*(5*Y + X) + Z];
            end
        end
    end
endgenerate

/*a[i][ j][k] ← a[i][ j][k] ⊕ 
 (¬a[i][ j+1][k] & a[i][ j+2][k])
*/

generate 
    for (genvar Z=0; Z<64; Z++) begin : gz
        for (genvar Y=0; Y<5; Y++) begin :  gy
            for (genvar X=0;  X<5; X++) begin : gx
                assign A_out[X][Y][Z] = A[X][Y][Z] ^ ((A[X][(Y+1)%5][Z] ^ 1'b1) & A[X][(Y+2)%5][Z]);
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