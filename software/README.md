# Software for the Basic Master Level 3 / MB-S1 core

Collected 2026-10-21. Nothing in this tree has been run. Where each file came from, with
its sha256, is in `SOURCES.md`.

The data on tape structure, load and exec addresses comes from
`l3info.py` (a decoder written for this survey; a copy is kept at
`software/tools/l3info.py`). It decodes `.l3`, `.l3b` and `.l3c` down to tape blocks
and parses the directory of each `.d88`. Raw output for every file (size, sha256 and
blocks) is in `software/analysis.json`.

**Counts (distinct titles or builds):**
- **Level 3, all models, cassette:** 30. That is 23 inufuto games, MELHEN, Cannon
  Ball, Bomber Man, Sasaji's CRTC test, and 3 tool sets.
- **Mark 5 only (IG):** 6. Mazy Mk5, Neuras Mk5, SKATING, BM Tetris, BM Block and
  IG Demo.
- **Level 3 disks (.d88):** 8.
- **MB-S1:** 33. That is 23 inufuto S1 builds, 7 commercial titles (Hudson ×4, Lode
  Runner, Jelda, Volguard), OPNTEST and 2 tool sets.
- **Run in S1 B-mode (documented):** MELHEN, BM Block, 12/25/50lines and the
  FD-YMODEM tools.

## Layout

| Dir | Contents |
|---|---|
| `incoming/` | The original archives, untouched |
| `extracted/<archive>/` | `incoming/*` unpacked. The MAME softlist zips are in `extracted/mame_bml3_{cass,flop}_<name>/` |
| `found/inufuto/<title>/{l3,l3mk5,s1}/` | inufuto's builds: `.l3`, `_l3.zip`, `_wav.zip`, `_src.zip`. Each `*_x/` dir is the unpacked zip |
| `found/archive.org/<item>/` | The Gaming Alexandria / hubz S1 tape uploads (Mario Bros. Special, Nuts & Milk, Princess Tomato) |
| `found/tosec/` | TOSEC 2022-07-10 `Hitachi S1 - Games - [L3B]` and `[L3C]` (the same dumps as archive.org) |
| `found/local_downloads/rocks-preserved-games_Hitachi_S1/` | `~/Downloads/Hitachi S1.zip` (from archive.org `rocks-preserved-games`). Adds **Volguard** |
| `found/gamingalexandria/hitachi5_bml3mk5_GAMES/` | The 2 `.l3` games bundled in GA's 2018 bml3mk5 emulator pack. The pack itself is in `roms/` |
| `found/s-sasaji/` | Sasaji's sample programs and tools (`l3tools.htm`, `s1tools.htm`), the saved tested-software pages, and the ベーマガ L3/S1 type-in index (`bm_index/`) |
| `found/mame_upstream/` | The current MAME `bml3_cass.xml`, `bml3_flop.xml` and **`mbs1_cass.xml`** (new: an S1 cassette softlist) |
| `found/github/inufuto_Cate_examples/` | Sparse clone (`l3/`, `s1/`) of inufuto's C sources for the L3/S1 builds |

System ROMs are not in `software/`. Those found are in `../roms/` (see the end of this
file).

## Recommended first bring-up tests

These are all small cassette loads. They run on a plain Level 3, and each is a known
build that already runs on emulators: inufuto ships his `.l3` files as "for emulators"
and Sasaji tests his own on EmuB.

| # | Title | Why |
|---|---|---|
| 1 | **Mazy** (inufuto, L3 build 2021-06-04), `found/inufuto/mazy/l3/mazy.l3` | 7 KB. One ML file, `$3000-$4875`, exec `$3000`. Touches only `$FFD0` mode, `$FFD3` beeper, `$FFD8` colour and `$FFE0` keyboard. The same game already works on the Jr core. `LOADM "",,R` |
| 2 | **Ascend** (inufuto 2022), `found/inufuto/ascend/l3/ascend.l3` | Same toolchain as Mazy, plus one `$FFC0` (PIA) access. Also in TOSEC |
| 3 | **Ruptus** (inufuto 2020), `found/inufuto/ruptus/l3/Ruptus.l3` | A larger ML image (11.6 KB, up to `$5D89`). Scrolling shooter |
| 4 | **MELHEN** (Micom BASIC 1984-12), `extracted/MELHEN_.../MELHEN (Maison Ikkoku).l3` | Tokenized BASIC (55 lines). Tests `LOAD"MELHEN"` / `RUN`, the BASIC interpreter and `$FFE0` key reads. Also runs on Mark 5 and S1 B-mode |
| 5 | **25lines / 50lines / 12lines** (Sasaji 2012), `found/s-sasaji/50lines/50lines_x/*.l3` | Tiny BASIC programs (about 480 bytes) that reprogram the CRTC (`$FFC6/$FFC7`) for 50 or 12 text rows. A direct HD46505 test. Type `NEWON7` first |
| 6 | **Cannon Ball** (Hudson Soft 1983), `extracted/Cannon-Ball_.../Cannonball.l3` | A commercial title. The BASIC stub `CAN` POKEs `$FFD7,1` (1200 baud), runs `NEWON7` and then LOADMs `CANNON` (`$0B00-$4767`, which loads **through VRAM**; no autoexec). The ML references the CRTC, PIA, `$FFD6` interlace and `$FFE0` |
| 7 | **Lift** or **Cacorm** (inufuto) | More inufuto builds with the minimal I/O set, for regression breadth |
| 8 (Mark 5) | **Mazy (Mark 5 build)**, `found/inufuto/mazy/l3mk5/mazy.l3`, then **BM Tetris** (`found/s-sasaji/bmtetris/bmtetris_x/tetris_all.l3`, also MAME `bmtetris`) | The first IG tests. Mazy Mk5 writes `$FFE9`/`$FFEA`. BM Tetris loads the "IGSYS4" IG character setter, `TETRIGM` at `$7000`, `TETR.M8` at `$6000` (exec `$6300`) and a BASIC main |

