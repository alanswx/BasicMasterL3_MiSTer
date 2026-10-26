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
	input             s1,
	input             s1_amode,
	input             symbolic,
	input             interlace,
	input       [7:0] dipsw,

	// HPS file transfer: index 0 = boot0.rom. Tapes are block device 2.
	input             ioctl_download,
	input             ioctl_wr,
	input      [24:0] ioctl_addr,
	input       [7:0] ioctl_dout,
	input       [7:0] ioctl_index,
	output            ioctl_wait,

	// floppy block devices (SimBlockDevice): per-drive bit vectors as it expects
	input             fdc_en,
	input             ram_hi,
	input             border,
	input             psg_en,
	input      [15:0] img_mounted,
	input             img_readonly,
	input      [63:0] img_size,
	output     [31:0] sd_lba [3],
	output     [15:0] sd_rd,
	output     [15:0] sd_wr,
	input      [15:0] sd_ack,
	input       [8:0] sd_buff_addr,
	input       [7:0] sd_buff_dout,
	output      [7:0] sd_buff_din [3],
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
	output     [19:0] dbg_pa,
	output      [7:0] dbg_cpu_din,
	output      [7:0] dbg_cpu_dout,
	output            dbg_cpu_rw,
	output            dbg_cpu_ce,      // 1 for one clk_sys tick at the end of each CPU cycle
	output     [15:0] dbg_cpu_pc,
	output            dbg_tape_motor,
	output     [31:0] dbg_tape_pos,
	output            dbg_tape_strobe,
	output      [7:0] dbg_tape_byte,
	output      [7:0] dbg_kb_code,
	output      [7:0] dbg_kb_mode,
	output      [7:0] dbg_kb_cnt,
	output      [7:0] dbg_cc
);

assign ioctl_wait = 1'b0;

wire rom_download  = ioctl_download && ioctl_index == 8'd0;
wire core_reset = reset | rom_download;
wire       sd_rd_t;
wire        tape_strobe;
wire  [7:0] tape_byte;
wire        motor, baud1200, rx_full;
wire [31:0] sd_lba_core [2];

tape tape (
	.clk(clk_sys), .reset(reset),
	.motor(motor), .baud1200(baud1200), .rx_full(rx_full), .speed(tape_speed),
	.img_mounted(img_mounted[2]), .img_size(img_size),
	.sd_lba(sd_lba[2]), .sd_rd(sd_rd_t), .sd_ack(sd_ack[2]),
	.sd_buff_addr(sd_buff_addr), .sd_buff_dout(sd_buff_dout), .sd_buff_wr(sd_buff_wr),
	.rx_strobe(tape_strobe), .rx_data(tape_byte), .active(), .position()
);
assign sd_buff_din[2] = 8'd0;
assign sd_lba[0] = sd_lba_core[0];
assign sd_lba[1] = sd_lba_core[1];

//////////////////////////////  CORE  ////////////////////////////////////////
wire [127:0] keys;
wire         break_key;
wire         beep;

keyboard keyboard (
	.clk(clk_sys), .reset(reset), .symbolic(symbolic), .ps2_key(ps2_key),
	.keys(keys), .break_key(break_key)
);

wire [1:0] sd_rd2, sd_wr2;
wire [7:0] sd_buff_din_core [2];
assign sd_rd = {13'd0, sd_rd_t, sd_rd2};
assign sd_wr = {14'd0, sd_wr2};
assign sd_buff_din[0] = sd_buff_din_core[0];
assign sd_buff_din[1] = sd_buff_din_core[1];

core core (
	.clk(clk_sys), .reset_in(core_reset), .mark5(mark5), .s1(s1), .s1_amode(s1_amode), .interlace(interlace),
	.rom_wr(rom_download & ioctl_wr), .rom_addr(ioctl_addr[17:0]), .rom_data(ioctl_dout),
	.keys(keys), .break_key(break_key), .dipsw(dipsw),
	.rx_strobe(tape_strobe), .rx_data(tape_byte), .motor(motor), .baud1200(baud1200), .rx_full(rx_full),
	.beep(beep),
	.fdc_en(fdc_en), .ram_hi(ram_hi), .border(border), .psg_en(psg_en), .joy(8'hff), .psg_snd(psg_snd),
	.img_mounted(img_mounted[1:0]), .img_readonly(img_readonly), .img_size(img_size),
	.sd_lba(sd_lba_core), .sd_rd(sd_rd2), .sd_wr(sd_wr2), .sd_ack(sd_ack[1:0]),
	.sd_buff_addr(sd_buff_addr), .sd_buff_dout(sd_buff_dout), .sd_buff_din(sd_buff_din_core),
	.sd_buff_wr(sd_buff_wr),
	.red(VGA_R), .green(VGA_G), .blue(VGA_B),
	.hs(VGA_HS), .vs(VGA_VS), .hb(VGA_HB), .vb(VGA_VB), .field(), .ce_pix(CE_PIXEL)
);

wire [10:0] psg_snd;
assign AUDIO_L = {1'b0, beep, 14'd0} + {2'b00, psg_snd, 3'd0};
assign AUDIO_R = AUDIO_L;

//////////////////////////////  DEBUG TAPS  //////////////////////////////////
assign dbg_cpu_addr    = core.cpu_addr;
assign dbg_pa          = core.pa;
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
