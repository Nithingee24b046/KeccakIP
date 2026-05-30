module theta(input [0:1599] S, output [0:1599] S_out);

wire A[0:4][0:4][0:63];
wire A_out[0:4][0:4][0:63];
wire [4:0] colbits[0:4][0:63];

generate //str to state array (A[x][y][z]=S[64*(5*y+x)+z])
    for (genvar Z=0; Z<64; Z++) begin : z_conv
        for (genvar Y=0; Y<5; Y++) begin : y_conv 
            for (genvar X=0;  X<5; X++) begin : x_conv
                assign A[X][Y][Z] = S[64*(5*Y + X) + Z];
            end
        end
    end

endgenerate

//a[i][ j][k] ← a[i][ j][k] xor 
//parity(a[0...4][j-1][k]) xor
//parity(a[0...4][j+1][k−1])

generate //packing the 5 A[0..4][Y][Z] bits into one vector to use reduction xo
    for (genvar Z=0; Z<64; Z++) begin : gz_col
        for (genvar Y=0; Y<5; Y++) begin : gy_col

            assign colbits[Y][Z] = {A[4][Y][Z],
                                    A[3][Y][Z],
                                    A[2][Y][Z],
                                    A[1][Y][Z],
                                    A[0][Y][Z]};
        end
    end
endgenerate

generate
    for (genvar Z=0; Z<64; Z++) begin : gz_out
        for (genvar Y=0; Y<5; Y++) begin : gy_out
            for (genvar X=0; X<5; X++) begin : gx_out

                assign A_out[X][Y][Z] = A[X][Y][Z]
                    ^ (^colbits[(Y+4)%5][Z])
                    ^ (^colbits[(Y+1)%5][(Z+63)%64]);

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