Next steps after these: **Bomber Man** (Hudson, built like Cannon Ball), the **MSS Tetris**
disk (the first FDC test, `tetris.d88`, 2D) and **igdemo** (MAME, Mark 5).

## Level 3 / Mark II / Mark 5: cassette

| Title | Author / publisher | Year | Machine | Format | Path | Load | Notes |
|---|---|---|---|---|---|---|---|
| MELHEN | めぞん一刻 (Maison Ikkoku) / Micom BASIC 1984-12, preserved by TWE (Typing Task Force) | 1984 | L3 / Mark 5 / S1 B-mode | .l3 + WAV + readme | `extracted/MELHEN_Hitachi-Basic-Master-Level-3_JA/` | `LOAD "MELHEN"`, `RUN` | Tokenized BASIC, 1469 bytes, lines 10-550. The binary-SAVE prefix is `FF FF FF` |
| SKATING (氷すべり) | Motoaki Tamada / Micom BASIC 1984-12 (Typing Task Force) | 1984 | **Mark 5** (the magazine lists it as "Mark5"; SKATING1 writes IG `$FFE9`/`$FFEA` and defines characters at `$A000`) | .l3 ×2 + WAV | `extracted/Skating_Hitachi-Basic-Master-Level-3_JA/` | `LOAD "SKATING1"`, `RUN`, then `LOAD "SKATING2"`, `RUN` (probable order: SKATING1 is the IG character setter) | BASIC, 910 and 1677 bytes |
| Cannon Ball | Hudson Soft | 1983 | L3 | .l3 | `extracted/Cannon-Ball_Hitachi-Basic-Master-Level-3_JA/Cannonball.l3` | `LOAD`, `RUN` (BASIC `CAN` then LOADMs `CANNON`) | 2 copies on the tape. `CANNON` ML is `$0B00-$4767` with exec `$FFFF` (none). The stub sets 1200 baud via `$FFD7`, so a WAV's second half is at 1200 baud |
| Bomber Man (Eric and the Floaters) | Hudson Soft | 1983 | L3 | .l3 | `extracted/Eric-and-the-Floaters_Hitachi-Basic-Master-Level-3_JA/Bomber Man.l3` | `LOAD`, `RUN` (`BOM` then `BOMB`) | Built like Cannon Ball (`$0B00-$4767`), 2 copies |
| BM Tetris | Sasaji ("Sakn Soft") | 1990 / 2011 | **Mark 5** (IG). The readme says S1 is untested | .l3 + WAV, plus MAME `bmtetris` (FLAC) | `found/s-sasaji/bmtetris/bmtetris_x/tetris_all.l3` (identical to `found/gamingalexandria/.../BM Tetris.l3`); `extracted/mame_bml3_cass_bmtetris/tetris_all.flac` | `LOAD`, `RUN` | 5 files: IGSYS4 (BASIC), TETRIGM (ML `$7000`), TETRIS (BASIC stub), TETR.M8 (ML `$6000-$6BFF`, exec `$6300`), TETR.B2 (BASIC main) |
| BM Block (ブロックくずし) | Sasaji | 2017 | **Mark 5 / S1 B-mode** (IG; on an L3 or Mk II it runs, but the characters are unreadable) | .l3 + source | `found/s-sasaji/bmblock_010/bmblock_010_x/BLOCK_ALL.l3` (identical to GA `BM Block.l3`) | `LOAD`, `RUN` | IGSYS4 + BLOCK_IG (`$7000`) + BLOCK_LD + BLOCK_M (`$6000`) + BLOCK_B. Full 6809 ASM source in `src/` |
| IG Demo | Hitachi? | 1983? | **Mark 5** | FLAC (MAME softlist) | `extracted/mame_bml3_cass_igdemo/igdemo.flac` | (unknown) | No `.l3` exists. It would have to be converted with WavTool |
| 12lines / 25lines / 50lines | Sasaji | 2012 | L3 / S1 B-mode | .l3 | `found/s-sasaji/50lines/50lines_x/` | `NEWON7`, then `LOAD`, `RUN` | **CRTC test**. Reprograms `$FFC6/$FFC7` for 12- or 50-row text. Run `25lines` to restore |
| fd2tape_1s / tape2fd_1s | Sasaji | 2011 | L3 + 3"/5" 1S FDD | .l3 | `found/s-sasaji/fdtool_for_1s/fdtool_for_1s_x/` | `LOAD`, `RUN` | Utilities for copying between disk and tape. They touch `$FFD7` |
| FD YMODEM send (L3 1S v0.10/v0.12, L3 2D, S1 2D, S1 2HD) | Sasaji | 2016 / 2025 | L3 (1S or 2D FDC + RS-232C); S1 versions for S1 | .l3 + ASM source | `found/s-sasaji/fd_ymodem_send_*/` | `LOAD`, `RUN` | Disk-dumping tools that use the ACIA as RS-232C. Useful later as **FDC + ACIA tests**. BASIC + ML at `$6000` (L3) or `$C000` (S1) |
| MKKANJI (L3, v0.11 and 2016) | Sasaji | 2016 / 2025 | L3 + kanji ROM card | .l3 + .BAS + WAV | `found/s-sasaji/mkkanji_l3*/` | `NEWON7`, `LOAD`, `RUN` | Kanji ROM dumper (`$FF75/$FF76`). Saves to tape at 1200 baud (`$FFD7`). Good for testing the kanji card |
| (ベーマガ type-ins) | Micom BASIC Magazine | 1982-1990 | 58 L3, 65 Mark 5, 68 S1 | listings only | `found/s-sasaji/bm_index/pr_bml3.txt` | (n/a) | Sasaji's index of every L3/Mk5/S1 "特選プログラム". None are dumped here except MELHEN and SKATING (the Typing Task Force ones) |

