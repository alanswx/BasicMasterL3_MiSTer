// MP-1802 5" 2D floppy card (MB8866) for the Level 3.
//
// Registers [MP1802Tech p.39-48]; EmuB floppy.cpp:
//   $FF00-$FF03  FDC status/command, track, sector, data. The card has no
//                bus inverters, so the MB8866's inverted data bus reaches the
//                CPU inverted; the core below is a normal WD1793, so both
//                directions are inverted here.
//   $FF04-$FF07  write: b6 NMI mask, b5 double density, b4 side, b3 motor,
//                b1-0 drive. read: b7 = /DRQ, b0 = /IRQ, other bits 1.
//   FDC INTRQ -> NMI unless masked; DRQ is polled.
//
// Glue (the access latch, per-drive controller instances with the sector
// register mirrored, mount-scan bookkeeping) follows FM-7_MiSTer's FDC.v,
// which uses the same wd1793.sv. Two drives; drives 2 and 3 are empty.
module mp1802 (
  input             clk,
  input             reset,
  input             ce,           // 1.008 MHz controller clock enable

  input             cs,           // $FF00-$FF07
  input       [2:0] a,
  input             we,           // one-clk strobes at the end of the bus cycle
  input             re,
  input       [7:0] din,
  output      [7:0] dout,
  output            nmi,

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
  input             sd_buff_wr
);

wire prepare0, prepare1;
wire ce_wd = ce | prepare0 | prepare1;     // run the mount scan flat out

// ---------------------------------------------------------------------------
// Board register $FF04
reg  [7:0] ctl;
wire [1:0] drv  = ctl[1:0];
wire       side = ctl[4];

// ---------------------------------------------------------------------------
// Accesses are latched and held until a controller ce consumes them (the core
// only samples rd/wr on ce). A second write landing before the core has seen
// the first one's strobe go low is parked (FDC.v's gap_done logic).
wire core_sel = cs & ~a[2];

reg [1:0] acc_addr;
reg [7:0] acc_din;
reg       acc_wr, acc_rd;
reg [1:0] pnd_addr;
reg [7:0] pnd_din;
reg       pnd, gap_done;

always @(posedge clk) begin
  if (reset) begin
    acc_wr <= 1'b0; acc_rd <= 1'b0; pnd <= 1'b0; gap_done <= 1'b1;
    acc_addr <= 2'd0;
  end else begin
    if (core_sel & we) begin
      if (gap_done & ~acc_wr & ~pnd) begin
        acc_addr <= a[1:0]; acc_din <= ~din; acc_wr <= 1'b1; gap_done <= 1'b0;
      end else begin
        pnd_addr <= a[1:0]; pnd_din <= ~din; pnd <= 1'b1;
      end
    end else if (ce_wd) begin
      if (acc_wr) acc_wr <= 1'b0;
      else begin
        gap_done <= 1'b1;
        if (pnd) begin
          acc_addr <= pnd_addr; acc_din <= pnd_din; acc_wr <= 1'b1;
          pnd <= 1'b0; gap_done <= 1'b0;
        end
      end
    end
    // a read is acknowledged at the end of its bus cycle, after the CPU has
    // taken the byte
    if (core_sel & re) begin
      acc_addr <= a[1:0];
      acc_rd <= 1'b1;
    end else if (ce_wd) acc_rd <= 1'b0;
  end
end

// While the CPU is reading a register the core's read mux follows the bus;
// otherwise it stays on the latched access.
wire [1:0] core_addr = (acc_wr | acc_rd | ~core_sel) ? acc_addr : a[1:0];

always @(posedge clk) begin
  if (reset) ctl <= 8'h00;
  else if (cs & a[2] & we) ctl <= din;
end

