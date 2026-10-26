//============================================================================
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//
//============================================================================

module emu
(
	//Master input clock
	input         CLK_50M,

	//Async reset from top-level module.
	//Can be used as initial reset.
	input         RESET,

	//Must be passed to hps_io module
	inout  [48:0] HPS_BUS,

	//Base video clock. Usually equals to CLK_SYS.
	output        CLK_VIDEO,

	//Multiple resolutions are supported using different CE_PIXEL rates.
	//Must be based on CLK_VIDEO
	output        CE_PIXEL,

	//Video aspect ratio for HDMI. Most retro systems have ratio 4:3.
	//if VIDEO_ARX[12] or VIDEO_ARY[12] is set then [11:0] contains scaled size instead of aspect ratio.
	output [12:0] VIDEO_ARX,
	output [12:0] VIDEO_ARY,

	output  [7:0] VGA_R,
	output  [7:0] VGA_G,
	output  [7:0] VGA_B,
	output        VGA_HS,
	output        VGA_VS,
	output        VGA_DE,    // = ~(VBlank | HBlank)
	output        VGA_F1,
	output [1:0]  VGA_SL,
	output        VGA_SCALER, // Force VGA scaler

	input  [11:0] HDMI_WIDTH,
	input  [11:0] HDMI_HEIGHT,
	output        HDMI_FREEZE,

`ifdef MISTER_FB
	// Use framebuffer in DDRAM (USE_FB=1 in qsf)
	// FB_FORMAT:
	//    [2:0] : 011=8bpp(palette) 100=16bpp 101=24bpp 110=32bpp
	//    [3]   : 0=16bits 565 1=16bits 1555
	//    [4]   : 0=RGB  1=BGR (for 16/24/32 modes)
	//
	// FB_STRIDE either 0 (rounded to 256 bytes) or multiple of pixel size (in bytes)
	output        FB_EN,
	output  [4:0] FB_FORMAT,
	output [11:0] FB_WIDTH,
	output [11:0] FB_HEIGHT,
	output [31:0] FB_BASE,
	output [13:0] FB_STRIDE,
	input         FB_VBL,
	input         FB_LL,
	output        FB_FORCE_BLANK,

`ifdef MISTER_FB_PALETTE
	// Palette control for 8bit modes.
	// Ignored for other video modes.
	output        FB_PAL_CLK,
	output  [7:0] FB_PAL_ADDR,
	output [23:0] FB_PAL_DOUT,
	input  [23:0] FB_PAL_DIN,
	output        FB_PAL_WR,
`endif
`endif

	output        LED_USER,  // 1 - ON, 0 - OFF.

	// b[1]: 0 - LED status is system status OR'd with b[0]
	//       1 - LED status is controled solely by b[0]
	// hint: supply 2'b00 to let the system control the LED.
	output  [1:0] LED_POWER,
	output  [1:0] LED_DISK,

	// I/O board button press simulation (active high)
	// b[1]: user button
	// b[0]: osd button
	output  [1:0] BUTTONS,

	input         CLK_AUDIO, // 24.576 MHz
	output [15:0] AUDIO_L,
	output [15:0] AUDIO_R,
	output        AUDIO_S,   // 1 - signed audio samples, 0 - unsigned
	output  [1:0] AUDIO_MIX, // 0 - no mix, 1 - 25%, 2 - 50%, 3 - 100% (mono)

	//ADC
	inout   [3:0] ADC_BUS,

	//SD-SPI
	output        SD_SCK,
	output        SD_MOSI,
	input         SD_MISO,
	output        SD_CS,
	input         SD_CD,

	//High latency DDR3 RAM interface
	//Use for non-critical time purposes
	output        DDRAM_CLK,
	input         DDRAM_BUSY,
	output  [7:0] DDRAM_BURSTCNT,
	output [28:0] DDRAM_ADDR,
	input  [63:0] DDRAM_DOUT,
	input         DDRAM_DOUT_READY,
	output        DDRAM_RD,
	output [63:0] DDRAM_DIN,
	output  [7:0] DDRAM_BE,
	output        DDRAM_WE,

	//SDRAM interface with lower latency
	output        SDRAM_CLK,
	output        SDRAM_CKE,
	output [12:0] SDRAM_A,
	output  [1:0] SDRAM_BA,
	inout  [15:0] SDRAM_DQ,
	output        SDRAM_DQML,
	output        SDRAM_DQMH,
	output        SDRAM_nCS,
	output        SDRAM_nCAS,
	output        SDRAM_nRAS,
	output        SDRAM_nWE,

`ifdef MISTER_DUAL_SDRAM
	//Secondary SDRAM
	//Set all output SDRAM_* signals to Z ASAP if SDRAM2_EN is 0
	input         SDRAM2_EN,
	output        SDRAM2_CLK,
	output [12:0] SDRAM2_A,
	output  [1:0] SDRAM2_BA,
	inout  [15:0] SDRAM2_DQ,
	output        SDRAM2_nCS,
	output        SDRAM2_nCAS,
	output        SDRAM2_nRAS,
	output        SDRAM2_nWE,
`endif

	input         UART_CTS,
	output        UART_RTS,
	input         UART_RXD,
	output        UART_TXD,
	output        UART_DTR,
	input         UART_DSR,

	// Open-drain User port.
	// 0 - D+/RX
	// 1 - D-/TX
	// 2..6 - USR2..USR6
	// Set USER_OUT to 1 to read from USER_IN.
	input   [6:0] USER_IN,
	output  [6:0] USER_OUT,

	input         OSD_STATUS
);

