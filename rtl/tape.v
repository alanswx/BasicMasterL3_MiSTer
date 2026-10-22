// .l3 tape player. An .l3 image is the byte stream the ACIA receives (start
// and stop bits already stripped; EmuB cmt.cpp feeds it one byte per 11 bit
// times). While the motor relay ($FFD2 bit 7) is on, hand the ACIA one byte
// every 11 bit periods. The byte period is shifted right by `speed` for fast
// loading (0 = real time). When loading fast, a byte is also held until the
// CPU has taken the previous one (ACIA RDRF clear): the ROM's BASIC loader
// cannot keep up with 4x otherwise and the ACIA overruns.
//
// The image is not buffered on chip: it is a MiSTer block device, read one
// 512-byte sector at a time as playback reaches it, so any size works.
module tape (
  input             clk,
  input             reset,
  input             motor,
  input             baud1200,
  input       [2:0] speed,        // 0 = real time, n = 2^n times faster
  input             rx_full,      // ACIA still holds the previous byte

  // block device
  input             img_mounted,
  input      [63:0] img_size,
  output reg [31:0] sd_lba,
  output reg        sd_rd,
  input             sd_ack,
  input       [8:0] sd_buff_addr,
  input       [7:0] sd_buff_dout,
  input             sd_buff_wr,

  output reg        rx_strobe,
  output reg  [7:0] rx_data,
  output            active,
  output     [31:0] position
);

// 32.256 MHz * 11 / 600 = 591360 clocks per byte; half that at 1200 baud.
wire [19:0] period = (baud1200 ? 20'd295680 : 20'd591360) >> speed;

reg [19:0] timer;
reg [31:0] pos, size;
reg        fetch;
reg [22:0] loaded;            // sector held in the buffer
reg        valid;             // buffer holds `loaded`
reg        busy;

assign position = pos;
assign active = motor && pos < size;

wire [22:0] want = pos[31:9];
wire        have = valid && loaded == want;

wire [7:0] buf_q;
dpram #(9, 8) sector (
  .clk(clk),
  .a_addr(sd_buff_addr), .a_din(sd_buff_dout), .a_we(sd_ack & sd_buff_wr), .a_dout(),
  .b_addr(pos[8:0]), .b_din(8'd0), .b_we(1'b0), .b_dout(buf_q)
);

always @(posedge clk) begin
  rx_strobe <= 1'b0;
  fetch <= 1'b0;
  if (img_mounted) begin
    size <= img_size[31:0];
    pos <= 32'd0; timer <= 20'd0;
    valid <= 1'b0; busy <= 1'b0; sd_rd <= 1'b0;
  end else if (reset) begin
    timer <= 20'd0;
  end else begin
    // sector fetch: request the sector playback is in, if it is not loaded
    if (~busy && ~have && pos < size) begin
      sd_lba <= {9'd0, want};
      sd_rd <= 1'b1;
      busy <= 1'b1;
      valid <= 1'b0;
    end
    if (busy && sd_ack) sd_rd <= 1'b0;
    if (busy && ~sd_rd && ~sd_ack) begin
      busy <= 1'b0;
      valid <= 1'b1;
      loaded <= sd_lba[22:0];
    end

    if (active && have) begin
      if (timer >= period && (speed == 3'd0 || ~rx_full)) begin
        timer <= 20'd0;
        fetch <= 1'b1;
      end else begin
        timer <= timer + 20'd1;
      end
    end
    // pos has held its value for many clocks, so buf_q is valid here
    if (fetch) begin
      rx_data <= buf_q;
      rx_strobe <= 1'b1;
      pos <= pos + 32'd1;
    end
  end
end

endmodule