// ---------------------------------------------------------------------------
// Drives
wire d0 = drv == 2'd0;
wire d1 = drv == 2'd1;
wire sector_reg_wr = acc_wr & (acc_addr == 2'd2);

wire ready0, ready1;
wire drq0, drq1, intrq0, intrq1;
wire [7:0] core_dout0, core_dout1;
wire fmt_wp0, fmt_wp1;

reg [1:0] mounted, scanning, prepare_seen, wp_r, old_img_mounted;
integer i;
always @(posedge clk) begin
  old_img_mounted <= img_mounted;
  for (i = 0; i < 2; i = i + 1) begin
    if (img_mounted[i]) begin
      mounted[i]      <= |img_size;
      scanning[i]     <= |img_size;
      prepare_seen[i] <= 1'b0;
      if (~old_img_mounted[i]) wp_r[i] <= img_readonly;
    end else begin
      if ((i == 0) ? prepare0 : prepare1) prepare_seen[i] <= 1'b1;
      if (prepare_seen[i] && ~((i == 0) ? prepare0 : prepare1)) begin
        scanning[i] <= 1'b0;
        prepare_seen[i] <= 1'b0;
      end
    end
  end
end

assign ready0 = mounted[0] & ~scanning[0];
assign ready1 = mounted[1] & ~scanning[1];

wd1793 #(.RWMODE(1), .EDSK(1)) fdc0 (
  .clk_sys(clk), .ce(ce_wd), .reset(reset), .io_en(1'b1),
  .rd(acc_rd & d0), .wr((acc_wr & d0) | sector_reg_wr),
  .addr(core_addr), .din(acc_din), .dout(core_dout0),
  .drq(drq0), .intrq(intrq0), .busy(),
  .wp(wp_r[0] | fmt_wp0), .fmt_wp(fmt_wp0),
  .size_code(3'd1), .layout(1'b0), .side(side), .ready(ready0),
  .img_mounted(img_mounted[0]), .img_size(img_size[19:0]), .img_size_id(img_size[23:0]),
  .disk_index(3'd0), .prepare(prepare0),
  .sd_lba(sd_lba[0]), .sd_rd(sd_rd[0]), .sd_wr(sd_wr[0]), .sd_ack(sd_ack[0]),
  .sd_buff_addr(sd_buff_addr), .sd_buff_dout(sd_buff_dout), .sd_buff_din(sd_buff_din[0]),
  .sd_buff_wr(sd_buff_wr),
  .input_active(1'b0), .input_addr(20'd0), .input_data(8'd0), .input_wr(1'b0),
  .buff_addr(), .buff_read(), .buff_din(8'd0)
);

wd1793 #(.RWMODE(1), .EDSK(1)) fdc1 (
  .clk_sys(clk), .ce(ce_wd), .reset(reset), .io_en(1'b1),
  .rd(acc_rd & d1), .wr((acc_wr & d1) | sector_reg_wr),
  .addr(core_addr), .din(acc_din), .dout(core_dout1),
  .drq(drq1), .intrq(intrq1), .busy(),
  .wp(wp_r[1] | fmt_wp1), .fmt_wp(fmt_wp1),
  .size_code(3'd1), .layout(1'b0), .side(side), .ready(ready1),
  .img_mounted(img_mounted[1]), .img_size(img_size[19:0]), .img_size_id(img_size[23:0]),
  .disk_index(3'd0), .prepare(prepare1),
  .sd_lba(sd_lba[1]), .sd_rd(sd_rd[1]), .sd_wr(sd_wr[1]), .sd_ack(sd_ack[1]),
  .sd_buff_addr(sd_buff_addr), .sd_buff_dout(sd_buff_dout), .sd_buff_din(sd_buff_din[1]),
  .sd_buff_wr(sd_buff_wr),
  .input_active(1'b0), .input_addr(20'd0), .input_data(8'd0), .input_wr(1'b0),
  .buff_addr(), .buff_read(), .buff_din(8'd0)
);

// An absent drive reads "not ready, track 0".
wire [7:0] core_dout = d0 ? core_dout0 : d1 ? core_dout1 :
                       (core_addr == 2'd0 ? 8'h84 : 8'h00);
wire drq   = d0 ? drq0   : d1 ? drq1   : 1'b0;
wire intrq = d0 ? intrq0 : d1 ? intrq1 : 1'b0;

assign dout = a[2] ? {~drq, 6'b111111, ~intrq} : ~core_dout;
assign nmi  = intrq & ~ctl[6];

endmodule