///////// Default values for ports not used in this core /////////

//assign ADC_BUS  = 'Z;
assign USER_OUT = '1;
assign {UART_RTS, UART_TXD, UART_DTR} = 0;
assign {SD_SCK, SD_MOSI, SD_CS} = 'Z;
assign {SDRAM_DQ, SDRAM_A, SDRAM_BA, SDRAM_CLK, SDRAM_CKE, SDRAM_DQML, SDRAM_DQMH, SDRAM_nWE, SDRAM_nCAS, SDRAM_nRAS, SDRAM_nCS} = 'Z;
assign {DDRAM_CLK, DDRAM_BURSTCNT, DDRAM_ADDR, DDRAM_DIN, DDRAM_BE, DDRAM_RD, DDRAM_WE} = '0;

assign VGA_SCALER = 0;
assign HDMI_FREEZE = 0;

// $FFD3 bit 7 is a 1-bit speaker level.
assign AUDIO_S = 0;
wire [10:0] psg_snd;
assign AUDIO_L = {1'b0, beep, 14'd0} + {2'b00, psg_snd, 3'd0};
assign AUDIO_R = AUDIO_L;
assign AUDIO_MIX = 0;

assign LED_USER = tape_active;
assign LED_DISK = 0;
assign LED_POWER = 0;
assign BUTTONS = 0;

//////////////////////////////////////////////////////////////////

wire [1:0] ar = cfg[122:121];

assign VIDEO_ARX = (!ar) ? 12'd4 : (ar - 1'd1);
assign VIDEO_ARY = (!ar) ? 12'd3 : 12'd0;

// boot0.rom (from games/BasicMasterL3/) is loaded as index 0:
//   $0000-$5FFF Level 3 BASIC (MAME 598/599/600 joined, = EmuB L3BAS.ROM)
//   $8000-$8FFF character generator (font.rom)
// See roms/README.md for how it is built.
`include "build_id.v"
// OSD layout follows ~/dev2/osd-standard.md: media and Memory on the top page,
// P1 Machine, P2 Video, P3 Input. Settings take effect at the next reset (cfg
// below); Keyboard, Tape speed, Tape overlay and Rewind tape act at once.
// Hide flags must come before the page prefix ("H2P1...").
localparam CONF_STR = {
	"BasicMasterL3;;",
	"-;",
	"SC0,D88,Pri. disk 0;",
	"SC1,D88,Disk 1;",
	"S2,L3 ,Tape;",
	"F0,ROM,Load ROM;",
	"-;",
	"O[8],Memory,64K,32K (stock);",
	"-;",
	"P1,Machine;",
	"P2,Video;",
	"P3,Input;",
	"-;",
	"h0-,Changes pending;",
	"R[0],Apply and reset;",

	"P1O[12:11],Model,Mark 5,Level 3,MB-S1;",
	"H2P1O[13],S1 SYSTEM,A (S1 BASIC),B (Level 3);",
	"h2P1-;",
	"P1O[15:14],Floppy card,Auto,MP-1802,None;",
	"P1O[10],PSG card,On,Off;",
	"P1O[16],Tape speed,16x,Normal;",
	"P1-;",
	"P1T[18],Rewind tape;",

	"P2O[6],Interlace,Even field,On;",
	"P2O[9],Border,On,Off;",
	"P2O[117:115],Scandoubler Fx,None,HQ2x,CRT 25%,CRT 50%,CRT 75%;",
	"P2O[122:121],Aspect ratio,Original,Full Screen,[ARC1],[ARC2];",
	"P2O[17],Tape overlay,On,Off;",

	"P3O[5],Keyboard,US symbols,JIS layout;",

	"I,Tape ready (rewound);",
	"v,1;",
	"V,v",`BUILD_DATE,";",
	"J,Fire 1,Fire 2"
};

