// .l3 tape player. An .l3 image is the byte stream the ACIA receives (start
// and stop bits already stripped; EmuB cmt.cpp feeds it one byte per 11 bit
// times). While the motor relay ($FFD2 bit 7) is on, hand the ACIA one byte
// every 11 bit periods. The byte period is shifted right by `speed` for fast
// loading (0 = real time).
module tape (
  input             clk,
  input             reset,
  input             rewind,
  input      [16:0] size,
  input             motor,
  input             baud1200,
  input       [2:0] speed,        // 0 = real time, n = 2^n times faster

  output reg [15:0] buf_addr,
  input       [7:0] buf_q,

  output reg        rx_strobe,
  output reg  [7:0] rx_data,
  output            active
);

// 32.256 MHz * 11 / 600 = 591360 clocks per byte; half that at 1200 baud.
wire [19:0] period = (baud1200 ? 20'd295680 : 20'd591360) >> speed;

reg [19:0] timer;
reg [16:0] pos;
reg        fetch;

assign active = motor && pos < size;

always @(posedge clk) begin
  rx_strobe <= 1'b0;
  fetch <= 1'b0;
  if (reset | rewind) begin
    timer <= 20'd0;
    pos <= 17'd0;
    buf_addr <= 16'd0;
  end else begin
    buf_addr <= pos[15:0];
    if (active) begin
      if (timer >= period) begin
        timer <= 20'd0;
        fetch <= 1'b1;
      end else begin
        timer <= timer + 20'd1;
      end
    end
    // buf_addr has held pos for many clocks, so buf_q is valid here
    if (fetch) begin
      rx_data <= buf_q;
      rx_strobe <= 1'b1;
      pos <= pos + 17'd1;
    end
  end
end

endmodule