### inufuto (all builds `LOADM "",,R`)

inufuto's page gives `LOADM "",,R` as the run command for every Level 3, Mark 5 and S1
build. The `.l3` / `_l3.zip` files are marked "for emulators" and `_wav.zip` "for real
hardware". All Level 3 builds share one memory layout: a single DECB-style ML segment at
`$3000`, exec `$3000`. The I/O they touch (from a scan of extended-mode operands) is
`$FFD0`, `$FFD3`, `$FFD8` and `$FFE0`, sometimes plus `$FFC0`/`$FFC7`/`$FFE3`. The
Mark 5 builds add `$FFE9`/`$FFEA`. The TOSEC "Jr. Level 3" Ascend/Mazy/Ruptus files are
byte-identical to these.

| Title | Author | Date | Machine | Format | Path | Load | Notes |
|---|---|---|---|---|---|---|---|
| Aerial | inufuto | 2021-10-28 | L3 (all models) | .l3 + WAV | `found/inufuto/aerial/l3/aerial.l3` | `LOADM "",,R` | AERIAL ML $3000-$56AC exec $3000 |
| Aerial (S1 build) | inufuto | 2025-09-27 | S1 (S1 mode) | .l3 + WAV | `found/inufuto/aerial/s1/aerial_l3_x/aerial.l3` | `LOADM "",,R` | 103-byte LOADER at $D000, then a raw stream (see formats). Sept 2025 rebuild "improved using IG" |
| AntiAir | inufuto | 2024-03-31 | L3 (all models) | .l3 + WAV | `found/inufuto/antiair/l3/antiair_l3_x/antiair.l3` | `LOADM "",,R` | ANTIAIR ML $3000-$4780 exec $3000 |
| AntiAir (S1 build) | inufuto | 2024-04-03 | S1 (S1 mode) | .l3 + WAV | `found/inufuto/antiair/s1/antiair_l3_x/antiair.l3` | `LOADM "",,R` | 103-byte LOADER at $D000, then a raw stream (see formats) |
| Ascend | inufuto | 2022-04-21 | L3 (all models) | .l3 + WAV | `found/inufuto/ascend/l3/ascend.l3` | `LOADM "",,R` | ASCEND ML $3000-$4E6D exec $3000 |
| Ascend (S1 build) | inufuto | 2025-09-27 | S1 (S1 mode) | .l3 + WAV | `found/inufuto/ascend/s1/ascend_l3_x/ascend.l3` | `LOADM "",,R` | 103-byte LOADER at $D000, then a raw stream (see formats). Sept 2025 rebuild "improved using IG" |
| Awass | inufuto | 2026-01-14 | L3 (all models) | .l3 + WAV | `found/inufuto/awass/l3/awass_l3_x/awass.l3` | `LOADM "",,R` | AWASS ML $3000-$5467 exec $3000 |
| Awass (S1 build) | inufuto | 2026-01-14 | S1 (S1 mode) | .l3 + WAV | `found/inufuto/awass/s1/awass_l3_x/awass.l3` | `LOADM "",,R` | 103-byte LOADER at $D000, then a raw stream (see formats) |
| Battlot | inufuto | 2021-02-22 | L3 (all models) | .l3 + WAV | `found/inufuto/battlot/l3/battlot.l3` | `LOADM "",,R` | BATTLOT ML $3000-$5557 exec $3000 |
| Battlot (S1 build) | inufuto | 2025-09-27 | S1 (S1 mode) | .l3 + WAV | `found/inufuto/battlot/s1/battlot_l3_x/battlot.l3` | `LOADM "",,R` | 103-byte LOADER at $D000, then a raw stream (see formats). Sept 2025 rebuild "improved using IG" |
| Bootskell | inufuto | 2021-08-26 | L3 (all models) | .l3 + WAV | `found/inufuto/bootskell/l3/bootskell.l3` | `LOADM "",,R` | BOOTSKEL ML $3000-$54DF exec $3000 |
| Bootskell (S1 build) | inufuto | 2025-09-27 | S1 (S1 mode) | .l3 + WAV | `found/inufuto/bootskell/s1/bootskell_l3_x/bootskell.l3` | `LOADM "",,R` | 103-byte LOADER at $D000, then a raw stream (see formats). Sept 2025 rebuild "improved using IG" |
| Cacorm | inufuto | 2022-06-26 | L3 (all models) | .l3 + WAV | `found/inufuto/cacorm/l3/cacorm.l3` | `LOADM "",,R` | CACORM ML $3000-$4F05 exec $3000 |
| Cacorm (S1 build) | inufuto | 2025-09-26 | S1 (S1 mode) | .l3 + WAV | `found/inufuto/cacorm/s1/cacorm_l3_x/cacorm.l3` | `LOADM "",,R` | 103-byte LOADER at $D000, then a raw stream (see formats). Sept 2025 rebuild "improved using IG" |
| Cavit | inufuto | 2021-05-07 | L3 (all models) | .l3 + WAV | `found/inufuto/cavit/l3/cavit.l3` | `LOADM "",,R` | CAVIT ML $3000-$577D exec $3000 |
| Cavit (S1 build) | inufuto | 2025-09-27 | S1 (S1 mode) | .l3 + WAV | `found/inufuto/cavit/s1/cavit_l3_x/cavit.l3` | `LOADM "",,R` | 103-byte LOADER at $D000, then a raw stream (see formats). Sept 2025 rebuild "improved using IG" |
| Cracky | inufuto | 2023-03-18 | L3 (all models) | .l3 + WAV | `found/inufuto/cracky/l3/cracky_l3_x/cracky.l3` | `LOADM "",,R` | CRACKY ML $3000-$4BD2 exec $3000 |
| Cracky (S1 build) | inufuto | 2025-09-28 | S1 (S1 mode) | .l3 + WAV | `found/inufuto/cracky/s1/cracky_l3_x/cracky.l3` | `LOADM "",,R` | 103-byte LOADER at $D000, then a raw stream (see formats). Sept 2025 rebuild "improved using IG" |
| Guntus | inufuto | 2022-10-16 | L3 (all models) | .l3 + WAV | `found/inufuto/guntus/l3/guntus.l3` | `LOADM "",,R` | GUNTUS ML $3000-$598E exec $3000 |
| Guntus (S1 build) | inufuto | 2025-09-28 | S1 (S1 mode) | .l3 + WAV | `found/inufuto/guntus/s1/guntus_l3_x/guntus.l3` | `LOADM "",,R` | 103-byte LOADER at $D000, then a raw stream (see formats). Sept 2025 rebuild "improved using IG" |
| Hopman | inufuto | 2023-07-29 | L3 (all models) | .l3 + WAV | `found/inufuto/hopman/l3/hopman_l3_x/hopman.l3` | `LOADM "",,R` | HOPMAN ML $3000-$4E5F exec $3000 |
| Hopman (S1 build) | inufuto | 2025-09-28 | S1 (S1 mode) | .l3 + WAV | `found/inufuto/hopman/s1/hopman_l3_x/hopman.l3` | `LOADM "",,R` | 103-byte LOADER at $D000, then a raw stream (see formats). Sept 2025 rebuild "improved using IG" |
| Impetus | inufuto | 2021-07-23 | L3 (all models) | .l3 + WAV | `found/inufuto/impetus/l3/impetus.l3` | `LOADM "",,R` | IMPETUS ML $3000-$689A exec $3000 |
| Impetus (S1 build) | inufuto | 2025-09-28 | S1 (S1 mode) | .l3 + WAV | `found/inufuto/impetus/s1/impetus_l3_x/impetus.l3` | `LOADM "",,R` | 103-byte LOADER at $D000, then a raw stream (see formats). Sept 2025 rebuild "improved using IG" |
| Lift | inufuto | 2021-12-27 | L3 (all models) | .l3 + WAV | `found/inufuto/lift/l3/lift.l3` | `LOADM "",,R` | LIFT ML $3000-$4C6E exec $3000 |
| Lift (S1 build) | inufuto | 2025-09-26 | S1 (S1 mode) | .l3 + WAV | `found/inufuto/lift/s1/lift_l3_x/lift.l3` | `LOADM "",,R` | 103-byte LOADER at $D000, then a raw stream (see formats). Sept 2025 rebuild "improved using IG" |
| Mazy | inufuto | 2021-06-04 | L3 (all models) | .l3 + WAV | `found/inufuto/mazy/l3/mazy.l3` | `LOADM "",,R` | MAZY ML $3000-$4875 exec $3000 |
| Mazy (Mark 5 build) | inufuto | 2020-08-29 | Mark 5 only (IG) | .l3 + WAV | `found/inufuto/mazy/l3mk5/mazy.l3` | `LOADM "",,R` | MAZY ML $3000-$4FF9 exec $3000; writes $FFE9/$FFEA (IG) |
| Mazy (S1 build) | inufuto | 2025-09-28 | S1 (S1 mode) | .l3 + WAV | `found/inufuto/mazy/s1/mazy_l3_x/mazy.l3` | `LOADM "",,R` | 103-byte LOADER at $D000, then a raw stream (see formats). Sept 2025 rebuild "improved using IG" |
| Mazy2 | inufuto | 2025-05-17 | L3 (all models) | .l3 + WAV | `found/inufuto/mazy2/l3/mazy2_l3_x/mazy2.l3` | `LOADM "",,R` | MAZY2 ML $3000-$526B exec $3000 |
| Mazy2 (S1 build) | inufuto | 2025-05-17 | S1 (S1 mode) | .l3 + WAV | `found/inufuto/mazy2/s1/mazy2_l3_x/mazy2.l3` | `LOADM "",,R` | 103-byte LOADER at $D000, then a raw stream (see formats) |
| Mieyen | inufuto | 2025-01-09 | L3 (all models) | .l3 + WAV | `found/inufuto/mieyen/l3/mieyen_l3_x/mieyen.l3` | `LOADM "",,R` | MIEYEN ML $3000-$4D67 exec $3000 |
| Mieyen (S1 build) | inufuto | 2025-01-10 | S1 (S1 mode) | .l3 + WAV | `found/inufuto/mieyen/s1/mieyen_l3_x/mieyen.l3` | `LOADM "",,R` | 103-byte LOADER at $D000, then a raw stream (see formats) |
| Neuras | inufuto | 2021-06-02 | L3 (all models) | .l3 + WAV | `found/inufuto/neuras/l3/Neuras.l3` | `LOADM "",,R` | NEURAS ML $3000-$5112 exec $3000 |
| Neuras (Mark 5 build) | inufuto | 2020-09-04 | Mark 5 only (IG) | .l3 + WAV | `found/inufuto/neuras/l3mk5/Neuras.l3` | `LOADM "",,R` | NEURAS ML $3000-$5B5A exec $3000; writes $FFE9/$FFEA (IG) |
| Neuras (S1 build) | inufuto | 2025-09-27 | S1 (S1 mode) | .l3 + WAV | `found/inufuto/neuras/s1/neuras_l3_x/neuras.l3` | `LOADM "",,R` | 103-byte LOADER at $D000, then a raw stream (see formats). Sept 2025 rebuild "improved using IG" |
| Osotos | inufuto | 2024-08-21 | L3 (all models) | .l3 + WAV | `found/inufuto/osotos/l3/osotos_l3_x/osotos.l3` | `LOADM "",,R` | OSOTOS ML $3000-$50F6 exec $3000 |
| Osotos (S1 build) | inufuto | 2024-08-22 | S1 (S1 mode) | .l3 + WAV | `found/inufuto/osotos/s1/osotos_l3_x/osotos.l3` | `LOADM "",,R` | 103-byte LOADER at $D000, then a raw stream (see formats) |
| Ruptus | inufuto | 2020-12-26 | L3 (all models) | .l3 + WAV | `found/inufuto/ruptus/l3/Ruptus.l3` | `LOADM "",,R` | RUPTUS ML $3000-$5D89 exec $3000 |
| Ruptus (S1 build) | inufuto | 2025-09-28 | S1 (S1 mode) | .l3 + WAV | `found/inufuto/ruptus/s1/ruptus_l3_x/ruptus.l3` | `LOADM "",,R` | 103-byte LOADER at $D000, then a raw stream (see formats). Sept 2025 rebuild "improved using IG" |
| Svellas | inufuto | 2025-08-17 | L3 (all models) | .l3 + WAV | `found/inufuto/svellas/l3/svellas_l3_x/svellas.l3` | `LOADM "",,R` | SVELLAS ML $3000-$504B exec $3000 |
| Svellas (S1 build) | inufuto | 2025-08-17 | S1 (S1 mode) | .l3 + WAV | `found/inufuto/svellas/s1/svellas_l3_x/svellas.l3` | `LOADM "",,R` | 103-byte LOADER at $D000, then a raw stream (see formats) |
| SwordWork | inufuto | 2026-04-28 | L3 (all models) | .l3 + WAV | `found/inufuto/sword/l3/sword_l3_x/sword.l3` | `LOADM "",,R` | SWORD ML $3000-$51FC exec $3000 |
| SwordWork (S1 build) | inufuto | 2026-04-28 | S1 (S1 mode) | .l3 + WAV | `found/inufuto/sword/s1/sword_l3_x/sword.l3` | `LOADM "",,R` | 103-byte LOADER at $D000, then a raw stream (see formats) |
| Uchotos | inufuto | 2026-08-26 | L3 (all models) | .l3 + WAV | `found/inufuto/uchotos/l3/uchotos_l3_x/uchotos.l3` | `LOADM "",,R` | UCHOTOS ML $3000-$4E0E exec $3000 |
| Uchotos (S1 build) | inufuto | 2026-08-27 | S1 (S1 mode) | .l3 + WAV | `found/inufuto/uchotos/s1/uchotos_l3_x/uchotos.l3` | `LOADM "",,R` | 103-byte LOADER at $D000, then a raw stream (see formats) |
| Yewdow | inufuto | 2023-11-22 | L3 (all models) | .l3 + WAV | `found/inufuto/yewdow/l3/yewdow_l3_x/yewdow.l3` | `LOADM "",,R` | YEWDOW ML $3000-$4F9C exec $3000 |
| Yewdow (S1 build) | inufuto | 2025-09-29 | S1 (S1 mode) | .l3 + WAV | `found/inufuto/yewdow/s1/yewdow_l3_x/yewdow.l3` | `LOADM "",,R` | 103-byte LOADER at $D000, then a raw stream (see formats). Sept 2025 rebuild "improved using IG" |

