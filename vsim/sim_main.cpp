// Verilator harness for the Basic Master Level 3 MiSTer core.
//
// Derived from the Basic Master Jr. harness: one clock (32.256 MHz, the
// machine's crystal), a PS/2 keyboard, boot0.rom and tape images over ioctl,
// and video.
//
//   make && ./obj_dir/Vemu                        # windowed
//   ./obj_dir/Vemu --headless --screenshot 120 --stop-at-frame 130
//   ./obj_dir/Vemu --tape game.l3 --send-keys '200:LOADM"",,R\n' --screenshot 900
//
// Frame numbers are 1/60 s of simulated time, counted from power-on, so they
// mean the same thing whether or not the CRTC has been programmed yet.

#include <verilated.h>
#include "Vemu.h"

#if defined(__has_include)
# if __has_include("Vemu___024root.h")
#  include "Vemu___024root.h"
#  define VEMU_SPLIT_ROOT 1
# endif
#endif

#ifndef _MSC_VER
#include <SDL.h>
#include <SDL_opengl.h>
#endif

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cstdint>
#include <string>
#include <vector>
#include <algorithm>

#include "sim_console.h"
#include "sim_bus.h"
#include "sim_video.h"
#include "sim_input.h"
#include "sim_clock.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "sim/stb_image_write.h"

// Active picture: 640 pixels (40 col doubles each dot) x 200 lines
#define VGA_WIDTH  640
#define VGA_HEIGHT 200

#define SIM_CLK_HZ 32256000u
#define TICKS_PER_FRAME (SIM_CLK_HZ / 60u)

// 50 us power-on reset
#define INITIAL_RESET_TICKS (SIM_CLK_HZ / 20000u)

vluint64_t main_time = 0;
double sc_time_stamp() { return main_time; }

DebugConsole console;
SimBus       bus(console);
SimInput     input(1, console);
SimVideo     video(VGA_WIDTH, VGA_HEIGHT, 0);
SimClock     clk_sys_clock(1);

Vemu* top = nullptr;

bool headless   = false;
bool trace_cpu  = false;
bool trace_io   = false;
bool trace_tape = false;
bool trace_key  = false;
// The hardware scanner walks all 128 codes once per 16.25 ms and the ROM
// polls on top of that, so injected keys need a generous hold.
unsigned int key_hold_cycles = SIM_CLK_HZ * 50 / 1000;   // 50 ms
int  tape_speed = 0;
bool mark5 = true;
unsigned int dipsw = 0x03;
int  stop_at_frame = -1;
std::vector<int> screenshot_frames;
std::string rom_image = "../roms/mister/bml3_boot0.rom";
std::string tape_image;
std::string screenshot_prefix = "screenshot_frame";
std::string screenshot_name;
bool rom_loaded = false;

struct MemDump { int frame; unsigned addr; unsigned len; };
std::vector<MemDump> mem_dumps;
struct MemPoke { int frame; unsigned addr; std::vector<uint8_t> bytes; };
std::vector<MemPoke> mem_pokes;
std::vector<unsigned> watch_pcs;
std::vector<unsigned long long> watch_hits;
struct KeyInjection { int frame; std::string keys; };
std::vector<KeyInjection> key_injections;
std::vector<int> text_dump_frames;

static int sim_frame() { return (int)(main_time / TICKS_PER_FRAME); }

