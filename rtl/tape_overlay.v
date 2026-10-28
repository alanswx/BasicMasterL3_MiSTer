// Tape status bar (tape standard rules 19-24, after the Sharp X1 core's
// x1_tape_overlay.sv). "TAPE > mm:ss/mm:ss x16" and a 64-step progress bar in
// the bottom-left corner of the picture while a tape is mounted and the motor
// relay is on. It is mixed into the RGB after the machine and never changes it.
//
// An .l3 image is one byte per 11 bit times, so tape time follows from bytes:
// elapsed = bytes played * 11 / baud, total = image size * 11 / baud, both at
// the current baud rate (fast loading shows "x16" instead), saturating at 99:59. Everything runs on clk_sys (CLK_VIDEO = clk_sys), so the status needs
// no clock-domain handshake.
module tape_overlay (
  input             clk,
  input             loaded,       // a tape is mounted
  input             playing,      // motor relay on
  input             fast,         // fast loading active
  input             baud1200,
  input      [31:0] position,     // bytes played (0 after mount/rewind)
  input      [31:0] size,         // bytes on the tape

  input             enable,
  input             ce_pix,
  input             hblank,
  input             vblank,
  input       [7:0] r_in, g_in, b_in,
  output reg  [7:0] r_out, g_out, b_out
);