(The inufuto S1 builds are listed in the table above with the L3 builds. inufuto
calls the machine just "S1"; the builds write S1 extended I/O at `$FE02`/`$FE03`/
`$FE23`/`$FE24` and `$FFD0`/`$FFD4`, so they run in S1 mode, not B-mode.)

## Level 3: disks (`.d88`)

Every disk has a D88 header with 164 track slots and 80 tracks present. "2D" below
means 40 cylinders × 2 heads × 16 sectors of 256 bytes (MFM). Track 0 side 0 is
16 × 128 bytes FM, the LEVEL-3 DISK BASIC boot track. The D88 media byte is `0x10`
("2DD") on most of them; that is a header quirk, and the layout is 2D. Directories are
read from cylinder 20, logical sectors 5-23 (2D) or 7-16 (1S), using 32-byte entries
(name 8, ext 3, type, ascii flag, start cluster). The layout is from L3DiskEx's
`basic_types.xml` and `basiccommon.h`.

| Title | Publisher | Year | Machine | Format | Path | Load | Notes |
|---|---|---|---|---|---|---|---|
| Tetris (`jedwidz-tetris`) | homebrew | 1991 | L3 + MP-1802 5" 2D | d88, 2D | `extracted/mame_bml3_flop_tetris/tetris.d88` (identical to the MSS `.7z` copy) | Disk boot (LEVEL-3 DISK BASIC), then `RUN"TETRIS"` | 23 files: TETRIS.BAS, TETRIS2.BAS, EDIT.BAS, ROUTINES.BIN, SOUNDFX.BIN, TETRISP1.PIC, LEV 1-15.TRS, SCRS.TRS. MAME `tetris`. Best first disk test |
| HI-Writer 1.5 + data disk | Hisoft Pty. Ltd. | 19?? | L3 + 2D | d88 2D + d88 (hidata: 80 trk × 16 × 128 MFM, no BASIC directory) | `extracted/mame_bml3_flop_hiwriter/` (identical to the MSS copies) | Disk boot | 35 directory entries (UTILITY.BAS, FILECOPY.UTL, DISKCOPY.UTL, FORMAT.UTL, ...). The data disk uses a non-DISK-BASIC format |
| Disk BASIC and Utilities | ? | 19?? | L3 + 2D | d88 2D | `extracted/mame_bml3_flop_dbu/dbu.d88` | Disk boot | 10 files: UTILITY.BAS, FILECOPY/DISKCOPY/VOL-COPY/DISKDUMP/LPTFILES/CONFIG/FORMAT.UTL |
| MA-5370 Disk BASIC 1.1 | Hitachi | 19?? | L3 + **1S** (3"/5" single density, MP-1805) | d88 "2D" header, but every track is 16 × 128 FM | `extracted/mame_bml3_flop_ma5370/ma5370.d88` | Disk boot | MAME marks it baddump ("all tracks hacked to single density"). 13 files: UTILITY, DSKCOPY1/2, DISKIO32/40, SYSCOPY, SYSIO32/40, CONFIG, FORMAT, SKIP2, AUTO, REAUTO |
| FCG6890 | ? | 19?? | L3 + 2D | d88 2D | `extracted/mame_bml3_flop_fcg6890/fcg6890.d88` | Disk boot | FCG6890.BIN + an autorun BAS. MAME: partial |
| Insect Hunter | ? | 1986 | L3 + 2D | d88 2D | `extracted/mame_bml3_flop_insecth/insecth.d88` | Disk boot | INSECT.BIN + BAS |
| Japanese Word Processor | ? | 1985 | L3 + 2D (+ kanji ROM, presumably) | d88 2D | `extracted/mame_bml3_flop_jwp/jwp.d88` | Disk boot | WP.BIN, INTRO.BIN, BAS |
| Submarine Treasures Pick Up | ? | 1985 | L3 + 2D | d88 2D | `extracted/mame_bml3_flop_subtreas/subtreas.d88` | Disk boot | STPU.BAS, PATCHED.BAS |

