// Hitachi Basic Master Level 3 (MB-6890/6891/6892) and MB-S1: CPU, memory
// map, system I/O and video glue.
//
// clk is 32.256 MHz, the machine's crystal. Everything else is an enable off
// the 5-bit phase counter `cnt`: the 6809 gets E = clk/32 (1.008 MHz) or, on
// the S1 at 2 MHz, clk/16; the CRTC gets 1.008 MHz (40 col) or 2.016 MHz
// (80 col, and always in S1 mode); pixels are clk/2.
//
// Level 3 behaviour follows EmuB-6892 (memory.cpp, memory_readio.h/writeio.h,
// keyboard.cpp, timer.cpp); the S1 follows EmuB-S1 as digested in
// ref/notes/mbs1-implementation-spec.md. Every CPU access goes through a
// 20-bit physical address `pa`:
//   Level 3 models and S1 B mode: pa = $F0000 | a, then Level 3 banking.
//   S1 A mode: the MMU (16 x 4 KB map registers at $FE00, system-mode pages
//   $E000 -> $84000 and $F000 -> $EF000). User mode is not implemented: S1
//   BASIC never enters it.
module core (
  input             clk,
  input             reset,
  input             mark5,        // Mark 5: $FFE8 bank register and IG
  input             s1,           // MB-S1
  input             s1_amode,     // S1 SYSTEM switch: 1 = A (S1 BASIC), 0 = B (Level 3)
  input             interlace,    // generate both interlace fields
  input             fdc_en,       // MP-1802 floppy card fitted
  input             ram_hi,       // RAM at $8000-$FFFF (RAM3/RAM4 cards, Mark 5)
  input             border,       // show the border in the background colour
  input             psg_en,       // 6-voice PSG card fitted
  input       [7:0] joy,          // joystick on PSG 0 port A, active low

  // boot0.rom download: $00000 Level 3 BASIC, $06000 MP-1802 ROM, $08000 font,
  // $10000 S1 BASIC (64 KB, PA $E0000-$EFFFF)
  input             rom_wr,
  input      [17:0] rom_addr,
  input       [7:0] rom_data,

  input     [127:0] keys,
  input             break_key,
  input       [7:0] dipsw,

  // cassette (byte level, through the ACIA)
  input             rx_strobe,
  input       [7:0] rx_data,
  output            motor,
  output            baud1200,

  output            beep,
  output     [10:0] psg_snd,

  // MP-1802 disk images (hps_io block devices 0 and 1)
  input       [1:0] img_mounted,
  input             img_readonly,
  input      [63:0] img_size,
  output     [31:0] sd_lba [2],
  output      [1:0] sd_rd,
  output      [1:0] sd_wr,
  input       [1:0] sd_ack,
  input       [8:0] sd_buff_addr,
  input       [7:0] sd_buff_dout,
  output      [7:0] sd_buff_din [2],
  input             sd_buff_wr,

  output      [7:0] red,
  output      [7:0] green,
  output      [7:0] blue,
  output            hs,
  output            vs,
  output            hb,
  output            vb,
  output            field,        // odd interlace field (VGA_F1)
  output            ce_pix
);

// ---------------------------------------------------------------------------
// Mode, latched at reset (the S1's SYSTEM switch is read at reset)
reg amode;                       // S1 A mode
reg clk2m;                       // S1 CPU at 2.016 MHz ($FFEB bit 1)
wire mk5 = mark5 | s1;           // the S1 has the Mark 5 extras in B mode
wire ramhi = ram_hi | s1;

// ---------------------------------------------------------------------------
// Clock phases
reg [4:0] cnt;
always @(posedge clk) cnt <= cnt + 5'd1;

wire [19:0] pa;
wire        slow_io;             // S1 at 2 MHz: common I/O is a 1 MHz access
reg   [5:0] cyc;                 // clocks since the last end of bus cycle
wire        fast = s1 & clk2m;