// ---------------------------------------------------------------------------
static void save_screenshot(int frame_number, const char* name = nullptr)
{
	if (!output_ptr) { printf("screenshot: no framebuffer\n"); return; }

	char filename[512];
	if (name)                          snprintf(filename, sizeof(filename), "%s", name);
	else if (!screenshot_name.empty()) snprintf(filename, sizeof(filename), "%s", screenshot_name.c_str());
	else                               snprintf(filename, sizeof(filename), "%s_%04d.png", screenshot_prefix.c_str(), frame_number);

	const int w = video.output_width;
	const int h = video.output_height;
	std::vector<uint8_t> rgb((size_t)w * h * 3);
	for (int y = 0; y < h; y++)
		for (int x = 0; x < w; x++) {
			uint32_t p = output_ptr[y * w + x];
			size_t d = ((size_t)y * w + x) * 3;
			rgb[d + 0] = (p >> 0)  & 0xFF;
			rgb[d + 1] = (p >> 8)  & 0xFF;
			rgb[d + 2] = (p >> 16) & 0xFF;
		}

	if (stbi_write_png(filename, w, h, 3, rgb.data(), w * 3))
		printf("Screenshot saved: %s\n", filename);
	else
		printf("Error: failed to write %s\n", filename);
	fflush(stdout);
}

// ---------------------------------------------------------------------------
// Keyboard injection. rtl/keyboard.v takes PS/2 set-2 codes; the Level 3 has
// a JIS layout, so the shifted symbols are those of the Level 3 keys the PS/2
// keys are mapped to (see the table in rtl/keyboard.v).
struct Ps2Map { unsigned int code; bool shift; bool ext; };

static Ps2Map ascii_to_ps2(char c)
{
	Ps2Map m = { 0xFF, false, false };
	if (c >= 'a' && c <= 'z') c = (char)(c - 'a' + 'A');

	static const struct { char ch; unsigned int sc; } letters[] = {
		{'A',0x1c},{'B',0x32},{'C',0x21},{'D',0x23},{'E',0x24},{'F',0x2b},{'G',0x34},
		{'H',0x33},{'I',0x43},{'J',0x3b},{'K',0x42},{'L',0x4b},{'M',0x3a},{'N',0x31},
		{'O',0x44},{'P',0x4d},{'Q',0x15},{'R',0x2d},{'S',0x1b},{'T',0x2c},{'U',0x3c},
		{'V',0x2a},{'W',0x1d},{'X',0x22},{'Y',0x35},{'Z',0x1a},
	};
	for (auto& l : letters) if (l.ch == c) { m.code = l.sc; return m; }

	static const unsigned int digits[] = { 0x45,0x16,0x1e,0x26,0x25,0x2e,0x36,0x3d,0x3e,0x46 };
	if (c >= '0' && c <= '9') { m.code = digits[c - '0']; return m; }

	switch (c) {
		case ' ':  m.code = 0x29; break;
		case '\n': case '\r': m.code = 0x5a; break;
		case '\b': m.code = 0x66; break;
		case ',':  m.code = 0x41; break;
		case '.':  m.code = 0x49; break;
		case '/':  m.code = 0x4a; break;
		case ';':  m.code = 0x4c; break;
		case ':':  m.code = 0x52; break;
		case '-':  m.code = 0x4e; break;
		case '^':  m.code = 0x55; break;
		case '@':  m.code = 0x0e; break;
		case '[':  m.code = 0x54; break;
		case ']':  m.code = 0x5b; break;
		case '\\': m.code = 0x5d; break;
		case '_':  m.code = 0x51; break;
		case '+':  m.code = 0x4c; m.shift = true; break;
		case '*':  m.code = 0x52; m.shift = true; break;
		case '=':  m.code = 0x4e; m.shift = true; break;
		case '!':  m.code = 0x16; m.shift = true; break;
		case '"':  m.code = 0x1e; m.shift = true; break;
		case '#':  m.code = 0x26; m.shift = true; break;
		case '$':  m.code = 0x25; m.shift = true; break;
		case '%':  m.code = 0x2e; m.shift = true; break;
		case '&':  m.code = 0x36; m.shift = true; break;
		case '\'': m.code = 0x3d; m.shift = true; break;
		case '(':  m.code = 0x3e; m.shift = true; break;
		case ')':  m.code = 0x46; m.shift = true; break;
		case '<':  m.code = 0x41; m.shift = true; break;
		case '>':  m.code = 0x49; m.shift = true; break;
		case '?':  m.code = 0x4a; m.shift = true; break;
		default: break;
	}
	return m;
}