## MB-S1: cassette

| Title | Publisher | Year | Machine | Format | Path | Load | Notes |
|---|---|---|---|---|---|---|---|
| Mario Bros. Special | Hudson Soft | 1984 | S1 | .l3b (+ WAV on archive.org, not downloaded) | `found/archive.org/mariobrosspecialhitachis1/..._x/Mario Bros. Special (Hitachi S1) [CT].l3b` (= TOSEC "Super Mario Bros. Special [MA-1006]") | `LOAD`, `RUN` (per the GA readme) | Standard blocks: `LOADER` (ASCII BASIC, 43 B) and `LOADER/M` (ML `$C000-$C1FF`, exec `$C000`). The rest of the tape is Hudson's own format, which does not decode as `01 3C` blocks at either speed. MAME `mbs1_cass: mariosp` |
| Nuts & Milk | Hudson Soft | 1984 | S1 | .l3b | `found/archive.org/nutsandmilkhitachis1/..._x/` (= TOSEC [MA-3202]) | `LOAD`, `RUN` | Same loader as Mario Bros. Special. MAME `nutsmilk` |
| Princess Tomato in the Salad Kingdom (サラダの国のトマト姫) | Hudson Soft | 1984 | S1 | .l3c ×3 | `found/archive.org/princesstomatointhesaladkingdomhitachis1/..._x/` (= TOSEC [MA-3204-1..3]) | `LOAD`, `RUN` (tape 1) | Same Hudson LOADER (50 B) + LOADER/M. These `.l3c` contain `H`/`L` run markers (see formats). MAME `tomathim` |
| Dezeni Land | Hudson Soft | 1984? | S1 | .l3c ×3 | `extracted/Dezeni-Land_Hitachi-S1_JA/` | `LOAD`, `RUN` (tape 1) | Same Hudson LOADER (34 B) + LOADER/M `$C000` scheme. Contains `G`/`L` markers |
| Lode Runner | ? | 198? | S1 | .l3b + .l3c + WAV (Program, Data) | `extracted/Lode-Runner_Hitachi-S1_JA/` | `LOAD`, `RUN` | Program: LODE1 (BASIC, **600 baud**), then LODE2 (BASIC), LODE3 (ML `$7000-$7FFF`) and LODE4 (ML `$6000-$BFFF`, exec `$7000`), all at **1200 baud**. Data: KYOCHAN (ML 9690 B, loads at `$0000`, 2 copies; the first has a bad checksum). **Mixed baud on one tape** |
| Jelda | ? | 198? | S1 | .l3b + WAV | `extracted/Jelda_Hitachi-S1_JA/` | `LOAD`, `RUN` | `A` = **protected BASIC** (binary-SAVE prefix `FE`, encrypted), then `JELDA` ML (27.6 KB, header says `$5678-$C27D`, exec `$ABCD`; looks deliberately obfuscated), then a trailing "Protected by HaHi..." fragment. One data block has a bad checksum in the l3b |
| Volguard | dB-Soft | 1984? | S1 | .l3b + WAV (33 min) | `found/local_downloads/rocks-preserved-games_Hitachi_S1/Hitachi S1_x/Hitachi S1/Volguard (Hitachi S1) [CT].l3b` | `LOAD`, `RUN` | **New find** (not in the TODO list). BASIC `VOLGUARD` POKEs `$FFEA` and LOADMs VOLPCG-B/R/G (`$5000`), VOL_LOAD (`$DF00`, autorun), VOL_PUT (`$5000-$AFFF`) and VOL (`$A000-$DEFF`). 2 copies. Also on archive.org as `[No-Intro] Hitachi - S1 (Waveform)` |
| OPNTEST (FM sound test) | Sasaji | 2017-2021 | S1 + YM2203 card (I/O 1985-06) | .l3 + source | `found/s-sasaji/opntest_022/opntest_022_x/` | `LOAD`, `RUN` | `OPNTEST_ALL` (card at `$FF1E/$FF1F`, 3.58 MHz), `_2M` (2 MHz), `_EX` (extended PSG port `$FFE6/$FFE7`). BASIC + OPNPLAY ML `$B000` + GRA1 `$B800`. **A sound-card test** |
| MKKANJI (S1) | Sasaji | 2016 / 2025 | S1 + kanji ROM | .l3 | `found/s-sasaji/mkkanji_s1*/` | `LOAD`, `RUN` | Kanji ROM dumper for the S1 |

