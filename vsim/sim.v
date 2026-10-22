`timescale 1ns / 1ps
//============================================================================
//  Simulation top (Verilator) for the Basic Master Level 3 core.
//
//  Stands in for BasicMasterL3.sv: same wiring, with hps_io and the PLL
//  replaced by things sim_main.cpp drives. clk_sys is the machine's 32.256 MHz
//  crystal here too, so every rate in the RTL is the real one.
//  Keep it in sync with BasicMasterL3.sv.
//============================================================================

module emu (
	input             clk_sys,
	input             reset,

	// PS/2 keyboard: [7:0] code, [8] extended, [9] pressed, [10] toggles per event
	input      [10:0] ps2_key,

	input       [2:0] tape_speed,
	input             mark5,
	input             symbolic,
	input             interlace,
	input       [7:0] dipsw,

	// HPS file transfer: index 0 = boot0.rom, 1 = tape (.l3)
	input             ioctl_download,
	input             ioctl_wr,
	input      [24:0] ioctl_addr,
	input       [7:0] ioctl_dout,
	input       [7:0] ioctl_index,
	output            ioctl_wait,

	// floppy block devices (SimBlockDevice): per-drive bit vectors as it expects
	input             fdc_en,
	input      [15:0] img_mounted,
	input             img_readonly,
	input      [63:0] img_size,
	output     [31:0] sd_lba [2],
	output     [15:0] sd_rd,
	output     [15:0] sd_wr,
	input      [15:0] sd_ack,
	input       [8:0] sd_buff_addr,
	input       [7:0] sd_buff_dout,
	output      [7:0] sd_buff_din [2],
	input             sd_buff_wr,

	output      [7:0] VGA_R,
	output      [7:0] VGA_G,
	output      [7:0] VGA_B,
	output            VGA_HS,
	output            VGA_VS,
	output            VGA_HB,
	output            VGA_VB,
	output            CE_PIXEL,

	output     [15:0] AUDIO_L,
	output     [15:0] AUDIO_R,

	// --- debug taps for sim_main.cpp -----------------------------------
	output     [15:0] dbg_cpu_addr,
	output      [7:0] dbg_cpu_din,
	output      [7:0] dbg_cpu_dout,
	output            dbg_cpu_rw,
	output            dbg_cpu_ce,      // 1 for one clk_sys tick at the end of each CPU cycle
	output     [15:0] dbg_cpu_pc,
	output            dbg_tape_motor,
	output     [16:0] dbg_tape_pos,
	output            dbg_tape_strobe,
	output      [7:0] dbg_tape_byte,
	output      [7:0] dbg_kb_code,
	output      [7:0] dbg_kb_mode,
	output      [7:0] dbg_kb_cnt,
	output      [7:0] dbg_cc
);

assign ioctl_wait = 1'b0;

wire rom_download  = ioctl_download && ioctl_index == 8'd0;
wire tape_download = ioctl_download && ioctl_index == 8'd1;
wire core_reset = reset | rom_download;

//////////////////////////////  TAPE  /////////////////////////////////////////
reg [16:0] tape_size;
reg        tape_rewind;
always @(posedge clk_sys) begin
	reg old_download;
	old_download <= tape_download;
	tape_rewind <= 1'b0;
	if (tape_download & ioctl_wr) tape_size <= ioctl_addr[16:0] + 17'd1;
	if (old_download & ~tape_download) tape_rewind <= 1'b1;
end

wire [15:0] tape_addr;
wire  [7:0] tape_q;
wire        tape_strobe;
wire  [7:0] tape_byte;
wire        motor, baud1200;

dpram #(16, 8) tape_buffer (
	.clk(clk_sys),
	.a_addr(ioctl_addr[15:0]), .a_din(ioctl_dout), .a_we(tape_download & ioctl_wr), .a_dout(),
	.b_addr(tape_addr), .b_din(8'd0), .b_we(1'b0), .b_dout(tape_q)
);

tape tape (
	.clk(clk_sys), .reset(reset), .rewind(tape_rewind), .size(tape_size),
	.motor(motor), .baud1200(baud1200), .speed(tape_speed),
	.buf_addr(tape_addr), .buf_q(tape_q),
	.rx_strobe(tape_strobe), .rx_data(tape_byte), .active()
);

//////////////////////////////  CORE  ////////////////////////////////////////
wire [127:0] keys;
wire         break_key;
wire         beep;

keyboard keyboard (
	.clk(clk_sys), .reset(reset), .symbolic(symbolic), .ps2_key(ps2_key),
	.keys(keys), .break_key(break_key)
);

wire [1:0] sd_rd2, sd_wr2;
assign sd_rd = {14'd0, sd_rd2};
assign sd_wr = {14'd0, sd_wr2};

core core (
	.clk(clk_sys), .reset(core_reset), .mark5(mark5), .interlace(interlace),
	.rom_wr(rom_download & ioctl_wr), .rom_addr(ioctl_addr[15:0]), .rom_data(ioctl_dout),
	.keys(keys), .break_key(break_key), .dipsw(dipsw),
	.rx_strobe(tape_strobe), .rx_data(tape_byte), .motor(motor), .baud1200(baud1200),
	.beep(beep),
	.fdc_en(fdc_en),
	.img_mounted(img_mounted[1:0]), .img_readonly(img_readonly), .img_size(img_size),
	.sd_lba(sd_lba), .sd_rd(sd_rd2), .sd_wr(sd_wr2), .sd_ack(sd_ack[1:0]),
	.sd_buff_addr(sd_buff_addr), .sd_buff_dout(sd_buff_dout), .sd_buff_din(sd_buff_din),
	.sd_buff_wr(sd_buff_wr),
	.red(VGA_R), .green(VGA_G), .blue(VGA_B),
	.hs(VGA_HS), .vs(VGA_VS), .hb(VGA_HB), .vb(VGA_VB), .field(), .ce_pix(CE_PIXEL)
);

assign AUDIO_L = {1'b0, beep, 14'd0};
assign AUDIO_R = AUDIO_L;

//////////////////////////////  DEBUG TAPS  //////////////////////////////////
assign dbg_cpu_addr    = core.cpu_addr;
assign dbg_cpu_din     = core.cpu_din;
assign dbg_cpu_dout    = core.cpu_dout;
assign dbg_cpu_rw      = core.cpu_rw;
assign dbg_cpu_ce      = core.fallE;
assign dbg_cpu_pc      = core.cpu.pc;
assign dbg_tape_motor  = motor;
assign dbg_tape_pos    = tape.pos;
assign dbg_tape_strobe = tape_strobe;
assign dbg_tape_byte   = tape_byte;
assign dbg_kb_code     = core.kb_code;
assign dbg_kb_mode     = core.kb_mode;
assign dbg_kb_cnt      = core.kb_cnt;
assign dbg_cc          = core.cpu.cc;

endmodule
