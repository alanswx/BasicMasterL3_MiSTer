# Verilator simulator

Runs the core (`rtl/`) with a stand-in for the MiSTer framework (`sim.v`: hps_io, the
PLL), a PS/2 keyboard, `boot0.rom` and tape/disk images over the same interfaces as on a
MiSTer. It can run headless for scripted tests or in a window (SDL2 + Dear ImGui).

## Building

Needs Verilator (4.2xx or 5.x), SDL2 and a C++ compiler.

```
cd vsim
make
```

`make TRACE=1` adds VCD tracing. The binary is `obj_dir/Vemu`.

## boot0.rom

The simulator loads `boot0.rom` from the current directory (or `--rom <file>`). Make it
with `../tools/make_boot0.py` (see the main README):

```
python3 ../tools/make_boot0.py bml3.zip mbs1.zip bml3mp1802.zip bml3mp1805.zip -o boot0.rom
```

## Running

```
./obj_dir/Vemu --headless --text 120 --screenshot 120 --stop-at-frame 121
./obj_dir/Vemu --headless --send-keys '130:PRINT 12*3+4\n' --text 260 --stop-at-frame 261
./obj_dir/Vemu --headless --model s1 --send-keys '400:CIRCLE (160,100),60,3\n' \
    --screenshot 640 --stop-at-frame 641
./obj_dir/Vemu --headless --tape game.l3 --tape-speed 4 \
    --send-keys '130:LOADM"",,R\n' --trace-tape --screenshot 2300 --stop-at-frame 2301
./obj_dir/Vemu --help
```

* Frames are 1/60 s of simulated time from power-on, not video frames, so they work
  before the CRTC is programmed. Level 3 BASIC reaches `Ready` by about frame 82, S1
  BASIC by about frame 300. Speed is about 19 frames/s.
* `--text N` prints the text page (`$0400`) as 40×25 ASCII; `--screenshot N` writes
  `screenshot_frame_NNNN.png`.
* `--model l3|mk5|s1`, `--s1mode a|b`, `--ram32k`, `--border`, `--interlace`,
  `--keyboard us|jis` mirror the OSD options. `--disk file.d88` (and `--disk1`) mount
  disks and fit the MP-1802 card.
* `--send-keys` types through the core's keyboard queue, paced so the ROM sees each key
  (about 9 characters/s).
* `--trace-io` prints every `$FF00-$FFEF` access with the PC, `--trace-key` the scanner
  latches, `--trace-tape` the tape motor and bytes.