## Tape and disk format notes

All of this was checked by decoding every file with `tools/l3info.py`, and against
Sasaji's help page (`l3help/notes.htm`) and the EmuB-S1/WavTool parsers.

**`.l3`** (binary). This is the serial byte stream with the start and stop bits removed.
It is baud-agnostic: nothing in the file records 600 or 1200 baud.
- Leader: about 90 `$FF` bytes before the header and between files (inufuto and
  Sasaji); 10 in the Hudson/S1 dumps.
- Block: `$01 $3C` sync, then type, length (0-255), data[length], then a checksum.
  The checksum is `(type + length + sum(data)) & $FF`. It verified on all of the
  roughly 1,850 blocks in the `.l3` files; the only failures were false `01 3C`
  matches inside the inufuto S1 raw stream.
  - Type `$00` is the header (length `$14` = 20): name[8] padded with spaces, then the
    file type (`$00` BASIC, `$01` data, `$02` machine code) and the ASCII flag (`$FF` =
    ASCII), then a third byte that is `$FF` only in the Hudson ASCII `LOADER` files
    (`01 FF FF`, probably the gap flag, as on CoCo). The rest of the 20 bytes are 0.
    Unlike CoCo DECB there are **no load or exec addresses in the header**.
  - Type `$01` is data. Blocks are 255 bytes except the last.
  - Type `$FF` is the end block, length 0, checksum `$FF`.
