// MB-S1 A-mode (S1 mode) display: text RAM + 7-bit colour RAM over three
// graphic planes, through an 8-entry palette. EmuB-S1 display.cpp /
// displaysub.h; see ref/notes/mbs1-implementation-spec.md section 5.
//
// The CRTC always runs at 2.016 MHz (80 characters per line, 8 pixels each at
// 16.128 MHz). 40-column text and 320-dot graphics are made by spanning one
// character / byte over two CRTC characters ($FE24 chooses, not the CRTC).
//
// Not yet: 640x400 (needs interlace), 64-colour mode.
//
// Phase (cnt[3:0]) as video.v's 80-column pipeline:
//   1 addresses registered   3 bytes latched   5 pattern latched
//   even cnt: pixel register updated   odd cnt: CE_PIXEL
module s1video (
  input             clk,
  input       [4:0] cnt,

  input       [2:0] smode,        // $FE24: [2] 80-col text, [1:0] graphic mode
  input       [7:0] dpage,        // $FE23: [7:5] G R B display enables, [1] graphic page, [0] text page
  input      [31:0] palette,      // $FE28-$FE2F, 4 bits each {I,G,R,B}, entry 0 in [3:0]
  input       [3:0] bd,           // $FFD0[3:0] border {I,G,R,B}
  input             border_en,
  input             is,           // $FFD6 bit 3

  input      [13:0] ma,
  input       [4:0] ra,
  input             h_de,
  input             v_de,
  input             hsync_in,
  input             vsync_in,
  input             cursor_in,

  output reg [10:0] t_addr,
  input       [7:0] t_q,
  input       [6:0] c_q,
  output reg [13:0] g_addr,
  input       [7:0] gr_q,
  input       [7:0] gg_q,
  input       [7:0] gb_q,
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
  output reg        vb
);

wire [3:0] ph = cnt[3:0];
wire       w80 = smode[2];
wire       gw  = smode[1];
wire [1:0] gm  = smode[1:0];

// --- border window (as video.v: 64 px / 16 lines round the display) ---------
reg [7:0] hc, hc_tot, hc_act;
reg [9:0] vl, vl_tot, vl_act;
reg       hde_o, vde_o;
wire      h_vis = h_de | (hc < hc_act + 8'd8) | (hc + 8'd8 >= hc_tot);
wire      v_vis = v_de | (vl < vl_act + 10'd16) | (vl + 10'd16 >= vl_tot);

