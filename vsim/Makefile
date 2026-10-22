V = verilator

TOP   = --top-module emu
RTL   = ../rtl
V_INC =

# NOTE: no -I/-y search path on purpose. Every source is listed explicitly in
# V_SRC below.
V_DEFINE = +define+SIMULATION=1 \
	-CFLAGS "-I../sim/imgui -I../sim/vinc -I../sim/ -g" \
	--timescale-override 1ps/1ps \
	-Wno-TIMESCALEMOD -Wno-PINMISSING -Wno-UNSIGNED -Wno-WIDTH -Wno-fatal

# VCD tracing costs runtime even when idle; opt in with `make TRACE=1`.
ifeq ($(TRACE),1)
V_DEFINE += --trace
CXX_DEFINE += -DVM_TRACE_VCD=1
else
CXX_DEFINE += -DVM_TRACE_VCD=0
endif

UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S), Darwin)
	LIBS += -framework OpenGL -framework Cocoa -framework IOKit -framework CoreVideo `sdl2-config --libs`
	LIBS += -L/usr/local/lib -L/opt/local/lib -L/opt/homebrew/lib
	CXXFLAGS += `sdl2-config --cflags`
	CXXFLAGS += `sdl2-config --cflags | sed 's|include/SDL2|include/|'`
	CXXFLAGS += -I/usr/local/include -I/opt/local/include -I/opt/homebrew/include
endif

ifeq ($(UNAME_S), Linux)
	LIBS += -lGL -ldl `sdl2-config --libs`
	CXXFLAGS += `sdl2-config --cflags`
endif

CC_OPT    = -O2
V_OPT     = -O3 --x-assign fast --x-initial fast --noassert
CXXFLAGS += $(CC_OPT) $(CXX_DEFINE) -Isim/imgui
LDFLAGS   = $(LIBS)
EXE       = ./obj_dir/Vemu

V_SRC = \
	sim.v \
	$(RTL)/dpram.v \
	$(RTL)/core.v \
	$(RTL)/mc6809is.v \
	$(RTL)/crtc6845.v \
	$(RTL)/video.v \
	$(RTL)/acia6850.v \
	$(RTL)/keyboard.v \
	$(RTL)/tape.v \
	$(RTL)/mp1802.v \
	$(RTL)/wd1793.sv \
	$(RTL)/wd_dpram.v \
	$(RTL)/psg6.v \
	$(RTL)/jt49/jt49_bus.v $(RTL)/jt49/jt49.v $(RTL)/jt49/jt49_cen.v \
	$(RTL)/jt49/jt49_div.v $(RTL)/jt49/jt49_eg.v $(RTL)/jt49/jt49_exp.v \
	$(RTL)/jt49/jt49_noise.v

C_SRC = \
	sim_main.cpp \
	sim/sim_bus.cpp sim/sim_clock.cpp sim/sim_console.cpp sim/sim_video.cpp \
	sim/sim_input.cpp sim/sim_audio.cpp sim/sim_blkdevice.cpp \
	sim/imgui/imgui_impl_sdl.cpp sim/imgui/imgui_impl_opengl2.cpp \
	sim/imgui/imgui_draw.cpp sim/imgui/imgui_widgets.cpp sim/imgui/imgui_tables.cpp \
	sim/imgui/imgui.cpp sim/imgui/ImGuiFileDialog.cpp \
	sim/imgui/implot.cpp sim/imgui/implot_items.cpp

VOUT = obj_dir/Vemu.cpp

all: $(EXE)

$(VOUT): $(V_SRC) Makefile
	$V -cc $(V_OPT) -LDFLAGS "$(LDFLAGS)" -exe --Mdir ./obj_dir \
		$(V_DEFINE) $(V_INC) $(TOP) -CFLAGS "$(CXXFLAGS)" $(V_SRC) $(C_SRC)

$(EXE): $(VOUT) $(C_SRC)
	(cd obj_dir; make -f Vemu.mk OBJCACHE= OPT_FAST="-O2" OPT_SLOW="-O0" OPT_GLOBAL="-O2")

clean:
	rm -rf obj_dir

.PHONY: all clean
