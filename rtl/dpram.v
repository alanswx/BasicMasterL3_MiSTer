// Behavioural true dual-port RAM, one clock. Quartus infers M10K blocks from
// this; Verilator simulates it directly. The array is public so the sim
// harness can --dump-mem / --poke it.
module dpram #(
  parameter AW = 16,
  parameter DW = 8
) (
  input               clk,

  input      [AW-1:0] a_addr,
  input      [DW-1:0] a_din,
  input               a_we,
  output reg [DW-1:0] a_dout,

  input      [AW-1:0] b_addr,
  input      [DW-1:0] b_din,
  input               b_we,
  output reg [DW-1:0] b_dout
);

reg [DW-1:0] mem[0:(1<<AW)-1] /* verilator public_flat_rw */;

always @(posedge clk) begin
  if (a_we) mem[a_addr] <= a_din;
  a_dout <= mem[a_addr];
end

always @(posedge clk) begin
  if (b_we) mem[b_addr] <= b_din;
  b_dout <= mem[b_addr];
end

endmodule