always @(posedge clk) begin
  if (ph == 4'd1) begin
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

// --- stage 1: addresses -----------------------------------------------------
wire [13:0] g_off  = {11'd0, (is ? ra[3:1] : ra[2:0])} << (gw ? 11 : 10);
wire [13:0] g_base = gw ? ma : {1'b0, ma[13:1]};
wire [13:0] g_page = (gw || gm == 2'b01) ? 14'd0 : {dpage[1], 13'd0};

reg [4:0] ra1;
reg       half1, hde1, vde1, hs1, vs1, cur1, hv1, vv1;
always @(posedge clk) begin
  if (ph == 4'd1) begin
    t_addr <= w80 ? ma[10:0] : {dpage[0], ma[10:1]};
    g_addr <= g_base + g_off + g_page;
    ra1 <= ra; half1 <= ma[0];
    hde1 <= h_de; vde1 <= v_de; hs1 <= hsync_in; vs1 <= vsync_in; cur1 <= cursor_in;
    hv1 <= border_en & h_vis; vv1 <= border_en & v_vis;
  end
end

// --- stage 2: bytes ---------------------------------------------------------
reg [7:0] code2, gr2, gg2, gb2;
reg [6:0] cr2;
reg [4:0] ra2;
reg       half2, hde2, vde2, hs2, vs2, cur2, hv2, vv2;
always @(posedge clk) begin
  if (ph == 4'd3) begin
    code2 <= t_q; cr2 <= c_q;
    gr2 <= gr_q; gg2 <= gg_q; gb2 <= gb_q;
    ra2 <= ra1; half2 <= half1;
    hde2 <= hde1; vde2 <= vde1; hs2 <= hs1; vs2 <= vs1; cur2 <= cur1;
    hv2 <= hv1; vv2 <= vv1;
  end
end

wire [3:0] fr = ra2[3:0];
assign font_addr = is ? ({code2, 4'd0} | {8'd0, code2[7] ? fr : {fr[3:1], 1'b0}})
                      : ((code2[7] ? {1'b0, code2[6:0], 4'd1} : {code2, 4'd0}) | {8'd0, fr[2:0], 1'b0});
assign ig_addr = {code2, is ? ra2[3:1] : ra2[2:0]};

// --- stage 3: pattern -------------------------------------------------------
reg [7:0] pat, pb, prr, pg, gr3, gg3, gb3;
reg [6:0] cr3;
reg       half3, hde3, vde3, hs3, vs3, cur3, hv3, vv3;
always @(posedge clk) begin
  if (ph == 4'd5) begin
    pat <= font_q; pb <= ig_b; prr <= ig_r; pg <= ig_g;
    gr3 <= gr2; gg3 <= gg2; gb3 <= gb2; cr3 <= cr2;
    half3 <= half2;
    hde3 <= hde2; vde3 <= vde2; hs3 <= hs2; vs3 <= vs2; cur3 <= cur2;
    hv3 <= hv2; vv3 <= vv2;
  end
end

// --- pixel ------------------------------------------------------------------
wire [3:0] o = ph - 4'd6;
wire [2:0] p = o[3:1];                       // pixel 0-7 within the CRTC char
// bit index: full width, or the doubled half of a 40-col / 320-dot byte
wire [2:0] bt = 3'd7 - p;
wire [2:0] bh = half3 ? (3'd3 - {1'b0, p[2:1]}) : (3'd7 - {1'b0, p[2:1]});
wire [2:0] tb = w80 ? bt : bh;
wire [2:0] gb_i = gw ? bt : bh;

wire       ig_t  = cr3[5];
wire [2:0] igc0  = {pg[tb], prr[tb], pb[tb]};
wire [2:0] igc1  = cr3[3] ? ~igc0 : igc0;
wire [2:0] igc   = cur3 ? cr3[2:0] : igc1;
wire       fbit  = pat[tb] ^ cur3 ^ cr3[3];
wire [2:0] tcol  = ig_t ? igc : (fbit ? cr3[2:0] : 3'd0);
wire       ton   = ig_t ? (igc != 3'd0) : fbit;
wire [2:0] gcol  = {gg3[gb_i], gr3[gb_i], gb3[gb_i]} & dpage[7:5];
wire [1:0] sel   = {cr3[6], cr3[4]};

reg [2:0] c;
always @(*) begin
  if (sel == 2'b00 || dpage[7:5] == 3'd0) c = tcol;
  else if (sel == 2'b01)                 c = gcol;
  else if (sel == 2'b10)                 c = ton ? tcol : gcol;
  else                                   c = (gcol != 3'd0) ? gcol : tcol;
end

wire [3:0] pe = palette[{c, 2'b00} +: 4];

function [7:0] lvl(input on, input i);
  lvl = on ? (i ? 8'hff : 8'haf) : 8'h00;
endfunction

always @(posedge clk) begin
  if (~cnt[0]) begin
    hs <= hs3; vs <= vs3;
    hb <= border_en ? ~hv3 : ~hde3;
    vb <= border_en ? ~vv3 : ~vde3;
    if (hde3 & vde3) begin
      red <= lvl(pe[1], pe[3]); green <= lvl(pe[2], pe[3]); blue <= lvl(pe[0], pe[3]);
    end else if (hv3 & vv3) begin
      red <= lvl(bd[1], bd[3]); green <= lvl(bd[2], bd[3]); blue <= lvl(bd[0], bd[3]);
    end else begin
      red <= 8'd0; green <= 8'd0; blue <= 8'd0;
    end
  end
end

endmodule
