module rho(input [0:1599]S,output  [0:1599]S_out);

wire A[0:4][0:4][0:63];
wire A_out[0:4][0:4][0:63];

//first we will compute the i_new, j_new for corresponding t
function automatic integer get_i(input integer t);
    integer ii, jj, tmp, k;
    begin
        ii = 0; jj = 1;
        for (k = 0; k < t; k++) begin
            tmp = (3*ii + 2*jj) % 5;
            jj  = ii;
            ii  = tmp;
        end
        get_i = ii; //this is the return function it seems
    end
endfunction

function automatic integer get_j(input integer t);
    integer ii, jj, tmp, k;
    begin
        ii = 0; jj = 1;
        for (k = 0; k < t; k++) begin
            tmp = (3*ii + 2*jj) % 5;
            jj  = ii;
            ii  = tmp;
        end
        get_j = jj; //this is the return function it seems
    end
endfunction
 
generate //str to state array (A[x][y][z]=S[64*(5*y+x)+z])
    for (genvar Z=0; Z<64; Z++) begin : z_conv
        for (genvar Y=0; Y<5; Y++) begin : y_conv 
            for (genvar X=0;  X<5; X++) begin : x_conv
                assign A[X][Y][Z] = S[64*(5*Y + X) + Z];
            end
        end
    end

endgenerate

/* 
Start condition: x=1, y=0
parameter t varies from 0 to 23
x=0, y=0 is untouched
i_new = (3*i_old + 2*j_old)%5
j_new = i_old
*/

generate
        for(genvar z=0;z<64;z=z+1)begin: Lane00
                assign A_out[0][0][z] = A[0][0][z];
        end
endgenerate

generate 
    for (genvar T=0; T<24; T++) begin : rho_t
        for (genvar Z=0; Z<64; Z++) begin : rho_z
            assign A_out[get_i(T)][get_j(T)][Z] = A[get_i(T)][get_j(T)][(Z - (((T+1)*(T+2))/2) + 64*5)%64];
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