static void queue_key_string(const std::string& keys)
{
	const unsigned int SHIFT = 0x12;
	for (char c : keys) {
		Ps2Map m = ascii_to_ps2(c);
		if (m.code == 0xFF) {
			printf("send-keys: no mapping for '%c' (0x%02x) -- skipped\n", c, (unsigned char)c);
			continue;
		}
		if (m.shift) input.keyEvents.push(SimInput_PS2KeyEvent(SHIFT, true, false, SHIFT));
		input.keyEvents.push(SimInput_PS2KeyEvent(m.code, true,  m.ext, m.code));
		input.keyEvents.push(SimInput_PS2KeyEvent(m.code, false, m.ext, m.code));
		if (m.shift) input.keyEvents.push(SimInput_PS2KeyEvent(SHIFT, false, false, SHIFT));
	}
}

static std::string unescape(const std::string& in)
{
	std::string out;
	for (size_t i = 0; i < in.size(); i++) {
		if (in[i] != '\\' || i + 1 >= in.size()) { out += in[i]; continue; }
		char n = in[++i];
		switch (n) {
			case 'n': out += '\n'; break;
			case 'r': out += '\r'; break;
			case 't': out += '\t'; break;
			case 'b': out += '\b'; break;
			case '\\': out += '\\'; break;
			case 'x':
				if (i + 2 < in.size()) {
					out += (char)strtol(in.substr(i + 1, 2).c_str(), nullptr, 16);
					i += 2;
				}
				break;
			default: out += n; break;
		}
	}
	return out;
}

#ifdef VEMU_SPLIT_ROOT
# define ROOT top->rootp
#else
# define ROOT top
#endif
#define MAIN_RAM  ROOT->emu__DOT__core__DOT__ram__DOT__mem
#define COLOR_RAM ROOT->emu__DOT__core__DOT__cram__DOT__mem

static void save_mem_dump(const MemDump& d)
{
	char filename[256];
	snprintf(filename, sizeof(filename), "memdump_%04X_%04X_f%04d.bin",
	         d.addr, d.addr + d.len - 1, d.frame);
	FILE* f = fopen(filename, "wb");
	if (!f) { printf("dump-mem: cannot write %s\n", filename); return; }
	for (unsigned a = d.addr; a < d.addr + d.len && a < 0x10000; a++)
		fputc(MAIN_RAM[a], f);
	fclose(f);
	printf("Memory dump saved: %s\n", filename);
	fflush(stdout);
}

static void apply_poke(const MemPoke& q)
{
	for (size_t i = 0; i < q.bytes.size(); i++) {
		unsigned a = q.addr + (unsigned)i;
		if (a < 0x10000) MAIN_RAM[a] = q.bytes[i];
	}
	printf("Poked %zu byte(s) at $%04X\n", q.bytes.size(), q.addr);
	fflush(stdout);
}

// Print the 40x25 text screen at $0400 as ASCII: a cheap, exact check of what
// BASIC printed that does not depend on the font.
static void dump_text(int frame)
{
	printf("---- text screen at frame %d ----\n", frame);
	for (int r = 0; r < 25; r++) {
		char line[41];
		for (int c = 0; c < 40; c++) {
			uint8_t ch = MAIN_RAM[0x0400 + r * 40 + c];
			line[c] = (ch >= 0x20 && ch < 0x7f) ? (char)ch : '.';
		}
		line[40] = 0;
		printf("|%s|\n", line);
	}
	fflush(stdout);
}

static void process_key_injections(int frame)
{
	for (auto it = key_injections.begin(); it != key_injections.end(); ) {
		if (it->frame == frame) {
			printf("Injecting keys at frame %d: \"%s\"\n", frame, it->keys.c_str());
			queue_key_string(it->keys);
			it = key_injections.erase(it);
		} else ++it;
	}
}

