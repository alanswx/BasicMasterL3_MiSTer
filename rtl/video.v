// Level 3 display pipeline: CRTC address -> VRAM + colour RAM -> character
// generator / graphic / IG pattern -> 16.128 MHz pixels.
//
// Rules follow EmuB-6892 display.cpp / displaysub.h:
//   colour RAM byte: [2:0] fg (B,R,G = bits 0,1,2), [3] reverse, [4] graphic,
//                    [5] IG (Mark 5).
//   hi-res mode ($FFD0 bit 6 = 0) adds ((RA >> IS) & 7) << (10 + W80) to MA.
//   VRAM addresses wrap inside $0400-$43FF.
//
// Phase (cnt = clk_sys mod 32, or mod 16 in 80 columns):
//   0 character clock to the CRTC     1 VRAM address registered
//   3 VRAM / colour byte latched      5 pattern latched (font/IG ready)
//   even cnt: pixel register updated  odd cnt: CE_PIXEL
module video (
  input             clk,
  input             reset,
  input       [4:0] cnt,

  input             w80,          // $FFD0 bit 7
  input             hireso,       // $FFD0 bit 6 == 0
  input       [2:0] bg,           // $FFD0 bits 2-0
  input             is,           // $FFD6 bit 3
  input             ig_dis,       // $FFE9 bit 0: CPU owns IG RAM, show blanks
  input             ig_ok,        // machine has IG (Mark 5)
  input             border_en,    // show the background colour round the picture

  output            cclk_en,

  // CRTC
  input      [13:0] ma,
  input       [4:0] ra,
  input             h_de,
  input             v_de,
  input             hsync_in,
  input             vsync_in,
  input             cursor_in,
  input             vmode,

  // memories
  output reg [15:0] vram_addr,
  input       [7:0] vram_q,
  output     [13:0] cram_addr,
  input       [5:0] cram_q,
  output     [11:0] font_addr,
  input       [7:0] font_q,
  output     [10:0] ig_addr,
  input       [7:0] ig_b,
  input       [7:0] ig_r,
  input       [7:0] ig_g,

  output reg  [7:0] red,
  output reg  [7:0] green,
  output reg  [7:0] blue,
  output reg        hs,
  output reg        vs,
  output reg        hb,
  output reg        vb,
  output            ce_pix
);