wire forced_scandoubler;
wire [21:0] gamma_bus;
wire   [1:0] buttons;
wire [127:0] status;
wire  [10:0] ps2_key;
wire  [31:0] joy;

// Floppy block devices, one per drive (byte-wide: WIDE must stay 0, see
// FM-7_MiSTer.sv).
// block devices 0, 1: MP-1802 drives; 2: the tape, streamed a sector at a time
wire  [2:0] img_mounted;
wire        img_readonly;
wire [63:0] img_size;
wire [31:0] sd_lba [3];
wire  [2:0] sd_rd, sd_wr, sd_ack;
wire  [8:0] sd_buff_addr;
wire  [7:0] sd_buff_dout;
wire  [7:0] sd_buff_din [3];
wire        sd_buff_wr;

wire [24:0] ioctl_addr;
wire  [7:0] ioctl_dout;
wire  [7:0] ioctl_index;
wire        ioctl_wr;
wire        ioctl_download;

hps_io #(.CONF_STR(CONF_STR), .WIDE(0), .VDNUM(3)) hps_io
(
	.clk_sys(clk_sys),
	.HPS_BUS(HPS_BUS),
	.EXT_BUS(),
	.gamma_bus(gamma_bus),

	.forced_scandoubler(forced_scandoubler),

	.buttons(buttons),
	.status(status),
	.status_menumask({13'd0, status[12:11] != 2'd2, 1'b0, pending}),
	.info_req(info_req),
	.info(8'd1),

	.ps2_key(ps2_key),
	.joystick_0(joy),

	.img_mounted(img_mounted),
	.img_readonly(img_readonly),
	.img_size(img_size),
	.sd_lba(sd_lba),
	.sd_blk_cnt('{6'd0, 6'd0, 6'd0}),
	.sd_rd(sd_rd),
	.sd_wr(sd_wr),
	.sd_ack(sd_ack),
	.sd_buff_addr(sd_buff_addr),
	.sd_buff_dout(sd_buff_dout),
	.sd_buff_din(sd_buff_din),
	.sd_buff_wr(sd_buff_wr),

	.ioctl_download(ioctl_download),
	.ioctl_wr(ioctl_wr),
	.ioctl_addr(ioctl_addr),
	.ioctl_dout(ioctl_dout),
	.ioctl_wait(1'b0),
	.ioctl_index(ioctl_index)
);

///////////////////////   CLOCKS   ///////////////////////////////

// 32.256 MHz: the machine's own crystal. The core derives E (1.008 MHz), the
// CRTC character clocks and the 16.128 MHz pixel enable from it.
wire clk_sys;
pll pll
(
	.refclk(CLK_50M),
	.rst(0),
	.outclk_0(clk_sys),
	.outclk_1()
);

wire rom_download  = ioctl_download && ioctl_index == 8'd0;
wire reset = RESET | status[0] | buttons[1] | rom_download;

// The settings the machine runs with, taken from the OSD at every reset (Apply
// and reset, the board's reset, a core load). Keyboard (5), Tape speed (16),
// Tape overlay (17) and Rewind tape (18) read status directly.
reg [127:0] cfg;
always @(posedge clk_sys) if (reset) cfg <= status;
wire pending = {status[6], status[15:8], status[117:115], status[122:121]}
            != {cfg[6],    cfg[15:8],    cfg[117:115],    cfg[122:121]};

// Floppy card, fitted at reset. Auto fits it only when drive 0 holds an image:
// an S1 in A mode with the card fitted waits for a system disk forever
// ("Insert Program Diskette"; S1 ROM $5471, no BREAK check).
reg disk0_in, fdc_fit;
always @(posedge clk_sys) begin
	if (img_mounted[0]) disk0_in <= |img_size;
	if (reset) fdc_fit <= status[15:14] == 2'd1 || (status[15:14] == 2'd0 && disk0_in);
end

// "Tape ready (rewound)" on every tape mount
reg info_req;
always @(posedge clk_sys) info_req <= img_mounted[2] && |img_size;

wire        tape_strobe;
wire  [7:0] tape_byte;
wire        tape_active;
wire [31:0] tape_pos, tape_len;
wire        motor, baud1200, rx_full;
wire [31:0] sd_lba_fdc [2];
wire  [7:0] sd_buff_din_fdc [2];
wire  [1:0] sd_rd_fdc, sd_wr_fdc;

tape tape (
	.clk(clk_sys), .reset(RESET), .rewind(status[18]),
	.motor(motor), .baud1200(baud1200), .rx_full(rx_full),
	.speed(status[16] ? 3'd0 : 3'd4),
	.img_mounted(img_mounted[2]), .img_size(img_size),
	.sd_lba(sd_lba[2]), .sd_rd(sd_rd[2]), .sd_ack(sd_ack[2]),
	.sd_buff_addr(sd_buff_addr), .sd_buff_dout(sd_buff_dout), .sd_buff_wr(sd_buff_wr),
	.rx_strobe(tape_strobe), .rx_data(tape_byte), .active(tape_active), .position(tape_pos), .length(tape_len)
);
assign sd_wr[2] = 1'b0;
assign sd_buff_din[2] = 8'd0;
assign sd_lba[0] = sd_lba_fdc[0];
assign sd_lba[1] = sd_lba_fdc[1];
assign sd_buff_din[0] = sd_buff_din_fdc[0];
assign sd_buff_din[1] = sd_buff_din_fdc[1];
assign sd_rd[1:0] = sd_rd_fdc;
assign sd_wr[1:0] = sd_wr_fdc;

//////////////////////////////  CORE  ////////////////////////////////////////

wire [127:0] keys;
wire         break_key;
wire         beep;
wire         hs, vs, hb, vb, ce_pix;
wire   [7:0] red, green, blue;

keyboard keyboard (
	.clk(clk_sys), .reset(reset), .symbolic(~status[5]), .ps2_key(ps2_key),
	.keys(keys), .break_key(break_key)
);

core core (
	.clk(clk_sys), .reset_in(reset), .mark5(cfg[12:11] != 2'd1), .s1(cfg[12:11] == 2'd2), .s1_amode(~cfg[13]), .interlace(cfg[6]),
	.rom_wr(rom_download & ioctl_wr), .rom_addr(ioctl_addr[17:0]), .rom_data(ioctl_dout),
	.keys(keys), .break_key(break_key), .dipsw(8'h03),
	.rx_strobe(tape_strobe), .rx_data(tape_byte), .motor(motor), .baud1200(baud1200), .rx_full(rx_full),
	.beep(beep),
	.fdc_en(fdc_fit), .ram_hi(~cfg[8]), .border(~cfg[9]), .psg_en(~cfg[10]),
	.joy(~{2'b00, joy[5], joy[4], joy[0], joy[1], joy[2], joy[3]}), .psg_snd(psg_snd),
	.img_mounted(img_mounted[1:0]), .img_readonly(img_readonly), .img_size(img_size),
	.sd_lba(sd_lba_fdc), .sd_rd(sd_rd_fdc), .sd_wr(sd_wr_fdc), .sd_ack(sd_ack[1:0]),
	.sd_buff_addr(sd_buff_addr), .sd_buff_dout(sd_buff_dout), .sd_buff_din(sd_buff_din_fdc),
	.sd_buff_wr(sd_buff_wr),
	.red(red), .green(green), .blue(blue),
	.hs(hs), .vs(vs), .hb(hb), .vb(vb), .field(VGA_F1), .ce_pix(ce_pix)
);

wire [7:0] ov_r, ov_g, ov_b;
tape_overlay tape_overlay (
	.clk(clk_sys), .loaded(tape_len != 0), .playing(motor), .fast(~status[16]),
	.baud1200(baud1200), .position(tape_pos), .size(tape_len),
	.enable(~status[17]), .ce_pix(ce_pix), .hblank(hb), .vblank(vb),
	.r_in(red), .g_in(green), .b_in(blue), .r_out(ov_r), .g_out(ov_g), .b_out(ov_b)
);

assign CLK_VIDEO = clk_sys;

wire [2:0] video_fx = cfg[117:115];
wire [2:0] scanline_fx = video_fx ? video_fx - 3'd1 : 3'd0;
wire scandoubler = forced_scandoubler | (video_fx != 3'd0);
assign VGA_SL = scanline_fx[1:0];

video_mixer #(
	.LINE_LENGTH(800),
	.HALF_DEPTH(0),
	.GAMMA(1)
) video_mixer (
	.CLK_VIDEO(clk_sys),
	.ce_pix(ce_pix),
	.CE_PIXEL(CE_PIXEL),
	.scandoubler(scandoubler),
	.hq2x(video_fx == 3'd1),
	.gamma_bus(gamma_bus),
	.R(ov_r),
	.G(ov_g),
	.B(ov_b),
	.HSync(hs),
	.VSync(vs),
	.HBlank(hb),
	.VBlank(vb),
	.HDMI_FREEZE(1'b0),
	.freeze_sync(),
	.VGA_R(VGA_R),
	.VGA_G(VGA_G),
	.VGA_B(VGA_B),
	.VGA_VS(VGA_VS),
	.VGA_HS(VGA_HS),
	.VGA_DE(VGA_DE)
);

endmodule