// ---------------------------------------------------------------------------
static uint8_t prev_ce_pix = 0;
static uint64_t reset_ticks = 0;

static int verilate()
{
	if (Verilated::gotFinish()) {
		top->final();
		delete top;
		exit(0);
	}

	if (main_time < INITIAL_RESET_TICKS) {
		top->reset = 1;
		reset_ticks = main_time;
	} else if (top->reset && main_time > reset_ticks + INITIAL_RESET_TICKS) {
		top->reset = 0;
	}

	clk_sys_clock.Tick();
	top->clk_sys = clk_sys_clock.clk;

	if (clk_sys_clock.clk != clk_sys_clock.old) {
		if (clk_sys_clock.clk) {
			input.BeforeEval();
			bus.BeforeEval();
		}
		top->eval();
		if (clk_sys_clock.clk) bus.AfterEval();
	} else {
		top->eval();
	}

	if (clk_sys_clock.IsRising()) {
		uint8_t ce = top->CE_PIXEL;
		if (ce) {
			uint32_t colour = 0xFF000000u | ((uint32_t)top->VGA_B << 16)
			                              | ((uint32_t)top->VGA_G << 8)
			                              | ((uint32_t)top->VGA_R);
			video.Clock(top->VGA_HB, top->VGA_VB, top->VGA_HS, top->VGA_VS, colour);
		}
		prev_ce_pix = ce;

		if (top->dbg_cpu_ce) {
			uint16_t a = top->dbg_cpu_addr;
			uint8_t  d = top->dbg_cpu_rw ? top->dbg_cpu_din : top->dbg_cpu_dout;
			if (trace_cpu)
				printf("[cpu] PC=%04X A=%04X D=%02X %s\n", top->dbg_cpu_pc, a, d,
				       top->dbg_cpu_rw ? "R" : "W");
			if (trace_io && a >= 0xFF00 && a <= 0xFFEF)
				printf("[io ] f%05d PC=%04X %s $%04X %s $%02X\n", sim_frame(),
				       top->dbg_cpu_pc, top->dbg_cpu_rw ? "RD" : "WR", a,
				       top->dbg_cpu_rw ? "->" : "<-", d);
			if (!watch_pcs.empty()) {
				static uint16_t prev = 0xFFFF;
				if (a != prev) {
					prev = a;
					for (size_t i = 0; i < watch_pcs.size(); i++)
						if (watch_pcs[i] == a) watch_hits[i]++;
				}
			}
		}

		if (trace_tape) {
			static uint8_t last_motor = 0xFF;
			if (top->dbg_tape_motor != last_motor) {
				last_motor = top->dbg_tape_motor;
				printf("[tape] motor=%d pos=%u frame=%d\n", last_motor,
				       (unsigned)top->dbg_tape_pos, sim_frame());
			}
			if (top->dbg_tape_strobe)
				printf("[tape] byte %u = $%02X frame=%d\n",
				       (unsigned)top->dbg_tape_pos, top->dbg_tape_byte, sim_frame());
		}

		if (trace_key) {
			static uint8_t last_code = 0;
			if ((top->dbg_kb_code & 0x80) && !(last_code & 0x80))
				printf("[key] latched $%02X frame=%d\n", top->dbg_kb_code, sim_frame());
			last_code = top->dbg_kb_code;
		}

		main_time++;
	}
	return 1;
}

static void RunBatch(int steps) { for (int i = 0; i < steps; i++) verilate(); }