function [15:0] bcd_tick;         // m1 m0 s1 s0 + 1 s
  input [15:0] t;
  begin
    bcd_tick = t;
    if (t != 16'h9959) begin
      if (t[3:0] != 4'd9) bcd_tick[3:0] = t[3:0] + 4'd1;
      else begin
        bcd_tick[3:0] = 4'd0;
        if (t[7:4] != 4'd5) bcd_tick[7:4] = t[7:4] + 4'd1;
        else begin
          bcd_tick[7:4] = 4'd0;
          if (t[11:8] != 4'd9) bcd_tick[11:8] = t[11:8] + 4'd1;
          else begin bcd_tick[11:8] = 4'd0; bcd_tick[15:12] = t[15:12] + 4'd1; end
        end
      end
    end
  end
endfunction

// ---- status ---------------------------------------------------------------
// Both times are divided out of byte counts at the current baud rate, so they
// stay consistent when a program switches between 600 and 1200 baud.
wire [10:0] baud = baud1200 ? 11'd1200 : 11'd600;
reg  [15:0] elapsed = 0, total = 0, e_cnt = 0, t_cnt = 0;
reg  [31:0] last_pos = 0, e_rem = 0, t_rem = 0, cell_n = 0;
reg         e_busy = 0, t_busy = 0;
reg   [6:0] fill = 0;
wire [31:0] cell_len = size[31:6] == 0 ? 32'd1 : {6'd0, size[31:6]};

function [31:0] x11;
  input [31:0] n;
  x11 = {n[28:0], 3'd0} + {n[30:0], 1'b0} + n;
endfunction

always @(posedge clk) begin
  // m:ss = bytes * 11 / baud, by repeated subtraction, recomputed continuously
  if (~e_busy) begin e_rem <= x11(position); e_cnt <= 0; e_busy <= 1'b1; end
  else if (e_rem >= {21'd0, baud}) begin e_rem <= e_rem - {21'd0, baud}; e_cnt <= bcd_tick(e_cnt); end
  else begin elapsed <= e_cnt; e_busy <= 1'b0; end
  if (~t_busy) begin t_rem <= x11(size); t_cnt <= 0; t_busy <= 1'b1; end
  else if (t_rem >= {21'd0, baud}) begin t_rem <= t_rem - {21'd0, baud}; t_cnt <= bcd_tick(t_cnt); end
  else begin total <= t_cnt; t_busy <= 1'b0; end

  last_pos <= position;
  if (position == 0 || position < last_pos) begin
    fill <= 0; cell_n <= 0;
  end else if (position != last_pos) begin
    if (cell_n + 32'd1 >= cell_len) begin
      cell_n <= 0;
      if (fill != 7'd64) fill <= fill + 7'd1;
    end else cell_n <= cell_n + 32'd1;
  end
end

// ---- picture --------------------------------------------------------------
reg [10:0] x = 0, width = 0;
reg  [9:0] y = 0, height = 0;
reg        line_active = 0, old_hb = 0, old_vb = 0;

always @(posedge clk) if (ce_pix) begin
  old_hb <= hblank; old_vb <= vblank;
  if (~hblank & ~vblank) begin x <= x + 11'd1; line_active <= 1'b1; end
  if (hblank & ~old_hb) begin
    if (line_active) begin width <= x; y <= y + 10'd1; end
    x <= 0; line_active <= 1'b0;
  end
  if (vblank & ~old_vb) begin height <= y; y <= 0; end
end

localparam CHARS = 22, BOX_W = CHARS * 8 + 4, BOX_H = 18;
wire       visible = enable & loaded & playing;
// doubled on 640-wide and 400-line pictures
wire       sx = width >= 11'd512, sy = height >= 10'd300;
wire [10:0] x0 = 11'd4;
wire  [9:0] y0 = height - (sy ? 10'd2 * BOX_H : 10'd1 * BOX_H) - 10'd4;
wire [10:0] dx = x - x0;
wire  [9:0] dy = y - y0;
wire [10:0] lx = sx ? {1'b0, dx[10:1]} : dx;
wire  [9:0] ly = sy ? {1'b0, dy[9:1]} : dy;
wire       in_box = x >= x0 && y >= y0 && lx < BOX_W && ly < BOX_H;

// text at ly 2..9: 0-9 digits, 10 ':', 11 '/', 12 T, 13 A, 14 P, 15 E,
// 16 x, 17 play, 18 space
wire [10:0] tx = lx - 11'd2;
wire  [9:0] ty = ly - 10'd2;
wire  [4:0] col = tx[7:3];
reg   [4:0] code;
always @(*) begin
  case (col)
    5'd0: code = 5'd12;  5'd1: code = 5'd13;  5'd2: code = 5'd14;  5'd3: code = 5'd15;
    5'd5: code = 5'd17;
    5'd7: code = elapsed[15:12] == 0 ? 5'd18 : {1'b0, elapsed[15:12]};
    5'd8: code = {1'b0, elapsed[11:8]};   5'd9: code = 5'd10;
    5'd10: code = {1'b0, elapsed[7:4]};   5'd11: code = {1'b0, elapsed[3:0]};
    5'd12: code = 5'd11;
    5'd13: code = total[15:12] == 0 ? 5'd18 : {1'b0, total[15:12]};
    5'd14: code = {1'b0, total[11:8]};    5'd15: code = 5'd10;
    5'd16: code = {1'b0, total[7:4]};     5'd17: code = {1'b0, total[3:0]};
    5'd19: code = fast ? 5'd16 : 5'd18;
    5'd20: code = fast ? 5'd1 : 5'd18;
    5'd21: code = fast ? 5'd6 : 5'd18;
    default: code = 5'd18;
  endcase
end
reg [63:0] g;
always @(*) begin
  case (code)
    5'd0:  g = 64'h3C666E7666663C00;  5'd1:  g = 64'h1838181818187E00;
    5'd2:  g = 64'h3C66060C30607E00;  5'd3:  g = 64'h3C66061C06663C00;
    5'd4:  g = 64'h0C1C3C6C7E0C0C00;  5'd5:  g = 64'h7E607C0606663C00;
    5'd6:  g = 64'h1C30607C66663C00;  5'd7:  g = 64'h7E060C1830303000;
    5'd8:  g = 64'h3C66663C66663C00;  5'd9:  g = 64'h3C66663E060C3800;
    5'd10: g = 64'h0018180018180000;  5'd11: g = 64'h02060C1830604000;
    5'd12: g = 64'h7E18181818181800;  5'd13: g = 64'h183C66667E666600;
    5'd14: g = 64'h7C66667C60606000;  5'd15: g = 64'h7E60607C60607E00;
    5'd16: g = 64'h0000663C183C6600;  5'd17: g = 64'h4060707870604000;
    default: g = 64'h0;
  endcase
end
wire [7:0] glyph_row = g[63 - {ty[2:0], 3'd0} -: 8];
wire       text_on = ty < 10'd8 && tx < CHARS * 8 && glyph_row[3'd7 - tx[2:0]];
// bar at ly 12..15, 128 px for 64 steps
wire       bar_area = ly >= 10'd12 && ly < 10'd16 && lx >= 11'd2 && lx < 11'd130;
wire       bar_on = bar_area && (lx - 11'd2) < {3'd0, fill, 1'b0};

always @(*) begin
  {r_out, g_out, b_out} = {r_in, g_in, b_in};
  if (visible && in_box)
    {r_out, g_out, b_out} = text_on ? 24'hFFFFFF : bar_on ? 24'h44CC44 :
                            bar_area ? 24'h333333 : 24'h000000;
end

endmodule
