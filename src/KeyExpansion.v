// Nk: Number of words (4 byte) in key
// Nr: Number of key expansion rounds

// This module contains the routine for calculating some ith round key
module KeyExpansionRound #(parameter Nk = 4, parameter Nr = 10, parameter [3 : 0] roundCount = 0)(keyIn, keyOut); // (Round Number {ith round}, Previous Round Key {i-1 th round key}, Output Key {ith Round Key})
    localparam keySize = Nk*32;

    // input [3:0] roundCount;         // Round Number, so ith round => i
    input [keySize - 1:0] keyIn;    // Previous Round Key as input, so i-1 th round key

    output [keySize - 1:0] keyOut;  // Output Key, so the ith Round Key

    genvar i;

    // Split the key into Nk words
    wire [31:0] words[Nk - 1:0]; // An array of 32 bit values, with Nk elements (basically to store key as words)

    generate
        for (i = 0; i < Nk; i = i + 1) begin: KeySplitLoop
            assign words[i] = keyIn[(32 * Nk - 1) - i * 32 -: 32];
        end
    endgenerate

    // Rotate the words (rotWord)
    wire [31:0] w3Rot = {words[Nk - 1][23:0], words[Nk - 1][31:24]};

    // Perform the substitution of the words (subWord)
    wire [31:0] w3Sub;

    generate 
        for (i = 0; i < 4; i = i + 1) begin: SubWordLoop
            SubTable subTable(w3Rot[8 * i +: 8], w3Sub[8 * i +: 8]);
        end
    endgenerate

    // Perform the XOR operation with the round constant (roundConstant)
    wire [7:0] roundConstantStart = roundCount == 1 ? 8'h01
                                        : roundCount == 2 ? 8'h02
                                        : roundCount == 3 ? 8'h04
                                        : roundCount == 4 ? 8'h08
                                        : roundCount == 5 ? 8'h10
                                        : roundCount == 6 ? 8'h20
                                        : roundCount == 7 ? 8'h40
                                        : roundCount == 8 ? 8'h80
                                        : roundCount == 9 ? 8'h1b
                                        : roundCount == 10 ? 8'h36
                                        : roundCount == 11 ? 8'h6c
                                        : roundCount == 12 ? 8'hd8
                                        : roundCount == 13 ? 8'hab
                                        : roundCount == 14 ? 8'h4d
                                        : roundCount == 15 ? 8'h9a
                                        : roundCount == 16 ? 8'h2f
                                        : 8'h00;
    wire [31:0] roundConstant = {roundConstantStart, 24'h00};

    assign keyOut[32 * Nk - 1 -: 32] = words[0] ^ w3Sub ^ roundConstant; // XOR the first word with the round constant

    // Perform SubWord transformation for i % Nk work (256 bits key only)
    wire [31:0] wSub;
    generate 
        for (i = 0; i < 4; i = i + 1) begin: SubWordLoopForWSub
            SubTable subTable(keyOut[(32 * Nk - 1) - 3 * 32 - i * 8 -: 8], wSub[(3 - i) * 8 +: 8]);
        end
    endgenerate

    generate
        for (i = 1; i < Nk; i = i + 1) begin: KeyExpansionLoop
            assign keyOut[(32 * Nk - 1) - i * 32 -: 32] = words[i] ^ (Nk == 8 && i == 4 ? wSub : keyOut[(32 * Nk - 1) - (i - 1) * 32 -: 32]); // XOR word i with word i - 1
        end
    endgenerate
endmodule

module KeyExpansion #(parameter Nk = 4, parameter Nr = 10) (keyIn, keysOut, clk);
    localparam rounds = (Nr == 10 ? 9 : (Nr == 12 ? 7 : 6));

    localparam keySize = Nk*32;

    input [keySize - 1:0] keyIn;
    output reg [((Nr + 1) * keySize) - 1:0] keysOut;
    input clk;

    // assign keysOut[((Nr + 1) * keySize) - 1 -: keySize] = keyIn;

    wire [keySize-1:0] keysOutWireArray [Nr:1];

    // assign keysOutWireArray[0] = keyIn;
    always @(*) begin
        keysOut[((Nr+1)*keySize)-1 -: keySize] <= keyIn;
    end

    // Perform the key expansion rounds (KeyExpansionRound)
    genvar i;
    generate
        for (i = 1; i <= rounds; i = i + 1) begin: KeyExpansionRoundLoop
            KeyExpansionRound #(Nk, Nr, i) keyExpansionRound(keysOut[((Nr + 2 - i) * keySize) - 1 -: keySize], keysOutWireArray[i]); // WARN: Please recheck the indexing I'm loosing my mind
        end
    endgenerate

    // Perform the last key expansion round (LastKeyExpansionRound)
    wire [keySize - 1:0] lastkey;
    KeyExpansionRound #(Nk, Nr, rounds[3:0] + 4'b0001) lastKeyExpansionRound (keysOut[128 +: keySize], lastkey);

    assign keysOutWireArray[Nr] = lastkey[keySize - 1 -: 128];

    integer j;
    always @(posedge clk) begin
        for(j=1; j<=Nr; j=j+1) begin
            keysOut[(Nr+1-j) * keySize -1 -: keySize] <= keysOutWireArray[j]; // WARN: Please recheck the indexing this is driving me crazy
        end
    end
endmodule