static bool frame_actions(int frame)
{
	if (!key_injections.empty()) process_key_injections(frame);

	for (auto it = mem_pokes.begin(); it != mem_pokes.end(); ) {
		if (it->frame == frame) { apply_poke(*it); it = mem_pokes.erase(it); }
		else ++it;
	}
	for (auto it = mem_dumps.begin(); it != mem_dumps.end(); ) {
		if (it->frame == frame) { save_mem_dump(*it); it = mem_dumps.erase(it); }
		else ++it;
	}
	for (auto it = text_dump_frames.begin(); it != text_dump_frames.end(); ) {
		if (*it == frame) { dump_text(frame); it = text_dump_frames.erase(it); }
		else ++it;
	}
	auto it = std::find(screenshot_frames.begin(), screenshot_frames.end(), frame);
	if (it != screenshot_frames.end()) {
		save_screenshot(frame);
		screenshot_frames.erase(it);
	}
	if (stop_at_frame >= 0 && frame >= stop_at_frame) {
		printf("Reached stop frame %d (video frames %d), exiting\n", frame, video.count_frame);
		for (size_t i = 0; i < watch_pcs.size(); i++)
			printf("[watch] $%04X hit %llu times\n", watch_pcs[i],
			       (unsigned long long)watch_hits[i]);
		return true;
	}
	return false;
}

// ---------------------------------------------------------------------------
static void usage(const char* argv0)
{
	printf(
	"Basic Master Level 3 core simulator\n"
	"\n"
	"Usage: %s [options]\n"
	"\n"
	"  --headless                 run without a window (still renders for screenshots)\n"
	"  --rom <file>               boot0.rom image (default ../roms/mister/bml3_boot0.rom)\n"
	"  --tape <file>              load an .l3 tape image over ioctl (index 1)\n"
	"  --tape-speed N             fast tape: byte rate x 2^N while the motor runs (default 0)\n"
	"  --model l3|mk5             Mark 5 extras ($FFE8 banking, IG) on or off (default mk5)\n"
	"  --dipsw HEX                $FFC9 DIP switches (default 03)\n"
	"  --screenshot N[,N,...]     write screenshot_frame_NNNN.png at these frames\n"
	"  --screenshot-name <path>   override the output path for a single screenshot\n"
	"  --text N[,N,...]           print the 40-column text page as ASCII at these frames\n"
	"  --stop-at-frame N          exit once frame N has been reached\n"
	"  --dump-mem ADDR:LEN@FRAME  snapshot RAM to memdump_*.bin (hex addr and len)\n"
	"  --poke ADDR=BYTES@FRAME    write RAM directly; BYTES is hex, FFx256 repeats\n"
	"  --send-keys N:string       type `string` at frame N (\\n = Return, \\xNN = raw)\n"
	"  --watch-pc ADDR[,ADDR]     count bus accesses to these addresses\n"
	"  --trace-cpu                print every CPU bus cycle (very verbose)\n"
	"  --trace-io                 print accesses to $FF00-$FFEF\n"
	"  --trace-tape               print tape motor changes and bytes delivered\n"
	"  --trace-key                print key codes latched by the scanner\n"
	"  --key-hold MS              how long to hold each injected key (default 50 ms)\n"
	"  -h, --help                 this text\n"
	"\n"
	"Frames are 1/60 s of simulated time from power-on.\n",
	argv0);
}

static std::vector<int> parse_int_list(const std::string& list)
{
	std::vector<int> v;
	size_t pos = 0;
	while (pos <= list.size()) {
		size_t comma = list.find(',', pos);
		std::string tok = list.substr(pos, comma == std::string::npos ? std::string::npos : comma - pos);
		if (!tok.empty()) v.push_back(atoi(tok.c_str()));
		if (comma == std::string::npos) break;
		pos = comma + 1;
	}
	return v;
}

