// HD46505SP (6845) CRTC, clock-enable driven.
//
// Counting follows EmuB-6892's hd46505.cpp, including interlace sync & video
// mode (R8[1:0] = 3), where the raster address steps by 2 and a row is
// (R9+2)/2 lines per field.
//
// With `interlace` off only the even field is generated, as a progressive
// 262-line frame; that loses nothing for ASCII (the interlace character set
// line-doubles it) but halves the 16-line interlace glyphs. With it on, an
// interlaced CRTC (R8[0] = 1) alternates fields: the odd field starts at
// raster 1 in video mode and its VSYNC comes half a line later, giving
// 262.5-line fields; `field` tells MiSTer which one is which.
module crtc6845 (
  input             clk,
  input             reset,
  input             cclk_en,      // one tick per character clock
  input             interlace,    // honour R8 interlace (else even field only)
  input             cur_half,     // S1 40-column text: cursor covers both CRTC chars

  // CPU port (RS = A0)
  input             cs,
  input             we,           // write strobe, one clk
  input             rs,
  input       [7:0] din,
  output reg  [7:0] dout,

  output     [13:0] ma,
  output      [4:0] ra,
  output            de,
  output            hde,
  output            vde,
  output            hsync,
  output            vsync,
  output            cursor,
  output            vmode,        // interlace sync & video mode
  output            field         // 1 = odd field
);

reg [7:0] r[0:17];
reg [4:0] ar;

wire [7:0] R0 = r[0], R1 = r[1], R2 = r[2], R3 = r[3];
wire [6:0] R4 = r[4][6:0];
wire [4:0] R5 = r[5][4:0];
wire [6:0] R6 = r[6][6:0], R7 = r[7][6:0];
wire [1:0] imode = r[8][1:0];
wire [4:0] R9 = r[9][4:0];
wire [6:0] R10 = r[10][6:0];
wire [4:0] R11 = r[11][4:0];
wire [13:0] start_addr = {r[12][5:0], r[13]};
wire [13:0] cursor_addr = {r[14][5:0], r[15]};

assign vmode = imode == 2'b11;

integer i;
always @(posedge clk) begin
  if (reset) begin
    ar <= 5'd0;
    for (i = 0; i < 18; i = i + 1) r[i] <= 8'd0;
  end else if (cs & we) begin
    if (~rs) ar <= din[4:0];
    else if (ar < 5'd16) r[ar] <= din;
  end
end

always @(*) begin
  case (ar)
    5'd14: dout = {2'b00, r[14][5:0]};
    5'd15: dout = r[15];
    5'd16: dout = {2'b00, r[16][5:0]};
    5'd17: dout = r[17];
    default: dout = 8'h00;
  endcase
end

// ---------------------------------------------------------------------------
reg  [7:0] h;
reg  [6:0] row;
reg  [4:0] rac;
reg  [4:0] adj;
reg        in_adj;
reg [13:0] row_start;
reg  [4:0] vs_cnt;
reg  [5:0] fcnt;
reg        odd;
reg        vs_half;
wire       ilace = interlace & imode[0];

wire [5:0] max_ra = {1'b0, R9} + (vmode ? 6'd2 : 6'd1);
wire [5:0] ra_next = {1'b0, rac} + (vmode ? 6'd2 : 6'd1);
wire [3:0] hsw = R3[3:0];
wire [4:0] vsw = R3[7:4] == 4'd0 ? 5'd16 : {1'b0, R3[7:4]};

always @(posedge clk) begin
  if (reset) begin
    h <= 8'd0; row <= 7'd0; rac <= 5'd0; adj <= 5'd0; in_adj <= 1'b0;
    row_start <= 14'd0; vs_cnt <= 5'd0; fcnt <= 6'd0; odd <= 1'b0; vs_half <= 1'b0;
  end else if (cclk_en) begin
    if (h == R0) begin
      h <= 8'd0;
      if (vs_cnt != 5'd0) vs_cnt <= vs_cnt - 5'd1;

      if (in_adj) begin
        if ({1'b0, adj} + 6'd1 >= {1'b0, R5}) begin
          row <= 7'd0; rac <= {4'd0, vmode & ilace & ~odd}; in_adj <= 1'b0;
          row_start <= start_addr;
          fcnt <= fcnt + 6'd1; odd <= ilace & ~odd;
        end else adj <= adj + 5'd1;
      end else if (ra_next >= max_ra) begin
        rac <= {4'd0, vmode & odd};
        row_start <= row_start + {6'd0, R1};
        if (row == R4) begin
          if (R5 != 5'd0) begin
            in_adj <= 1'b1; adj <= 5'd0;
          end else begin
            row <= 7'd0; row_start <= start_addr;
            rac <= {4'd0, vmode & ilace & ~odd};
            fcnt <= fcnt + 6'd1; odd <= ilace & ~odd;
          end
        end else begin
          row <= row + 7'd1;
          if (row + 7'd1 == R7) vs_cnt <= vsw;
        end
      end else begin
        rac <= ra_next[4:0];
      end
    end else begin
      h <= h + 8'd1;
    end
    if (h == {1'b0, R0[7:1]}) vs_half <= vs_cnt != 5'd0;
  end
end

wire v_de = ~in_adj & (row < R6);
wire h_de = h < R1;

assign ma = row_start + {6'd0, h};
assign ra = rac;
assign de = h_de & v_de;
assign hde = h_de;
assign vde = v_de;
assign hsync = (hsw != 4'd0) && (h >= R2) && (h < R2 + {4'd0, hsw});
assign vsync = odd ? vs_half : (vs_cnt != 5'd0);
assign field = odd;

reg blink;
always @(*) begin
  case (R10[6:5])
    2'b00: blink = 1'b1;
    2'b01: blink = 1'b0;
    2'b10: blink = fcnt[3];
    2'b11: blink = fcnt[4];
  endcase
end

assign cursor = de & blink &
                (cur_half ? ma[13:1] == cursor_addr[13:1] : ma == cursor_addr) &
                (rac >= R10[4:0]) & (rac <= R11);

endmodule