wire fallE = ~fast ? (cnt == 5'd0)
           : slow_io ? (cnt == 5'd0 && cyc >= 6'd31)
           : (cnt[3:0] == 4'd0);
wire fallQ = (~fast | slow_io) ? (cnt == 5'd24) : (cnt[3:0] == 4'd12);

always @(posedge clk) cyc <= fallE ? 6'd0 : (cyc == 6'd63 ? cyc : cyc + 6'd1);

// ---------------------------------------------------------------------------
// CPU
wire [15:0] cpu_addr;
wire  [7:0] cpu_dout;
reg   [7:0] cpu_din;
wire        cpu_rw;
wire        cpu_irq, cpu_firq, cpu_nmi;

mc6809is cpu (
  .CLK(clk),
  .fallE_en(fallE),
  .fallQ_en(fallQ),
  .D(cpu_din),
  .DOut(cpu_dout),
  .ADDR(cpu_addr),
  .RnW(cpu_rw),
  .BS(), .BA(),
  .nIRQ(~cpu_irq),
  .nFIRQ(~cpu_firq),
  .nNMI(~cpu_nmi),
  .AVMA(), .BUSY(), .LIC(),
  .nHALT(1'b1),
  .nRESET(~reset),
  .nDMABREQ(1'b1),
  .RegData()
);

wire wr = fallE & ~cpu_rw & ~reset;     // end of a write cycle
wire rd = fallE &  cpu_rw & ~reset;     // end of a read cycle (side effects)
wire [15:0] ca = cpu_addr;

// ---------------------------------------------------------------------------
// MMU (S1 A mode)
reg [7:0] map [0:15];
assign pa = ~amode            ? {4'hF, ca} :
            ca[15:13] == 3'b111 ? (ca[12] ? {8'hEF, ca[11:0]} : {8'h84, ca[11:0]}) :
                                  {map[ca[15:12]], ca[11:0]};

wire [15:0] a = pa[15:0];               // Level 3 view of the address
wire l3p    = pa[19:16] == 4'hF;        // Level 3 path (always, except S1 A mode)

// common I/O at $xFF00-$xFFEF, x = E or F
wire io     = (pa[19:8] == 12'hFFF || pa[19:8] == 12'hEFF) && pa[7:4] != 4'hF;
wire sysio  = io && pa[7:6] == 2'b11 && pa[5:4] != 2'b11;   // $FFC0-$FFEF
wire s1io   = amode && pa[19:8] == 12'hEFE;                 // $EFE00-$EFEFF
wire vram_a = l3p && a >= 16'h0400 && a < 16'h4400;

// S1 physical windows
wire gwin   = amode && pa[19:14] == 6'b101100;              // $B0000-$B3FFF
wire gplg   = amode && pa[19:14] == 6'b101101;              // $B4000-$B7FFF G
wire gplb   = amode && pa[19:14] == 6'b101110;              // $B8000-$BBFFF B
wire txt    = amode && pa[19:12] == 8'hBC;
wire igwin  = amode && (pa[19:12] == 8'hBD || pa[19:12] == 8'hBE);
wire sysram = amode && pa[19:14] >= 6'h21 && pa[19:14] <= 6'h23; // $84000-$8FFFF
wire s1rom  = amode && pa[19:16] == 4'hE;

assign slow_io = io || (s1io && (pa[7:0] == 8'h25 || pa[7:0] == 8'h26 || pa[7:0] == 8'h27));

// ---------------------------------------------------------------------------
// Bank registers
reg  [7:0] pia_ora, pia_ddra, pia_cra, pia_orb, pia_ddrb, pia_crb;
wire [7:0] pia_pa = (pia_ora & pia_ddra) | ~pia_ddra;
wire [7:0] bank1 = pia_pa & 8'hce;      // EmuB mem_bank_reg1
reg  [7:0] bank2;                       // $FFE8 (Mark 5)

reg  [7:0] ig_mode, ig_en;
wire       ig_enable = mk5 & ig_mode[0];

reg rom_sel;
always @(*) begin
  rom_sel = 1'b0;
  if (l3p) begin
    if (a[15:13] == 3'b101)      rom_sel = ~(~bank1[1] & bank1[6]);    // $A000
    else if (a[15:13] == 3'b110) rom_sel = ~(~bank1[2] & bank1[7]);    // $C000
    else if (a[15:12] == 4'hE)   rom_sel = ~(~bank1[3] & bank1[7]);    // $E000
    else if (a[15:12] == 4'hF) begin
      if (a[11:4] == 8'hFF)      rom_sel = ~bank2[1];                  // $FFF0 vectors
      else                       rom_sel = ~bank2[0];                  // $F000-$FEFF
    end
  end
end

// ---------------------------------------------------------------------------
// S1 registers used by the memory logic
reg  [7:0] bmsk;                 // $FE20 BMSK-COLOR: [7] BMSC, [2:0] G R B
reg  [3:0] aplane;               // $FE21 ACTIVE-PLANE: [3] DW, [2:0] G R B
reg  [7:0] dpage;                // $FE23
reg  [2:0] smode;                // $FE24
reg  [7:0] creg_b, creg_r, creg_g; // $FE25-$FE27
reg [31:0] palette;              // $FE28-$FE2F
reg  [7:0] color_reg;

// ---------------------------------------------------------------------------
// Memories
wire  [7:0] ram_q, rom_q, vram_q, s1rom_q, vg_q, vb_q;
wire  [7:0] t_q, igb_q, igr_q, igg_q, font_cq;
wire  [6:0] c_q;
wire  [7:0] vgv_q, vbv_q, tv_q;
wire  [6:0] cv_q;
wire [15:0] vram_addr;
wire [13:0] vcram_addr;
wire [11:0] font_addr_l3, font_addr_s1;
wire  [7:0] font_q;
wire [10:0] ig_vaddr_l3, ig_vaddr_s1;
wire  [7:0] ig_b, ig_r, ig_g;
wire [10:0] s1_taddr;
wire [13:0] s1_gaddr;

wire ig_wr_l3 = ig_enable && l3p && a[15:11] == 5'b10100;   // $A000-$A7FF
wire ig_wr = (ig_wr_l3 || igwin) & wr;

// Graphic window plane writes (spec 2.6)
wire [2:0] apl = aplane[2:0];           // active planes G R B
function [7:0] plane_wdata(input [7:0] d, input [7:0] creg, input bm);
  if (bmsk[7])         plane_wdata = (bm ? d : 8'h00) | (creg & ~d);
  else if (aplane[3])  plane_wdata = creg;
  else                 plane_wdata = d;
endfunction

// main RAM: Level 3 RAM = S1 R plane ($0000-$3FFF) + S1 system RAM
wire [15:0] ram_a = (l3p | sysram) ? a : {2'b00, pa[13:0]};
wire ram_we = wr & ((l3p & ~ig_wr_l3 & (ramhi | ~a[15])) | sysram | (gwin & apl[1]));
wire [7:0] ram_d = gwin ? plane_wdata(cpu_dout, creg_r, bmsk[1]) : cpu_dout;

dpram #(16, 8) ram (
  .clk(clk),
  .a_addr(ram_a), .a_din(ram_d), .a_we(ram_we), .a_dout(ram_q),
  // in A mode port B serves the S1 renderer's R plane
  .b_addr(amode ? {2'b00, s1_gaddr} : vram_addr), .b_din(8'd0), .b_we(1'b0), .b_dout(vram_q)
);

// G plane; its low 6 bits are also the Level 3 colour RAM ($0400-$43FF)
wire [13:0] cram_a = a[13:0] - 14'h0400;
wire l3cram_we = wr & vram_a & ~amode;
wire [13:0] vg_a = (gwin | gplg) ? pa[13:0] : cram_a;
wire vg_we = l3cram_we | (wr & gplg) | (wr & gwin & apl[2]);
wire [7:0] vg_d = l3cram_we ? {2'b00, color_reg[5:0]} :
                  gwin ? plane_wdata(cpu_dout, creg_g, bmsk[2]) : cpu_dout;

dpram #(14, 8) vgram (
  .clk(clk),
  .a_addr(vg_a), .a_din(vg_d), .a_we(vg_we), .a_dout(vg_q),
  .b_addr(amode ? s1_gaddr : vcram_addr), .b_din(8'd0), .b_we(1'b0), .b_dout(vgv_q)
);

// B plane (S1)
wire vb_we = (wr & gplb) | (wr & gwin & apl[0]);
dpram #(14, 8) vbram (
  .clk(clk),
  .a_addr(pa[13:0]), .a_din(gwin ? plane_wdata(cpu_dout, creg_b, bmsk[0]) : cpu_dout),
  .a_we(vb_we), .a_dout(vb_q),
  .b_addr(s1_gaddr), .b_din(8'd0), .b_we(1'b0), .b_dout(vbv_q)
);

// S1 text RAM and its 7-bit colour RAM
dpram #(11, 8) tram (
  .clk(clk),
  .a_addr(pa[10:0]), .a_din(cpu_dout), .a_we(wr & txt), .a_dout(t_q),
  .b_addr(s1_taddr), .b_din(8'd0), .b_we(1'b0), .b_dout(tv_q)
);
dpram #(11, 7) tcram (
  .clk(clk),
  .a_addr(pa[10:0]), .a_din(color_reg[6:0]), .a_we(wr & txt), .a_dout(c_q),
  .b_addr(s1_taddr), .b_din(7'd0), .b_we(1'b0), .b_dout(cv_q)
);

// Level 3 BASIC ROM, 24 KB at $A000-$FFFF (boot0.rom $0000-$5FFF)
wire [14:0] rom_cpu_a = a[14:0] - 15'h2000;
dpram #(15, 8) rom (
  .clk(clk),
  .a_addr(rom_wr ? rom_addr[14:0] : rom_cpu_a),
  .a_din(rom_data), .a_we(rom_wr && rom_addr[17:15] == 3'b000), .a_dout(rom_q),
  .b_addr(15'd0), .b_din(8'd0), .b_we(1'b0), .b_dout()
);

// S1 BASIC ROM, 64 KB at PA $E0000-$EFFFF (boot0.rom $10000-$1FFFF)
dpram #(16, 8) s1rom_m (
  .clk(clk),
  .a_addr(rom_wr ? rom_addr[15:0] : pa[15:0]),
  .a_din(rom_data), .a_we(rom_wr && rom_addr[17:16] == 2'b01), .a_dout(s1rom_q),
  .b_addr(16'd0), .b_din(8'd0), .b_we(1'b0), .b_dout()
);

// MP-1802 boot ROM, 2 KB (boot0.rom $6000-$67FF), seen at $F800-$FEFF
// in place of BASIC while the card is fitted [MP1802Tech p.41-44].
wire [7:0] fdcrom_q;
dpram #(11, 8) fdcrom (
  .clk(clk),
  .a_addr(rom_wr ? rom_addr[10:0] : a[10:0]), .a_din(rom_data),
  .a_we(rom_wr && rom_addr[17:11] == 7'b0001100), .a_dout(fdcrom_q),
  .b_addr(11'd0), .b_din(8'd0), .b_we(1'b0), .b_dout()
);
wire fdcrom_sel = fdc_en && l3p && a[15:11] == 5'b11111 && a[10:8] != 3'b111;

// Character generator, 4 KB (boot0.rom $8000-$8FFF); the S1 also reads it
// through $BDxxx with IGEN = 7.
dpram #(12, 8) font (
  .clk(clk),
  .a_addr(rom_wr ? rom_addr[11:0] : pa[11:0]), .a_din(rom_data),
  .a_we(rom_wr && rom_addr[17:12] == 6'b001000), .a_dout(font_cq),
  .b_addr(amode ? font_addr_s1 : font_addr_l3), .b_din(8'd0), .b_we(1'b0), .b_dout(font_q)
);

// IG RAM: three 2 KB planes (B, R, G). Level 3: written through $A000-$A7FF
// while $FFE9 bit 0 is set, to the planes enabled in $FFEA. S1: also the
// $BD000-$BEFFF window, no $FFE9 gate.
wire [10:0] ig_vaddr = amode ? ig_vaddr_s1 : ig_vaddr_l3;
dpram #(11, 8) igb (
  .clk(clk),
  .a_addr(pa[10:0]), .a_din(cpu_dout), .a_we(ig_wr & ig_en[0]), .a_dout(igb_q),
  .b_addr(ig_vaddr), .b_din(8'd0), .b_we(1'b0), .b_dout(ig_b)
);
dpram #(11, 8) igr (
  .clk(clk),
  .a_addr(pa[10:0]), .a_din(cpu_dout), .a_we(ig_wr & ig_en[1]), .a_dout(igr_q),
  .b_addr(ig_vaddr), .b_din(8'd0), .b_we(1'b0), .b_dout(ig_r)
);
dpram #(11, 8) igg (
  .clk(clk),
  .a_addr(pa[10:0]), .a_din(cpu_dout), .a_we(ig_wr & ig_en[2]), .a_dout(igg_q),
  .b_addr(ig_vaddr), .b_din(8'd0), .b_we(1'b0), .b_dout(ig_g)
);

// ---------------------------------------------------------------------------
// CRTC
wire        cclk_en;
wire  [7:0] crtc_dout;
wire [13:0] crtc_ma;
wire  [4:0] crtc_ra;
wire        crtc_hde, crtc_vde, crtc_hs, crtc_vs, crtc_cur, crtc_vmode;
wire        crtc_cs = sysio && (a[5:0] == 6'h06 || a[5:0] == 6'h07);

crtc6845 crtc (
  .clk(clk), .reset(reset), .cclk_en(cclk_en), .interlace(interlace),
  .cur_half(amode & ~smode[2]),
  .cs(crtc_cs), .we(wr), .rs(a[0]), .din(cpu_dout), .dout(crtc_dout),
  .ma(crtc_ma), .ra(crtc_ra), .de(), .hde(crtc_hde), .vde(crtc_vde),
  .hsync(crtc_hs), .vsync(crtc_vs), .cursor(crtc_cur), .vmode(crtc_vmode), .field(field)
);

// ---------------------------------------------------------------------------
// System registers
reg  [7:0] mode_sel;
reg        interlace_sel;
reg        remote;
reg        music;
reg        time_mask, fast_mask, t2s;
reg  [3:0] baud_sel;

assign motor    = remote;
assign baud1200 = baud_sel[1:0] == 2'b01;
assign beep     = music;

wire [7:0] l3_red, l3_green, l3_blue, s1_red, s1_green, s1_blue;
wire       l3_hs, l3_vs, l3_hb, l3_vb, s1_hs, s1_vs, s1_hb, s1_vb;

video video (
  .clk(clk), .reset(reset), .cnt(cnt),
  .w80(mode_sel[7] | amode), .hireso(~mode_sel[6]), .bg(mode_sel[2:0]),
  .is(interlace_sel), .ig_dis(ig_mode[0]), .ig_ok(mk5), .border_en(border),
  .cclk_en(cclk_en),
  .ma(crtc_ma), .ra(crtc_ra), .h_de(crtc_hde), .v_de(crtc_vde),
  .hsync_in(crtc_hs), .vsync_in(crtc_vs), .cursor_in(crtc_cur), .vmode(crtc_vmode),
  .vram_addr(vram_addr), .vram_q(vram_q),
  .cram_addr(vcram_addr), .cram_q(vgv_q[5:0]),
  .font_addr(font_addr_l3), .font_q(font_q),
  .ig_addr(ig_vaddr_l3), .ig_b(ig_b), .ig_r(ig_r), .ig_g(ig_g),
  .red(l3_red), .green(l3_green), .blue(l3_blue),
  .hs(l3_hs), .vs(l3_vs), .hb(l3_hb), .vb(l3_vb), .ce_pix(ce_pix)
);

s1video s1video (
  .clk(clk), .cnt(cnt),
  .smode(smode), .dpage(dpage), .palette(palette), .bd(mode_sel[3:0]),
  .border_en(border), .is(interlace_sel),
  .ma(crtc_ma), .ra(crtc_ra), .h_de(crtc_hde), .v_de(crtc_vde),
  .hsync_in(crtc_hs), .vsync_in(crtc_vs), .cursor_in(crtc_cur),
  .t_addr(s1_taddr), .t_q(tv_q), .c_q(cv_q),
  .g_addr(s1_gaddr), .gr_q(vram_q), .gg_q(vgv_q), .gb_q(vbv_q),
  .font_addr(font_addr_s1), .font_q(font_q),
  .ig_addr(ig_vaddr_s1), .ig_b(ig_b), .ig_r(ig_r), .ig_g(ig_g),
  .red(s1_red), .green(s1_green), .blue(s1_blue),
  .hs(s1_hs), .vs(s1_vs), .hb(s1_hb), .vb(s1_vb)
);

assign red   = amode ? s1_red   : l3_red;
assign green = amode ? s1_green : l3_green;
assign blue  = amode ? s1_blue  : l3_blue;
assign hs    = amode ? s1_hs    : l3_hs;
assign vs    = amode ? s1_vs    : l3_vs;
assign hb    = amode ? s1_hb    : l3_hb;
assign vb    = amode ? s1_vb    : l3_vb;

// ---------------------------------------------------------------------------
// ACIA
wire [7:0] acia_dout;
wire       acia_irq;
wire       acia_cs = sysio && a[5:1] == 5'b00010;     // $FFC4-$FFC5

acia6850 acia (
  .clk(clk), .reset(reset),
  .cs(acia_cs), .rs(a[0]), .we(wr), .re(rd), .din(cpu_dout), .dout(acia_dout),
  .rx_strobe(rx_strobe), .rx_data(rx_data),
  .tx_strobe(), .tx_data(), .cr_out(),
  .irq(acia_irq)
);

// ---------------------------------------------------------------------------
// MP-1802 floppy card at $FF00-$FF07
wire [7:0] fdc_dout;
wire       fdc_nmi;
wire       fdc_cs = fdc_en && io && a[7:3] == 5'b00000;

mp1802 fdc (
  .clk(clk), .reset(reset), .ce(cnt == 5'd16),
  .cs(fdc_cs), .a(a[2:0]), .we(wr), .re(rd), .din(cpu_dout), .dout(fdc_dout),
  .nmi(fdc_nmi),
  .img_mounted(img_mounted), .img_readonly(img_readonly), .img_size(img_size),
  .sd_lba(sd_lba), .sd_rd(sd_rd), .sd_wr(sd_wr), .sd_ack(sd_ack),
  .sd_buff_addr(sd_buff_addr), .sd_buff_dout(sd_buff_dout), .sd_buff_din(sd_buff_din),
  .sd_buff_wr(sd_buff_wr)
);

// ---------------------------------------------------------------------------
// 6-voice PSG card at $FF30-$FF33
wire [7:0] psg_dout;
wire       psg_cs = psg_en && io && a[7:2] == 6'b001100;
wire [10:0] psg6_snd;

psg6 psg (
  .clk(clk), .reset(reset), .ce_psg(cnt == 5'd8),
  .cs(psg_cs), .a(a[1:0]), .we(wr), .din(cpu_dout), .dout(psg_dout),
  .joy_a(joy), .sound(psg6_snd)
);

// S1 built-in PSG at $FFE4 (data) / $FFE5 (register), 1.008 MHz
reg  [3:0] s1psg_reg;
wire [7:0] s1psg_dout;
wire [9:0] s1psg_snd;
wire       s1psg_wr = s1 && wr && sysio && a[5:0] == 6'h24;

jt49 s1psg (
  .rst_n(~reset), .clk(clk), .clk_en(cnt == 5'd8),
  .addr(s1psg_reg), .cs_n(~s1psg_wr), .wr_n(~s1psg_wr), .din(cpu_dout), .sel(1'b1),
  .dout(s1psg_dout), .sound(s1psg_snd), .A(), .B(), .C(), .sample(),
  .IOA_in(8'hff), .IOA_out(), .IOA_oe(), .IOB_in(8'hff), .IOB_out(), .IOB_oe()
);

assign psg_snd = psg6_snd + (s1 ? {1'b0, s1psg_snd} : 11'd0);

// ---------------------------------------------------------------------------
// Keyboard scanner: a 7-bit code counter stepped by CRTC HSYNC (Level 3) or a
// fixed 15.75 kHz tick (S1), two steps per code (EmuB keyboard.cpp
// update_keyboard). It stops on a pressed key until $FFE0 is read. After the
// last key is released it reports $FF once.
reg  [7:0] kb_mode;
reg  [7:0] kb_cnt;
reg  [7:0] kb_code;
reg  [1:0] kb_pressed;
reg        kb_irq;
reg        kb_nmi_flag;          // $FFC8 bit 7
reg        kb_nmi;
reg        hs_old, vs_old, brk_old;
reg        timer_flag, fast_flag, fast_ph;

// S1 fixed-rate ticks (EmuB-S1 keyboard.cpp / timer.cpp)
reg [10:0] kb_div;               // clk/2048 = 15.75 kHz
reg [19:0] t60_div;              // clk/537600 = 60 Hz
reg [14:0] t1k_div;              // clk/32768 = 1.016 ms
wire kb_tick  = s1 ? (kb_div == 11'd0) : (crtc_hs & ~hs_old);
wire t60_tick = s1 ? (t60_div == 20'd0) : (crtc_vs & ~vs_old);
wire t1k_tick = t1k_div == 15'd0;

always @(posedge clk) begin
  kb_div  <= kb_div + 11'd1;
  t60_div <= (t60_div == 20'd537599) ? 20'd0 : t60_div + 20'd1;
  t1k_div <= t1k_div + 15'd1;
end

// $FFD1 trace counter (EmuB memory.cpp): a write arms it, the next CPU read
// starts a 16-cycle count, then NMI is held until the following read. Used
// by the monitor's single-step.
reg  [1:0] trace_state;          // 0 idle, 1 armed, 2 counting, 3 NMI out
reg  [4:0] trace_cnt;
reg        trace_nmi;

wire [6:0] kb_scan = kb_cnt[7:1] & (kb_mode[3] ? 7'h07 : 7'h7f);
wire       kb_rd   = sysio && (s1 ? a[5:0] == 6'h20 : a[5:3] == 3'b100);

// ---------------------------------------------------------------------------
// Register writes and read side effects
integer i;
always @(posedge clk) begin
  if (reset) begin
    amode <= s1 & s1_amode;
    clk2m <= s1 & s1_amode;
    mode_sel <= 8'h00;
    interlace_sel <= 1'b0;
    remote <= 1'b0;
    music <= 1'b0;
    time_mask <= s1 & s1_amode;
    fast_mask <= 1'b1;
    t2s <= 1'b0;
    baud_sel <= 4'd0;
    color_reg <= 8'h07;
    pia_ora <= 8'h00; pia_ddra <= 8'h00; pia_cra <= 8'h00;
    pia_orb <= 8'h00; pia_ddrb <= 8'h00; pia_crb <= 8'h00;
    bank2 <= 8'h00;
    ig_mode <= 8'h00; ig_en <= 8'h00;
    kb_mode <= 8'h00; kb_cnt <= 8'h00; kb_code <= 8'h00; kb_pressed <= 2'd0;
    kb_irq <= 1'b0; kb_nmi_flag <= 1'b0; kb_nmi <= 1'b0;
    timer_flag <= 1'b0; fast_flag <= 1'b0; fast_ph <= 1'b0;
    trace_state <= 2'd0; trace_nmi <= 1'b0;
    bmsk <= 8'h00; aplane <= 4'h0; dpage <= 8'h00; smode <= 3'd0;
    creg_b <= 8'h00; creg_r <= 8'h00; creg_g <= 8'h00; palette <= 32'h76543210;
    s1psg_reg <= 4'd0;
  end else begin
    // ---- trace counter
    case (trace_state)
      2'd1: if (rd) begin trace_state <= 2'd2; trace_cnt <= 5'd16; end
      2'd2: if (fallE) begin
              if (trace_cnt == 5'd1) begin trace_nmi <= 1'b1; trace_state <= 2'd3; end
              trace_cnt <= trace_cnt - 5'd1;
            end
      2'd3: if (rd) begin trace_nmi <= 1'b0; trace_state <= 2'd0; end
      default: ;
    endcase

    // ---- CPU writes
    if (wr) begin
      if (sysio) case (a[5:0])
        6'h00: if (pia_cra[2]) pia_ora <= cpu_dout; else pia_ddra <= cpu_dout;
        6'h01: pia_cra <= {pia_cra[7:6], cpu_dout[5:0]};
        6'h02: if (pia_crb[2]) pia_orb <= cpu_dout; else pia_ddrb <= cpu_dout;
        6'h03: pia_crb <= {pia_crb[7:6], cpu_dout[5:0]};
        6'h10: mode_sel <= cpu_dout;
        6'h11: trace_state <= 2'd1;
        6'h12: remote <= cpu_dout[7];
        6'h13: music <= cpu_dout[7];
        6'h14: begin
                 time_mask <= cpu_dout[7];
                 if (cpu_dout[7]) timer_flag <= 1'b0;
                 if (s1) begin
                   fast_mask <= cpu_dout[1];
                   t2s <= cpu_dout[0];
                   if (cpu_dout[1]) fast_flag <= 1'b0;
                 end
               end
        6'h16: interlace_sel <= cpu_dout[3];
        6'h17: baud_sel <= s1 ? cpu_dout[3:0] : {3'b000, cpu_dout[0]};
        6'h18, 6'h19, 6'h1a, 6'h1b, 6'h1c, 6'h1d, 6'h1e, 6'h1f:
               // the S1 decodes $FFD8 alone ($FFD9 TRQ, $FFDC-$FFDF mouse)
               if (~s1) color_reg <= cpu_dout & 8'hbf;
               else if (a[2:0] == 3'd0) color_reg <= cpu_dout;
        6'h20, 6'h21, 6'h22, 6'h23, 6'h24, 6'h25, 6'h26, 6'h27:
               if (~s1 || a[2:0] == 3'd0) begin
                 kb_mode <= cpu_dout;
                 kb_irq <= cpu_dout[6] & kb_code[7];
                 if (kb_nmi_flag & ~cpu_dout[7]) kb_nmi <= 1'b0;
               end else if (a[2:0] == 3'd5) s1psg_reg <= cpu_dout[3:0];
        6'h28: if (mk5) bank2 <= cpu_dout;
        6'h29: if (mk5) ig_mode <= cpu_dout;
        6'h2a: if (mk5) ig_en <= {5'd0, cpu_dout[2:0]};
        6'h2b: if (s1) clk2m <= cpu_dout[1];
        default: ;
      endcase
      if (s1io) begin
        if (pa[7:4] == 4'h0) map[pa[3:0]] <= cpu_dout;
        case (pa[7:0])
          8'h20: bmsk <= cpu_dout & 8'h87;
          8'h21: aplane <= cpu_dout[3:0];
          8'h23: dpage <= cpu_dout;
          8'h24: smode <= cpu_dout[2:0];
          8'h25: creg_b <= cpu_dout;
          8'h26: creg_r <= cpu_dout;
          8'h27: creg_g <= cpu_dout;
          default: ;
        endcase
        if (pa[7:3] == 5'b00101) palette[{pa[2:0], 2'b00} +: 4] <= cpu_dout[3:0];
      end
    end

    // ---- CPU read side effects
    if (rd) begin
      // reading VRAM / S1 text RAM loads the colour register unless MK is set
      if (vram_a & ~amode & ~color_reg[7]) color_reg <= {2'b00, vg_q[5:0]};
      if (txt & ~color_reg[7]) color_reg <= {1'b0, c_q};
      // graphic window read in DW mode latches all active planes
      if (gwin & aplane[3]) begin
        if (apl[2]) creg_g <= vg_q;
        if (apl[1]) creg_r <= ram_q;
        if (apl[0]) creg_b <= vb_q;
      end
      if (sysio) case (a[5:0])
        6'h08: if (~break_key) begin kb_nmi_flag <= 1'b0; kb_nmi <= 1'b0; end
        6'h0a: begin timer_flag <= 1'b0; fast_flag <= 1'b0; end
        default: ;
      endcase
      if (kb_rd) begin
        kb_code[7] <= 1'b0;
        kb_irq <= 1'b0;
      end
    end

    // ---- timers: FIRQ at 60 Hz unless masked (+ the S1's 1/2 ms timer)
    vs_old <= crtc_vs;
    if (t60_tick & ~time_mask) timer_flag <= 1'b1;
    if (s1 & t1k_tick) begin
      fast_ph <= ~fast_ph;
      if (~fast_mask & (t2s | fast_ph)) fast_flag <= 1'b1;
    end

    // ---- BREAK key
    brk_old <= break_key;
    if (break_key & ~brk_old & ~kb_nmi_flag) begin
      kb_nmi_flag <= 1'b1;
      if (kb_mode[7]) kb_nmi <= 1'b1;
    end

    // ---- keyboard scan
    hs_old <= crtc_hs;
    if (kb_tick & ~kb_code[7] & ~(rd & kb_rd)) begin
      kb_cnt <= kb_cnt + 8'd1;
      if (~kb_cnt[0]) begin
        kb_code <= {1'b0, kb_scan};
      end else if (kb_scan == 7'h7f) begin
        if (kb_pressed == 2'd1) begin
          kb_code <= 8'hff;
          if (kb_mode[6]) kb_irq <= 1'b1;
        end else begin
          kb_code <= 8'h7f;
        end
        if (kb_pressed != 2'd0) kb_pressed <= kb_pressed - 2'd1;
      end else if (kb_scan < 7'h70 && keys[kb_scan]) begin
        kb_code <= {1'b1, kb_scan};
        kb_pressed <= 2'd2;
        if (kb_mode[6]) kb_irq <= 1'b1;
      end else begin
        kb_code <= {1'b0, kb_scan};
      end
    end
  end
end

// map registers power up as 0 (EmuB memory.cpp:215; not cleared on reset)
initial for (i = 0; i < 16; i = i + 1) map[i] = 8'h00;

// ---------------------------------------------------------------------------
// Interrupts
assign cpu_irq  = kb_irq | acia_irq;
assign cpu_firq = timer_flag | fast_flag;
assign cpu_nmi  = kb_nmi | trace_nmi | fdc_nmi;

// ---------------------------------------------------------------------------
// Read mux
reg [7:0] io_dout;
always @(*) begin
  io_dout = s1rom_q;               // unimplemented S1 I/O reads the ROM underneath
  if (~amode | ~s1rom) io_dout = 8'hff;
  if (fdc_cs) io_dout = fdc_dout;
  if (psg_cs) io_dout = psg_dout;
  if (sysio) case (a[5:0])
    6'h00: io_dout = pia_cra[2] ? pia_pa : pia_ddra;
    6'h01: io_dout = pia_cra;
    6'h02: io_dout = pia_crb[2] ? ((pia_orb & pia_ddrb) | ~pia_ddrb) : pia_ddrb;
    6'h03: io_dout = pia_crb;
    6'h04, 6'h05: io_dout = acia_dout;
    6'h06, 6'h07: io_dout = crtc_dout;
    6'h08: io_dout = {kb_nmi_flag, 7'h7f};
    6'h09: io_dout = s1 ? 8'h03 : dipsw;
    6'h0a: io_dout = {timer_flag, fast_flag & s1, 6'h00};
    6'h0b: io_dout = 8'h7f;                      // light pen flag
    6'h18, 6'h19, 6'h1a, 6'h1b, 6'h1c, 6'h1d, 6'h1e, 6'h1f:
           if (~s1)                   io_dout = (color_reg & 8'hbf) | 8'h40;
           else if (a[2:0] == 3'd0)   io_dout = color_reg;
           else if (a[2:0] == 3'd1)   io_dout = 8'h0f;      // $FFD9 TRQ-SEL
           else                       io_dout = 8'hff;      // mouse absent
    6'h20, 6'h21, 6'h22, 6'h23, 6'h24, 6'h25, 6'h26, 6'h27:
           if (~s1)               io_dout = kb_code;
           else case (a[2:0])
             3'd0: io_dout = kb_code;
             3'd1: io_dout = 8'h01;              // JIS keyboard
             3'd4: io_dout = s1psg_dout;
             default: io_dout = 8'hff;
           endcase
    6'h2b: io_dout = s1 ? {5'b00000, 1'b1, clk2m, amode} : 8'hff;
    default: ;
  endcase
  if (s1io) begin
    if (pa[7:4] == 4'h0) io_dout = map[pa[3:0]];
    case (pa[7:0])
      8'h25: io_dout = creg_b;
      8'h26: io_dout = creg_r;
      8'h27: io_dout = creg_g;
      default: ;
    endcase
  end
end

// graphic window read: the first active plane in the order G, R, B
wire [7:0] gwin_q = ~aplane[3] ? (apl[2] ? vg_q : apl[1] ? ram_q : apl[0] ? vb_q : 8'h00)
                               : (apl[2] ? vg_q : apl[1] ? ram_q : apl[0] ? vb_q : 8'h00);
wire [7:0] igwin_q = (ig_en[2:0] == 3'b111) ? font_cq :
                     ig_en[2] ? igg_q : ig_en[1] ? igr_q : ig_en[0] ? igb_q : 8'h00;

always @(*) begin
  if (io | s1io)                    cpu_din = io_dout;
  else if (l3p) begin
    if (rom_sel)                    cpu_din = fdcrom_sel ? fdcrom_q : rom_q;
    else if (a[15] & ~ramhi)        cpu_din = 8'hff;   // stock MB-6890: nothing there
    else                            cpu_din = ram_q;
  end
  else if (txt)                     cpu_din = t_q;
  else if (gwin)                    cpu_din = gwin_q;
  else if (igwin)                   cpu_din = igwin_q;
  else if (sysram)                  cpu_din = ram_q;
  else if (gplg)                    cpu_din = vg_q;
  else if (gplb)                    cpu_din = vb_q;
  else if (s1rom)                   cpu_din = s1rom_q;
  else                              cpu_din = 8'hff;
end

endmodule