int main(int argc, char** argv, char** env)
{
	Verilated::commandArgs(argc, argv);

	for (int i = 1; i < argc; i++) {
		std::string a = argv[i];
		auto next = [&](const char* what) -> std::string {
			if (i + 1 >= argc) { printf("%s needs an argument\n", what); exit(1); }
			return argv[++i];
		};
		if      (a == "-h" || a == "--help") { usage(argv[0]); return 0; }
		else if (a == "--headless")          headless = true;
		else if (a == "--trace-cpu")         trace_cpu = true;
		else if (a == "--trace-io")          trace_io = true;
		else if (a == "--trace-tape")        trace_tape = true;
		else if (a == "--trace-key")         trace_key = true;
		else if (a == "--key-hold")          key_hold_cycles = (unsigned)(atof(next("--key-hold").c_str()) * (SIM_CLK_HZ / 1000.0));
		else if (a == "--tape-speed")        tape_speed = atoi(next("--tape-speed").c_str());
		else if (a == "--rom")               rom_image = next("--rom");
		else if (a == "--tape")              tape_image = next("--tape");
		else if (a == "--dipsw")             dipsw = strtoul(next("--dipsw").c_str(), nullptr, 16);
		else if (a == "--model") {
			std::string v = next("--model");
			if      (v == "l3")  mark5 = false;
			else if (v == "mk5") mark5 = true;
			else { printf("--model wants l3 or mk5\n"); return 1; }
		}
		else if (a == "--screenshot-name")   screenshot_name = next("--screenshot-name");
		else if (a == "--stop-at-frame")     stop_at_frame = atoi(next("--stop-at-frame").c_str());
		else if (a == "--screenshot")        { auto v = parse_int_list(next("--screenshot")); screenshot_frames.insert(screenshot_frames.end(), v.begin(), v.end()); }
		else if (a == "--text")              { auto v = parse_int_list(next("--text")); text_dump_frames.insert(text_dump_frames.end(), v.begin(), v.end()); }
		else if (a == "--dump-mem") {
			std::string spec = next("--dump-mem");
			unsigned addr = 0, len = 0; int frame = 0;
			if (sscanf(spec.c_str(), "%x:%x@%d", &addr, &len, &frame) != 3) {
				printf("--dump-mem wants ADDR:LEN@FRAME (hex addr/len), e.g. 3000:100@900\n");
				return 1;
			}
			mem_dumps.push_back({ frame, addr, len });
		}
		else if (a == "--poke") {
			std::string spec = next("--poke");
			size_t eq = spec.find('='), at = spec.rfind('@');
			if (eq == std::string::npos || at == std::string::npos || at < eq) {
				printf("--poke wants ADDR=BYTE[,BYTE...]@FRAME, e.g. 2100=FF,FF@600\n");
				return 1;
			}
			MemPoke q;
			q.addr  = strtoul(spec.substr(0, eq).c_str(), nullptr, 16);
			q.frame = atoi(spec.substr(at + 1).c_str());
			std::string list = spec.substr(eq + 1, at - eq - 1);
			size_t pos = 0;
			while (pos <= list.size()) {
				size_t comma = list.find(',', pos);
				std::string tok = list.substr(pos, comma == std::string::npos ? std::string::npos : comma - pos);
				if (!tok.empty()) {
					size_t x = tok.find('x');
					uint8_t v = (uint8_t)strtoul(tok.substr(0, x).c_str(), nullptr, 16);
					unsigned rep = (x == std::string::npos) ? 1 : strtoul(tok.substr(x + 1).c_str(), nullptr, 10);
					for (unsigned r = 0; r < rep; r++) q.bytes.push_back(v);
				}
				if (comma == std::string::npos) break;
				pos = comma + 1;
			}
			mem_pokes.push_back(q);
		}
		else if (a == "--watch-pc") {
			std::string list = next("--watch-pc");
			size_t pos = 0;
			while (pos <= list.size()) {
				size_t comma = list.find(',', pos);
				std::string tok = list.substr(pos, comma == std::string::npos ? std::string::npos : comma - pos);
				if (!tok.empty()) { watch_pcs.push_back(strtoul(tok.c_str(), nullptr, 16)); watch_hits.push_back(0); }
				if (comma == std::string::npos) break;
				pos = comma + 1;
			}
		}
		else if (a == "--send-keys") {
			std::string spec = next("--send-keys");
			size_t colon = spec.find(':');
			if (colon == std::string::npos) { printf("--send-keys wants FRAME:string\n"); return 1; }
			key_injections.push_back({ atoi(spec.substr(0, colon).c_str()),
			                           unescape(spec.substr(colon + 1)) });
		}
		else { printf("Unknown option: %s (try --help)\n", a.c_str()); return 1; }
	}

	if (!screenshot_name.empty() && screenshot_frames.size() != 1) {
		printf("--screenshot-name needs exactly one --screenshot frame\n");
		return 1;
	}

	top = new Vemu();

	bus.ioctl_addr     = &top->ioctl_addr;
	bus.ioctl_index    = &top->ioctl_index;
	bus.ioctl_wait     = &top->ioctl_wait;
	bus.ioctl_download = &top->ioctl_download;
	bus.ioctl_wr       = &top->ioctl_wr;
	bus.ioctl_dout     = &top->ioctl_dout;
	input.ps2_key      = &top->ps2_key;
	input.keyEventWait = key_hold_cycles;
	top->tape_speed = tape_speed;
	top->mark5 = mark5;
	top->dipsw = dipsw;

	{
		FILE* f = fopen(rom_image.c_str(), "rb");
		if (!f) { printf("Cannot open boot ROM %s (see roms/README.md)\n", rom_image.c_str()); return 1; }
		fclose(f);
	}
	printf("Loading boot ROM: %s\n", rom_image.c_str());
	bus.QueueDownload(rom_image, 0, 1);
	if (!tape_image.empty()) {
		printf("Loading tape image: %s\n", tape_image.c_str());
		bus.QueueDownload(tape_image, 1, 1);
	}

	if (!headless) {
		input.Initialise();
		if (video.Initialise("Basic Master Level 3") == 1) return 1;
	} else if (!output_ptr) {
		output_width  = VGA_WIDTH;
		output_height = VGA_HEIGHT;
		output_ptr = (uint32_t*)calloc((size_t)output_width * output_height, 4);
		if (!output_ptr) { fprintf(stderr, "framebuffer alloc failed\n"); return 2; }
	}

	if (headless) {
		printf("Headless mode.\n");
		int last_frame = -1;
		while (true) {
			RunBatch(4096);
			if (sim_frame() != last_frame) {
				last_frame = sim_frame();
				if (frame_actions(last_frame)) return 0;
			}
		}
	}

#ifndef _MSC_VER
	bool done = false;
	bool run_enable = true;
	int  last_frame = -1;

	while (!done) {
		SDL_Event event;
		while (SDL_PollEvent(&event)) {
			ImGui_ImplSDL2_ProcessEvent(&event);
			if (event.type == SDL_QUIT) done = true;
		}

		video.StartFrame();
		ImGui::NewFrame();
		input.Read();

		if (run_enable) RunBatch(200000);

		if (sim_frame() != last_frame) {
			last_frame = sim_frame();
			if (frame_actions(last_frame)) done = true;
		}

		ImGui::Begin("Machine");
		ImGui::Text("Frame %d (video %d)   %.1f fps", sim_frame(), video.count_frame, video.stats_fps);
		ImGui::Text("CPU  PC=%04X A=%04X", top->dbg_cpu_pc, top->dbg_cpu_addr);
		ImGui::Text("tape motor=%d pos=%u", top->dbg_tape_motor, (unsigned)top->dbg_tape_pos);
		ImGui::Checkbox("Run", &run_enable);
		if (ImGui::Button("Reset")) { main_time = 0; top->reset = 1; }
		ImGui::SameLine();
		if (ImGui::Button("Screenshot")) save_screenshot(sim_frame());
		ImGui::End();

		ImGui::Begin("Video");
		ImGui::Image(video.texture_id, ImVec2(VGA_WIDTH * 2, VGA_HEIGHT * 4));
		ImGui::End();

		console.Draw("Log", nullptr, ImVec2(500, 400));
		video.UpdateTexture();
	}

	video.CleanUp();
	input.CleanUp();
#endif
	return 0;
}