- A few `$00` bytes and more `$FF` leader follow the end block.
- **Machine-code files** carry CoCo/DECB-style segments in the data stream:
  `$00 lenH lenL addrH addrL <data>` ... then `$FF $00 $00 execH execL`. Every file
  seen has a single segment. Exec `$FFFF` means no autoexec (Hudson).
  `LOADM "",,R` runs the exec address.
- **Tokenized BASIC** data starts with a prefix: `FF FF FF` for normal binary SAVEs
  (every L3 example) and `FE ...` for protected or encrypted programs (Jelda). Then
  come Microsoft-style lines: next-line link (2 bytes, big endian), line number
  (2 bytes), tokens, `$00`, ending with a `$0000` link. The links reflect the RAM
  location at SAVE time (MELHEN, 25lines and so on imply the text started at `$4768`
  on the saving machine), so the loader must relink.

**`.l3b`** (ASCII). One character per serial bit. Lines are 110-116 characters
(constant within a file) and end in CRLF. The leader is a long run of `1`. Each frame
is start `0`, 8 data bits LSB first, then **2 stop bits** `11` (the measured
inter-frame idle is mostly exactly 2, with long `1` runs in gaps). Decoding the frames
gives exactly the `.l3` byte stream. Nothing in the file gives the bit rate either;
Lode Runner's `.l3b` holds 600- and 1200-baud segments without marking which is which.

**`.l3c`** (ASCII). One character per carrier sample at 4800 Hz (EmuB uses 4800 ×
(speed+1), so it treats the file as 9600 Hz in 1200-baud mode). Lines are 80
characters (89-91 in the Princess Tomato files) with CRLF. A 1200 Hz cycle is
`1100`/`0011` and a 2400 Hz cycle is `1010`/`0101`.
- At 600 baud a bit is 8 samples: `0` = 2 cycles of 1200 Hz, `1` = 4 cycles of 2400 Hz.
- At 1200 baud a bit is 4 samples: `0` = 1 cycle of 1200 Hz, `1` = 2 cycles of 2400 Hz.
- Lode Runner switches from 8-sample bits (LODE1) to 4-sample bits (LODE2-4) partway
  through one file, so a converter must re-detect the bit length per block.
- Some files also contain **`G`, `H` and `L` characters** that EmuB does not
  document. Dezeni Land has a dozen `GG`/`LL`/`LLGGLL`; Princess Tomato has thousands
  of `HH`/`LL`/`LLLL`, mostly in the noisy pre-leader region. EmuB's reader counts
  every non-CR/LF character as a sample, and its pattern matcher only matches
  `0`/`1` patterns, so these behave as dropouts or noise. They are probably level or
  gap annotations from the dumping tool. A converter should treat them as
  "not 0/1".

