// HD46850 / MC6850 ACIA, byte level.
//
// The tape player hands over whole received bytes (rx_strobe); serial framing
// is not modelled. Transmit completes immediately and the byte is offered on
// tx_strobe/tx_data (cassette SAVE is a TODO).
module acia6850 (
  input            clk,
  input            reset,

  input            cs,
  input            rs,
  input            we,          // one-clk write strobe
  input            re,          // one-clk read strobe (side effects)
  input      [7:0] din,
  output reg [7:0] dout,

  input            rx_strobe,
  input      [7:0] rx_data,
  output reg       tx_strobe,
  output reg [7:0] tx_data,

  output     [7:0] cr_out,
  output           rx_full,      // RDRF: a received byte is waiting
  output           irq
);

reg [7:0] cr;
reg [7:0] rdr;
reg       rdrf, ovrn, tdre, mreset;

assign cr_out = cr;
assign rx_full = rdrf;

wire [7:0] status = {irq, 1'b0, ovrn, 1'b0, 2'b00, tdre, rdrf};

always @(*) dout = rs ? rdr : status;

assign irq = ~mreset & ((cr[7] & (rdrf | ovrn)) | ((cr[6:5] == 2'b01) & tdre));

always @(posedge clk) begin
  tx_strobe <= 1'b0;
  if (reset) begin
    cr <= 8'h03; rdr <= 8'h00;
    rdrf <= 1'b0; ovrn <= 1'b0; tdre <= 1'b0; mreset <= 1'b1;
  end else begin
    if (cs & we & ~rs) begin
      cr <= din;
      if (din[1:0] == 2'b11) begin
        mreset <= 1'b1; rdrf <= 1'b0; ovrn <= 1'b0; tdre <= 1'b0;
      end else begin
        mreset <= 1'b0; tdre <= 1'b1;
      end
    end
    if (cs & we & rs & ~mreset) begin
      tx_data <= din;
      tx_strobe <= 1'b1;
    end
    if (cs & re & rs) begin
      rdrf <= 1'b0; ovrn <= 1'b0;
    end
    if (rx_strobe & ~mreset) begin
      if (rdrf & ~(cs & re & rs)) ovrn <= 1'b1;
      else begin
        rdr <= rx_data; rdrf <= 1'b1;
      end
    end
  end
end

endmodule