wire [4:0] ph = w80 ? {1'b0, cnt[3:0]} : cnt;
assign cclk_en = ph == 5'd0;
assign ce_pix = cnt[0];

// --- border ----------------------------------------------------------------
// The visible window is the display area plus 64 pixels each side and 16
// lines top and bottom, measured from the display enables so a reprogrammed
// CRTC still gets a sensible frame. Character and line counts of the previous
// line/frame locate the leading border.
reg [7:0] hc, hc_tot, hc_act;
reg [9:0] vl, vl_tot, vl_act;
reg       hde_o, vde_o;
wire [7:0] hb_w = w80 ? 8'd8 : 8'd4;
wire       h_vis = h_de | (hc < hc_act + hb_w) | (hc + hb_w >= hc_tot);
wire       v_vis = v_de | (vl < vl_act + 10'd16) | (vl + 10'd16 >= vl_tot);
wire       hv0 = border_en & h_vis;
wire       vv0 = border_en & v_vis;

always @(posedge clk) begin
  if (ph == 5'd1) begin
    hde_o <= h_de;
    hc <= hc + 8'd1;
    if (h_de & ~hde_o) begin hc_tot <= hc; hc <= 8'd1; end
    if (~h_de & hde_o) hc_act <= hc;
    if (h_de & ~hde_o) begin
      vde_o <= v_de;
      vl <= vl + 10'd1;
      if (v_de & ~vde_o) begin vl_tot <= vl; vl <= 10'd1; end
      if (~v_de & vde_o) vl_act <= vl;
    end
  end
end

// --- stage 1: address -------------------------------------------------------
wire [13:0] off = hireso ? ({11'd0, (is ? ra[3:1] : ra[2:0])} << (w80 ? 11 : 10)) : 14'd0;
wire [13:0] va  = ma + off;
assign cram_addr = vram_addr[13:0] - 14'h0400;

reg [4:0] ra1;
reg       hde1, vde1, hs1, vs1, cur1, hv1, vv1;
always @(posedge clk) begin
  if (ph == 5'd1) begin
    vram_addr <= (va < 14'h0400) ? {2'b01, va} : {2'b00, va};
    ra1 <= ra; hde1 <= h_de; vde1 <= v_de; hs1 <= hsync_in; vs1 <= vsync_in;
    cur1 <= cursor_in; hv1 <= hv0; vv1 <= vv0;
  end
end

// --- stage 2: byte latch ----------------------------------------------------
reg [7:0] code2;
reg [5:0] col2;
reg [4:0] ra2;
reg       hde2, vde2, hs2, vs2, cur2, hv2, vv2;
always @(posedge clk) begin
  if (ph == 5'd3) begin
    code2 <= vram_q;
    col2  <= ig_ok ? cram_q : {1'b0, cram_q[4:0]};
    ra2 <= ra1; hde2 <= hde1; vde2 <= vde1; hs2 <= hs1; vs2 <= vs1; cur2 <= cur1;
    hv2 <= hv1; vv2 <= vv1;
  end
end

wire [3:0] fr = ra2[3:0];
assign font_addr = is ? ({code2, 4'd0} | {8'd0, code2[7] ? fr : {fr[3:1], 1'b0}})
                      : ((code2[7] ? {1'b0, code2[6:0], 4'd1} : {code2, 4'd0}) | {8'd0, fr[2:0], 1'b0});
assign ig_addr = {code2, is ? ra2[3:1] : ra2[2:0]};

// --- stage 3: pattern -------------------------------------------------------
wire [1:0] gk = is ? ra2[3:2] : ra2[2:1];      // normal-mode block row
wire       gl = code2[3'd4 + {1'b0, gk}];
wire       gr = code2[{1'b0, gk}];

reg [7:0] pat;
reg [2:0] fgc, bgc;
reg       ig, white;
reg [7:0] pb, pr, pg;
reg       hde3, vde3, hs3, vs3, hv3, vv3;
always @(posedge clk) begin
  if (ph == 5'd5) begin
    hde3 <= hde2; vde3 <= vde2; hs3 <= hs2; vs3 <= vs2; hv3 <= hv2; vv3 <= vv2;
    ig <= 1'b0; white <= 1'b0;
    pb <= ig_b; pr <= ig_r; pg <= ig_g;
    begin : sel
      reg [2:0] f, b;
      reg       swap;
      f = col2[2:0];
      b = bg;
      swap = (col2[5:3] == 3'b001);            // reverse, not IG
      case (col2[5:4])
        2'b10, 2'b11: begin
          if (ig_dis) white <= 1'b1;
          else        ig <= 1'b1;
          pat <= 8'h00;
          swap = 1'b0;
        end
        2'b01: pat <= hireso ? code2 : {{4{gl}}, {4{gr}}};
        default: pat <= font_q;
      endcase
      if (swap ^ (cur2 & ~col2[5])) begin
        fgc <= b; bgc <= f;
      end else begin
        fgc <= f; bgc <= b;
      end
    end
  end
end

// --- pixel out --------------------------------------------------------------
wire [4:0] o = ph - 5'd6;
wire [2:0] dot = w80 ? o[3:1] : o[4:2];
wire [2:0] di = 3'd7 - dot;
wire [2:0] igc = {pg[di], pr[di], pb[di]};

reg [2:0] pix;
always @(*) begin
  if (white)   pix = 3'd7;
  else if (ig) pix = (igc != 3'd0) ? igc : bgc;
  else         pix = pat[di] ? fgc : bgc;
end

always @(posedge clk) begin
  if (~cnt[0]) begin
    hs <= hs3; vs <= vs3;
    if (border_en) begin
      hb <= ~hv3;
      vb <= ~vv3;
    end else begin
      hb <= ~hde3; vb <= ~vde3;
    end
    if (hde3 & vde3) begin
      red   <= {8{pix[1]}};
      green <= {8{pix[2]}};
      blue  <= {8{pix[0]}};
    end else if (hv3 & vv3) begin
      red   <= {8{bg[1]}};
      green <= {8{bg[2]}};
      blue  <= {8{bg[0]}};
    end else begin
      red <= 8'd0; green <= 8'd0; blue <= 8'd0;
    end
  end
end

endmodule