**WAV.** Mostly 48 kHz 8-bit mono (inufuto and TTF), or 44.1 kHz 8-bit mono (the
Gaming Alexandria S1 dumps). A few are 44.1 kHz 16-bit stereo or 48 kHz 16-bit mono.

**Hudson S1 loader scheme** (Mario Bros. Special, Nuts & Milk, Princess Tomato and
Dezeni Land): a standard ASCII BASIC `LOADER`, then `LOADER/M`, a 512-byte ML loader
at `$C000` (exec `$C000`), then data in a non-standard format. It does not decode at
600 or 1200 baud as `$01 $3C` blocks; it is probably a different speed or encoding.
The core's ACIA/tape path must be bit-accurate, not just block-level, for these to
load from WAV/l3b/l3c. A `.l3` conversion of them would lose the turbo part.

**inufuto S1 loader scheme**: a standard ML `LOADER` (103 bytes, `$D000-$D05C`,
exec `$D000`), then after the end block: `00 00 00 00`, a run of `$C9` sync bytes,
then `addrH addrL lenH lenL` (Mazy: `$4000`, `$2635`) and raw bytes with no block
framing. The `.l3` keeps this as bytes, so a byte-level `.l3` → ACIA feeder handles
it, but a block-level loader would not.

**D88.** See the disk table. L3/S1 DISK BASIC 2D: 40 cyl × 2 sides × 16 × 256 bytes,
track 0 side 0 FM 16 × 128, FAT on cylinder 20 side 0 sector 2, directory in sectors
5-23. 1S: 16 × 128 bytes per track, directory in sectors 7-16.

## System ROMs encountered (in `../roms/`, not in `software/`)

| Path | What |
|---|---|
| `roms/archive.org-hitachis1biosfiles/` | archive.org `hitachis1biosfiles` / `hitachi-s1-bios`: `[BIOS] Hitachi S1.zip` (FONT.ROM, ROM1.ROM, ROM2.ROM, S1BAS1.ROM, S1ROM2.ROM, S1ROMI.ROM). Placed there by the ROM agent; the same zip was found here |
| `roms/local_downloads_bml3mk5_win32_191/` | From `~/Downloads/bml3mk5_win32_191/` (the GA Typing Task Force emulator pack): `598_p16611.ic3`, `599_p16561.ic4`, `600_p16681.ic5` (MAME names), `l3bas.rom` (24 KB), `font.rom` (and `tool_FONT.ROM`, identical) |
| `roms/gamingalexandria_typingtaskforce/bml3mk5_win32_191.zip` | Byte-identical to `~/Downloads/bml3mk5_win32_191.zip`. Contains `l3bas.rom` and `font.rom` |
| `roms/gamingalexandria_hitachi5/bml3mk5.zip` | GA's 2018 bml3mk5 pack: `l3bas.rom`, `font.rom`, `kanji.rom` (128 KB), **`mp1802.rom` and `mp1805.rom`** (FDC boot ROMs, 2 KB each), plus `BM Block.l3` and `BM Tetris.l3` |
| `roms/github_hi631_BASIC_MASTER_LEVEL3/` | `L3FONT.HEX` and `EXT_BASIC.HEX` (Intel HEX) from hi631's DE10 VGA project. `EXT_BASIC` looks like hi631's own extension code, not Hitachi BASIC |
| `roms/github_kwhr0_MB-S1/S1FONT.ROM` | 8 KB font from kwhr0/MB-S1 (an EmuB-S1 fork with a 6309 core). Possibly generated by its `mkfont` scripts |

## Searched but not found

- **TOSEC L3 or Mark 5 sets** beyond the 2022-06-08 "Jr. Level 3" (inufuto) set. TOSEC
  has no `Hitachi Basic Master Level 3` folder. The S1 sets are just the 3 Hudson titles.
- **No Neo Kobe Hitachi collection exists.** The archive.org Neo Kobe uploads cover only
  PC-6001/8001/8801/9801, FM-7, FM Towns, X1 and X68000. The X1 research dump in
  `~/dev2/SharpX1_Mister/references/local/research_20261018/` came from archive.org
  `Neo_Kobe_Sharp_X1_2016-02-25` (`neokobe_l.txt` is its `unzip -l` listing).
- **Typing Task Force / Gaming Alexandria**: their entire L3/S1 output is MELHEN,
  Skating, Cannonball and Bomber Man (`/hitachi5/`), plus the Hudson S1 trio. All of it
  is now in hand. The TTF S1 category holds only MELHEN.
- **Jelda, Lode Runner and Dezeni Land provenance**: they reach us via a
  "rocks-preserved-games" repack; their original dumper and publisher are not stated.
- **retropc.net**: the front page is a server-maintenance notice. No L3/S1 section was
  found.
- **Japanese hobbyist pages** (ued.cc, haserin09, vcraft, nekocanmac) have no
  downloads. Most ベーマガ L3/S1 type-ins (191 listed) are undumped.
- **Homebrew on GitHub**: apart from inufuto and Sasaji, there are only emulators
  (shippoiincho/bml3emulator for Pico, kwhr0/MB-S1, hi631's DE10 VGA L3 project) and
  kwhr0/mid2l3 (a MIDI-to-.l3 player generator, source only). No CPU-test or
  video-mode-test programs for L3/S1 turned up; 50lines and OPNTEST are the closest.
- **MAME**: `bml3_cass` has 2 entries, `bml3_flop` 8 and `mbs1_cass` 3 (Mario,
  Nuts & Milk, Tomato; WAV-based, all `supported="no"`). Every title is in hand.
