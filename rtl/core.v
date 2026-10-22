// Hitachi Basic Master Level 3 (MB-6890/6891/6892): CPU, memory map, system
// I/O and video glue.
//
// clk is 32.256 MHz, the machine's crystal. Everything else is an enable off
// the 5-bit phase counter `cnt`: the 6809 gets E = clk/32 (1.008 MHz), the
// CRTC gets 1.008 MHz (40 col) or 2.016 MHz (80 col), pixels are clk/2.
//
// Behaviour follows EmuB-6892 (memory.cpp, memory_readio.h/writeio.h,
// keyboard.cpp, timer.cpp) unless a comment says otherwise; see
// ref/notes/hardware-from-manuals.md for the service-manual view.
module core (
  input             clk,
  input             reset,
  input             mark5,        // Mark 5: $FFE8 bank register and IG
  input             interlace,    // generate both interlace fields
  input             fdc_en,       // MP-1802 floppy card fitted
  input             ram_hi,       // RAM at $8000-$FFFF (RAM3/RAM4 cards, Mark 5)
  input             border,       // show the border in the background colour

  // boot ROM download (boot0.rom: BASIC at 0, font at $8000)
  input             rom_wr,
  input      [15:0] rom_addr,
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
// Clock phases
reg [4:0] cnt;
always @(posedge clk) cnt <= cnt + 5'd1;

wire fallE = cnt == 5'd0;
wire fallQ = cnt == 5'd24;

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
wire [15:0] a = cpu_addr;

wire io     = a[15:8] == 8'hFF && a[7:4] != 4'hF;   // $FF00-$FFEF
wire sysio  = a[15:6] == 10'b1111111111 && a[5:4] != 2'b11; // $FFC0-$FFEF
wire vram_a = a >= 16'h0400 && a < 16'h4400;

// ---------------------------------------------------------------------------
// Bank registers
reg  [7:0] pia_ora, pia_ddra, pia_cra, pia_orb, pia_ddrb, pia_crb;
wire [7:0] pia_pa = (pia_ora & pia_ddra) | ~pia_ddra;
wire [7:0] bank1 = pia_pa & 8'hce;      // EmuB mem_bank_reg1
reg  [7:0] bank2;                       // $FFE8 (Mark 5)

reg  [7:0] ig_mode, ig_en;
wire       ig_enable = mark5 & ig_mode[0];

reg rom_sel;
always @(*) begin
  rom_sel = 1'b0;
  if (a[15:13] == 3'b101)      rom_sel = ~(~bank1[1] & bank1[6]);    // $A000
  else if (a[15:13] == 3'b110) rom_sel = ~(~bank1[2] & bank1[7]);    // $C000
  else if (a[15:12] == 4'hE)   rom_sel = ~(~bank1[3] & bank1[7]);    // $E000
  else if (a[15:12] == 4'hF) begin
    if (a[11:4] == 8'hFF)      rom_sel = ~bank2[1];                  // $FFF0 vectors
    else                       rom_sel = ~bank2[0];                  // $F000-$FEFF
  end
end

// ---------------------------------------------------------------------------
// Memories
wire  [7:0] ram_q, rom_q, vram_q;
wire  [5:0] cram_q, vcram_q;
wire [15:0] vram_addr;
wire [13:0] vcram_addr;
wire [11:0] font_addr;
wire  [7:0] font_q;
wire [10:0] ig_vaddr;
wire  [7:0] ig_b, ig_r, ig_g;

wire ig_wr = ig_enable && a[15:11] == 5'b10100;      // $A000-$A7FF

dpram #(16, 8) ram (
  .clk(clk),
  .a_addr(a), .a_din(cpu_dout), .a_we(wr & ~ig_wr & (ram_hi | ~a[15])), .a_dout(ram_q),
  .b_addr(vram_addr), .b_din(8'd0), .b_we(1'b0), .b_dout(vram_q)
);

reg  [7:0] color_reg;
wire [13:0] cram_a = a[13:0] - 14'h0400;

dpram #(14, 6) cram (
  .clk(clk),
  .a_addr(cram_a), .a_din(color_reg[5:0]), .a_we(wr & vram_a), .a_dout(cram_q),
  .b_addr(vcram_addr), .b_din(6'd0), .b_we(1'b0), .b_dout(vcram_q)
);

// BASIC ROM, 24 KB at $A000-$FFFF (boot0.rom $0000-$5FFF)
wire [14:0] rom_cpu_a = a[14:0] - 15'h2000;
dpram #(15, 8) rom (
  .clk(clk),
  .a_addr(rom_wr ? rom_addr[14:0] : rom_cpu_a),
  .a_din(rom_data), .a_we(rom_wr && rom_addr[15] == 1'b0), .a_dout(rom_q),
  .b_addr(15'd0), .b_din(8'd0), .b_we(1'b0), .b_dout()
);

// MP-1802 boot ROM, 2 KB (boot0.rom $6000-$67FF), seen at $F800-$FEFF
// in place of BASIC while the card is fitted [MP1802Tech p.41-44].
wire [7:0] fdcrom_q;
dpram #(11, 8) fdcrom (
  .clk(clk),
  .a_addr(rom_wr ? rom_addr[10:0] : a[10:0]), .a_din(rom_data),
  .a_we(rom_wr && rom_addr[15:11] == 5'b01100), .a_dout(fdcrom_q),
  .b_addr(11'd0), .b_din(8'd0), .b_we(1'b0), .b_dout()
);
wire fdcrom_sel = fdc_en && a[15:11] == 5'b11111 && a[10:8] != 3'b111;

// Character generator, 4 KB (boot0.rom $8000-$8FFF)
dpram #(12, 8) font (
  .clk(clk),
  .a_addr(rom_addr[11:0]), .a_din(rom_data),
  .a_we(rom_wr && rom_addr[15:12] == 4'h8), .a_dout(),
  .b_addr(font_addr), .b_din(8'd0), .b_we(1'b0), .b_dout(font_q)
);

// IG RAM: three 2 KB planes (B, R, G), written through $A000-$A7FF while
// $FFE9 bit 0 is set, to the planes enabled in $FFEA.
dpram #(11, 8) igb (
  .clk(clk),
  .a_addr(a[10:0]), .a_din(cpu_dout), .a_we(wr & ig_wr & ig_en[0]), .a_dout(),
  .b_addr(ig_vaddr), .b_din(8'd0), .b_we(1'b0), .b_dout(ig_b)
);
dpram #(11, 8) igr (
  .clk(clk),
  .a_addr(a[10:0]), .a_din(cpu_dout), .a_we(wr & ig_wr & ig_en[1]), .a_dout(),
  .b_addr(ig_vaddr), .b_din(8'd0), .b_we(1'b0), .b_dout(ig_r)
);
dpram #(11, 8) igg (
  .clk(clk),
  .a_addr(a[10:0]), .a_din(cpu_dout), .a_we(wr & ig_wr & ig_en[2]), .a_dout(),
  .b_addr(ig_vaddr), .b_din(8'd0), .b_we(1'b0), .b_dout(ig_g)
);

// ---------------------------------------------------------------------------
// CRTC
wire        cclk_en;
wire  [7:0] crtc_dout;
wire [13:0] crtc_ma;
wire  [4:0] crtc_ra;
wire        crtc_hde, crtc_vde, crtc_hs, crtc_vs, crtc_cur, crtc_vmode;
wire        crtc_cs = sysio && a[5:0] == 6'h06 || sysio && a[5:0] == 6'h07;

crtc6845 crtc (
  .clk(clk), .reset(reset), .cclk_en(cclk_en), .interlace(interlace),
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
reg        time_mask;
reg        baud_sel;

assign motor    = remote;
assign baud1200 = baud_sel;
assign beep     = music;

video video (
  .clk(clk), .reset(reset), .cnt(cnt),
  .w80(mode_sel[7]), .hireso(~mode_sel[6]), .bg(mode_sel[2:0]),
  .is(interlace_sel), .ig_dis(ig_mode[0]), .ig_ok(mark5), .border_en(border),
  .cclk_en(cclk_en),
  .ma(crtc_ma), .ra(crtc_ra), .h_de(crtc_hde), .v_de(crtc_vde),
  .hsync_in(crtc_hs), .vsync_in(crtc_vs), .cursor_in(crtc_cur), .vmode(crtc_vmode),
  .vram_addr(vram_addr), .vram_q(vram_q),
  .cram_addr(vcram_addr), .cram_q(vcram_q),
  .font_addr(font_addr), .font_q(font_q),
  .ig_addr(ig_vaddr), .ig_b(ig_b), .ig_r(ig_r), .ig_g(ig_g),
  .red(red), .green(green), .blue(blue),
  .hs(hs), .vs(vs), .hb(hb), .vb(vb), .ce_pix(ce_pix)
);

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
wire       fdc_cs = fdc_en && a[15:3] == 13'b1111111100000;

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
// Keyboard scanner: a 7-bit code counter stepped by CRTC HSYNC, two steps per
// code (EmuB keyboard.cpp update_keyboard). It stops on a pressed key until
// $FFE0 is read. After the last key is released it reports $FF once.
reg  [7:0] kb_mode;
reg  [7:0] kb_cnt;
reg  [7:0] kb_code;
reg  [1:0] kb_pressed;
reg        kb_irq;
reg        kb_nmi_flag;          // $FFC8 bit 7
reg        kb_nmi;
reg        hs_old, vs_old, brk_old;
reg        timer_flag;

// $FFD1 trace counter (EmuB memory.cpp): a write arms it, the next CPU read
// starts a 16-cycle count, then NMI is held until the following read. Used
// by the monitor's single-step.
reg  [1:0] trace_state;          // 0 idle, 1 armed, 2 counting, 3 NMI out
reg  [4:0] trace_cnt;
reg        trace_nmi;

wire [6:0] kb_scan = kb_cnt[7:1] & (kb_mode[3] ? 7'h07 : 7'h7f);

// ---------------------------------------------------------------------------
// Register writes and read side effects
always @(posedge clk) begin
  if (reset) begin
    mode_sel <= 8'h00;
    interlace_sel <= 1'b0;
    remote <= 1'b0;
    music <= 1'b0;
    time_mask <= 1'b0;
    baud_sel <= 1'b0;
    color_reg <= 8'h07;
    pia_ora <= 8'h00; pia_ddra <= 8'h00; pia_cra <= 8'h00;
    pia_orb <= 8'h00; pia_ddrb <= 8'h00; pia_crb <= 8'h00;
    bank2 <= 8'h00;
    ig_mode <= 8'h00; ig_en <= 8'h00;
    kb_mode <= 8'h00; kb_cnt <= 8'h00; kb_code <= 8'h00; kb_pressed <= 2'd0;
    kb_irq <= 1'b0; kb_nmi_flag <= 1'b0; kb_nmi <= 1'b0;
    timer_flag <= 1'b0;
    trace_state <= 2'd0; trace_nmi <= 1'b0;
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
      if (vram_a) ; // colour RAM written by the cram port
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
               end
        6'h16: interlace_sel <= cpu_dout[3];
        6'h17: baud_sel <= cpu_dout[0];
        6'h18, 6'h19, 6'h1a, 6'h1b, 6'h1c, 6'h1d, 6'h1e, 6'h1f:
               color_reg <= cpu_dout & 8'hbf;
        6'h20, 6'h21, 6'h22, 6'h23, 6'h24, 6'h25, 6'h26, 6'h27: begin
               kb_mode <= cpu_dout;
               kb_irq <= cpu_dout[6] & kb_code[7];
               if (kb_nmi_flag & ~cpu_dout[7]) kb_nmi <= 1'b0;
             end
        6'h28: if (mark5) bank2 <= cpu_dout;
        6'h29: if (mark5) ig_mode <= cpu_dout;
        6'h2a: if (mark5) ig_en <= {5'd0, cpu_dout[2:0]};
        default: ;
      endcase
    end

    // ---- CPU read side effects
    if (rd) begin
      // reading VRAM loads the colour register unless MK (bit 7) is set
      if (vram_a & ~color_reg[7]) color_reg <= {2'b00, cram_q};
      if (sysio) case (a[5:0])
        6'h08: if (~break_key) begin kb_nmi_flag <= 1'b0; kb_nmi <= 1'b0; end
        6'h0a: timer_flag <= 1'b0;
        6'h20, 6'h21, 6'h22, 6'h23, 6'h24, 6'h25, 6'h26, 6'h27: begin
               kb_code[7] <= 1'b0;
               kb_irq <= 1'b0;
             end
        default: ;
      endcase
    end

    // ---- timer: FIRQ on every CRTC VSYNC unless masked
    vs_old <= crtc_vs;
    if (crtc_vs & ~vs_old & ~time_mask) timer_flag <= 1'b1;

    // ---- BREAK key
    brk_old <= break_key;
    if (break_key & ~brk_old & ~kb_nmi_flag) begin
      kb_nmi_flag <= 1'b1;
      if (kb_mode[7]) kb_nmi <= 1'b1;
    end

    // ---- keyboard scan on CRTC HSYNC
    hs_old <= crtc_hs;
    if (crtc_hs & ~hs_old & ~kb_code[7] & ~(rd & sysio & a[5:3] == 3'b100)) begin
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

// ---------------------------------------------------------------------------
// Interrupts
assign cpu_irq  = kb_irq | acia_irq;
assign cpu_firq = timer_flag;
assign cpu_nmi  = kb_nmi | trace_nmi | fdc_nmi;

// ---------------------------------------------------------------------------
// Read mux
reg [7:0] io_dout;
always @(*) begin
  io_dout = 8'hff;
  if (fdc_cs) io_dout = fdc_dout;
  if (sysio) case (a[5:0])
    6'h00: io_dout = pia_cra[2] ? pia_pa : pia_ddra;
    6'h01: io_dout = pia_cra;
    6'h02: io_dout = pia_crb[2] ? ((pia_orb & pia_ddrb) | ~pia_ddrb) : pia_ddrb;
    6'h03: io_dout = pia_crb;
    6'h04, 6'h05: io_dout = acia_dout;
    6'h06, 6'h07: io_dout = crtc_dout;
    6'h08: io_dout = {kb_nmi_flag, 7'h7f};
    6'h09: io_dout = dipsw;
    6'h0a: io_dout = {timer_flag, 7'h00};
    6'h0b: io_dout = 8'h7f;                      // light pen flag
    6'h18, 6'h19, 6'h1a, 6'h1b, 6'h1c, 6'h1d, 6'h1e, 6'h1f:
           io_dout = (color_reg & 8'hbf) | 8'h40;
    6'h20, 6'h21, 6'h22, 6'h23, 6'h24, 6'h25, 6'h26, 6'h27:
           io_dout = kb_code;
    default: io_dout = 8'hff;
  endcase
end

always @(*) begin
  if (io)           cpu_din = io_dout;
  else if (rom_sel) cpu_din = fdcrom_sel ? fdcrom_q : rom_q;
  else if (a[15] & ~ram_hi) cpu_din = 8'hff;   // stock MB-6890: nothing there
  else              cpu_din = ram_q;
end

endmodule
