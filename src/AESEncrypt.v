module AESEncrypt (stateIn, allKeys, stateOut, clk);
	parameter Nk = 4; parameter Nr = 10; parameter [5:0] roundCount = 1;
	
	input [127:0] stateIn;
	input [((Nr + 1) * 128) - 1:0] allKeys;
	input clk;
	// output done;
	output reg [127:0] stateOut; // Holds the state of the AES encryption  WARN: (idk if we can input stuff when initializing)

	// input reg [5:0] roundCount ; // Holds the current round count

	wire [127:0] subByteWire;		// Output of subByte
	wire [127:0] shiftRowsWire;		// Output of shiftRows
	wire [127:0] mixColumnsWire;	// Output of mixColumns
	wire [127:0] roundKeyInput;		// Input to roundKey
	wire [127:0] stateWire;			// The output wire, fed into the 'state' reg finally

	// Instantiate AES modules needed for encryption
	SubBytes sub(stateIn, subByteWire);	// Takes (prev?) state as input and sends the output to subByteWire
	ShiftRows shft(subByteWire, shiftRowsWire);
	MixColumns mix(shiftRowsWire, mixColumnsWire);
	AddRoundKey addkey(roundKeyInput , allKeys[((Nr + 1) * 128) - (roundCount - 1) * 128 - 1 -: 128], stateWire);

	// Assign roundKeyInput based on roundCount
	// roundCount = 1 -> stateIn    (basically round zero)
	// roundCount = 2 to Nr -> mixColumnsWire
	// roundCount = Nr + 1 -> shiftRowsWire
	assign roundKeyInput = (roundCount == 1) ? stateIn : (roundCount < Nr + 1) ? mixColumnsWire : shiftRowsWire;


	// Update state
	always @(posedge clk) begin
		stateOut <= stateWire;
	end
// assign done=(roundCount>Nr+1)?1'd1:1'd0; // If roundCount>Nr+1, done = 1;  WARN: done should probably be implemented in the wrapper now

endmodule

module AESEncrypt128_DUT(data,key,clk,out);
	localparam Nk = 4; localparam Nr = 10;

	input [127:0] data; // wire
	input [Nk * 32 - 1:0] key; // wire
	input clk; // wire
	output [127:0] out; // WARN: Probabaly should be a reg?
	// output done; // TODO: Need to change done implementation
	
	wire [((Nr + 1) * 128) - 1:0] allKeys; // WARN: idk if it should be a reg
	wire [127:0] allStates [Nr+1:0];

	assign allStates[0] = data;
	assign out = allStates[Nr+1];
	
	genvar i;

	KeyExpansion #(Nk, Nr) ke(.keyIn(key), .keysOut(allKeys), .clk(clk));

	generate
		for(i=0; i < (Nr+1); i = i + 1) begin: EncryptionRoundsModule
			AESEncrypt #(Nk, Nr, i+1) aes(.stateIn(allStates[i]), .allKeys(allKeys), .stateOut(allStates[i+1]), .clk(clk));
		end
	endgenerate
endmodule
