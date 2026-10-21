# Sources: emulators, tools and hardware repos

Retrieved 2026-10-21 by the emulator-research agent. Every git repo is a full clone with history
(`git clone`, default branch). Nothing downloaded was executed. EmuB-6892 and EmuB-S1 were *built*
from a copy in the session scratchpad, but the result was not run.

Licence: EmuB-6892 and EmuB-S1 ship `src/COPYING.txt` (GNU GPL v2). The other bml3mk5 repos carry
the same "free software, copyright retained" disclaimer.

## Git repositories (GitHub user `bml3mk5`, 21 repos, all cloned)

Emulators and tools are in `ref/emulators/`. Hardware (card designs, KiCad/EAGLE, PDF readmes) is
in `ref/hardware/`. `eCZ-600` (Sharp X68000 emulator, in development) and `DiFinder` (hard-disk
image tool) are not L3-related; they were cloned for completeness.

| Repo | Local path | Commit | Last commit | Latest tag | Description |
|---|---|---|---|---|---|
| [DiFinder](https://github.com/bml3mk5/DiFinder) | `ref/emulators/DiFinder` | `11ffc5166b93` | 2026-08-14 | V0.0.6 | This is an application in order to access to files in a hard disk image for a retro computer. |
| [eCZ-600](https://github.com/bml3mk5/eCZ-600) | `ref/emulators/eCZ-600` | `9a2a6f992c6f` | 2025-10-12 | b489 |  |
| [EmuB-6892](https://github.com/bml3mk5/EmuB-6892) | `ref/emulators/EmuB-6892` | `0bd0afe8a32e` | 2026-07-12 | V2.1.4 | This is an emulator of HITACHI BASIC MASTER LEVEL3 MARK5. |
| [EmuB-S1](https://github.com/bml3mk5/EmuB-S1) | `ref/emulators/EmuB-S1` | `6a2eb1cdab15` | 2026-07-12 | V0.9.4 | This is an emulator that behaves like Hitachi MB-S1. |
| [L3DiskEx](https://github.com/bml3mk5/L3DiskEx) | `ref/emulators/L3DiskEx` | `9f38a7276b06` | 2026-10-01 | V0.8.6 | This is an application in order to access to files in a floppy disk image for retro computer and operating system. |
| [L3S1Basic](https://github.com/bml3mk5/L3S1Basic) | `ref/emulators/L3S1Basic` | `445d73c8336c` | 2025-10-19 | V0.8.2 | This is an application that converts text files to intermediate language format or ASCII format data, and vice versa. For LEVEL-3 BASIC of the Hitachi Basic Master Level 3 series and S1 BASIC of the MB-S1 series. |
| [MPPrinter](https://github.com/bml3mk5/MPPrinter) | `ref/emulators/MPPrinter` | `1b3b26300c90` | 2025-10-19 | V0.5.1 | This software is a printer emulator for viewing and printing data files using old-fashioned printer fonts. |
| [WavTool](https://github.com/bml3mk5/WavTool) | `ref/emulators/WavTool` | `dbdaf5b6f5b5` | 2026-01-31 | V0.6.7 | WAVTOOL is an application that converts tape audio data on Hitachi Basic Master Level 3 and MB-S1 and tape images which used in these emulators. |
| [L3KanjiRom](https://github.com/bml3mk5/L3KanjiRom) | `ref/hardware/L3KanjiRom` | `10022e893ef5` | 2026-08-23 |  | Kanji ROM Card for HITACHI BASIC MASTER LEVEL3 |
| [L3mk5ExRam](https://github.com/bml3mk5/L3mk5ExRam) | `ref/hardware/L3mk5ExRam` | `844b43ec375a` | 2023-03-06 |  | External Memory Card for HITACHI BASIC MASTER LEVEL3 mark5 |
| [L3PSG6n9Voices](https://github.com/bml3mk5/L3PSG6n9Voices) | `ref/hardware/L3PSG6n9Voices` | `51561078d670` | 2023-11-27 |  | PSG6&9Voices Card for HITACHI BASIC MASTER LEVEL3 |
| [L3S1VirtualFloppy](https://github.com/bml3mk5/L3S1VirtualFloppy) | `ref/hardware/L3S1VirtualFloppy` | `4277fb2b3ec1` | 2026-02-03 |  | Virtual Floppy Card for HITACHI Basic Master Level3 / MB-S1 |
| [MP1800Gotek](https://github.com/bml3mk5/MP1800Gotek) | `ref/hardware/MP1800Gotek` | `8e32c5383e2f` | 2026-08-24 | R0.2.2 | This is an interface board connecting between a floppy disk drive and MP-1800 / MP-1805, the FD interface card on a PC. You can use this on HITACHI BASIC MASTER LEVEL3 / Mark II / Mark5. |
| [MP1802Gotek](https://github.com/bml3mk5/MP1802Gotek) | `ref/hardware/MP1802Gotek` | `a3a406521ce4` | 2026-08-24 | R0.1.2 | This is an interface board connecting between a floppy disk drive and MP-1802 / MP-1870, the FD interface card on a PC. You can use this on HITACHI BASIC MASTER LEVEL3 / Mark II / Mark5 and MB-S1. |
| [S1ExmemAndFmOPN](https://github.com/bml3mk5/S1ExmemAndFmOPN) | `ref/hardware/S1ExmemAndFmOPN` | `8b96cbdd7162` | 2023-07-10 |  | Extended RAM & FM Synthesis Card for HITACHI MB-S1 |
| [S1ExmemAndFmOPN3L](https://github.com/bml3mk5/S1ExmemAndFmOPN3L) | `ref/hardware/S1ExmemAndFmOPN3L` | `3120bf668562` | 2023-07-10 |  | Extended RAM & FM Synthesis Card for HITACHI MB-S1 (OPN3-L (YMF288) Version) |
| [S1FmSynthOPNA](https://github.com/bml3mk5/S1FmSynthOPNA) | `ref/hardware/S1FmSynthOPNA` | `5b30d918e671` | 2023-08-10 | Rev.0.1.4 | FM Synthesis Card for HITACHI MB-S1 (OPNA (YM2608) Version) |
| [S1KanjiRomJIS2](https://github.com/bml3mk5/S1KanjiRomJIS2) | `ref/hardware/S1KanjiRomJIS2` | `8f6bf11fbd68` | 2026-02-01 |  | JIS Level 2 Kanji ROM Card for HITACHI MB-S1 |
| [S1MpcExCard](https://github.com/bml3mk5/S1MpcExCard) | `ref/hardware/S1MpcExCard` | `489ea026d8df` | 2023-05-20 |  | Extension Card for HITACHI MB-S1 |
| [USBKeyboard4S1_PiPico](https://github.com/bml3mk5/USBKeyboard4S1_PiPico) | `ref/hardware/USBKeyboard4S1_PiPico` | `f1f5e247b4c3` | 2024-07-09 |  | USBKeyboard Converter for HITACHI MB-S1 (Raspberry Pi Pico version) |
| [USBKeyboard4S1](https://github.com/bml3mk5/USBKeyboard4S1) | `ref/hardware/USBKeyboard4S1` | `cb70fa2c6c6e` | 2025-05-03 | S0.2.0-H0.1.1 | USBKeyboard Converter for HITACHI MB-S1 |

## Other emulators with source (cloned)

| Repo | Local path | Commit | Last commit | Description |
|---|---|---|---|---|
| [shippoiincho/bml3emulator](https://github.com/shippoiincho/bml3emulator) | `ref/emulators/shippoiincho-bml3emulator` | `1a65ad4e272c` | 2024-07-21 | Basic Master Level 3 emulator for the Raspberry Pi Pico (C, spc476 mc6809 core, VGA via PIO). ROM headers are dummies |
| [hi631/BASIC_MASTER_LEVEL3](https://github.com/hi631/BASIC_MASTER_LEVEL3) | `ref/emulators/hi631-BASIC_MASTER_LEVEL3` | `9d6c50ab1bea` | 2019-11-26 | Partial MB-6890 FPGA design for the DE10-Nano (MultiComp-based; no PIA, tape or interlace) |

MAME was not re-downloaded. The local checkout `~/Documents/development/BasicMasterJr_MiSTer/mame`
has full history (HEAD `f4bfc5a423f`, 2025-12-24). See `notes/other-emulators-survey.md` for the
history of `bml3.cpp` / `mbs1.cpp`.

## Binaries (not executed)

| File | Bytes | sha256 |
|---|---|---|
| `ref/emulators/binaries/EmuB-6892_V2.1.4/bml3mk5_cocoa2_macos_214_dbgr.dmg` | 7056997 | `e48d2829c1f48d9cdf2444f9c8218746e6e90ed686a9f7ae7276eed22b7b5a4d` |
| `ref/emulators/binaries/EmuB-6892_V2.1.4/bml3mk5_cocoa2_macos_214.dmg` | 6862286 | `3f94271a4bf6f4b40c0c10ee6d85b4cb9a93f71537c1feea87ac3d89fedec152` |
| `ref/emulators/binaries/EmuB-6892_V2.1.4/bml3mk5_win32_214_dbgr.zip` | 567933 | `fb5b41922823f8fe8f76b162d66cb454a6d5039a08aaaf55749f1e1b213b77ed` |
| `ref/emulators/binaries/EmuB-6892_V2.1.4/bml3mk5_win32_214.zip` | 490318 | `81e375af0429db3ed76d45478b1923bf045b03c71ca549cd5c694aef69644531` |
| `ref/emulators/binaries/EmuB-6892_V2.1.4/bml3mk5_win64_214_dbgr.zip` | 624015 | `706e01d06ee0e32991ddd8fc733d37b8ad76f5145cb00134bfd7bf2ef056a02a` |
| `ref/emulators/binaries/EmuB-6892_V2.1.4/bml3mk5_win64_214.zip` | 532603 | `490060a44fe18bf1fb284c728045364064acd2a098790c128547002699b4ebbf` |
| `ref/emulators/binaries/EmuB-S1_V0.9.4/mbs1_cocoa2_macos_094_dbgr.dmg` | 7351164 | `6c4c5af09dfe392b4022f006104c790cb58158e7b10733be7a563de5632efc77` |
| `ref/emulators/binaries/EmuB-S1_V0.9.4/mbs1_cocoa2_macos_094_m68k_dbgr.dmg` | 7754392 | `f1dd3d9536b923b139344b660b4863ab51184d3b7943d568ae4fb80bcc535080` |
| `ref/emulators/binaries/EmuB-S1_V0.9.4/mbs1_cocoa2_macos_094_z80b_dbgr.dmg` | 7443020 | `77e96c4671000059d18ab9cc56c9e256b8ce95a6d6f406a4396ac4a3c40b1072` |
| `ref/emulators/binaries/EmuB-S1_V0.9.4/mbs1_cocoa2_macos_094.dmg` | 7117635 | `17a79b227cc840b594a1cfe1447d836cfc11800c1d7ba5a107eeb1d993c9cc2c` |
| `ref/emulators/binaries/EmuB-S1_V0.9.4/mbs1_win32_094_dbgr.zip` | 747312 | `0d3b0c5d35c72c0aa9a286c97741e06c1fb30d596f7419579df42f40016a0652` |
| `ref/emulators/binaries/EmuB-S1_V0.9.4/mbs1_win32_094_m68k_dbgr.zip` | 728243 | `19411ddc2f72d5ee94118b2a336f1c74fed456f41ccf885f42f80bb854e851c4` |
| `ref/emulators/binaries/EmuB-S1_V0.9.4/mbs1_win32_094_z80b_dbgr.zip` | 735707 | `fb9a78ae696bc43a2a46ba4b3d77987ebd8497494734aada2394467ce8611a3b` |
| `ref/emulators/binaries/EmuB-S1_V0.9.4/mbs1_win32_094.zip` | 615949 | `fb7793c83bfb8f101a5eb1453b109a76a2f62d964c844b3a29acd831d57b2824` |
| `ref/emulators/binaries/EmuB-S1_V0.9.4/mbs1_win64_094_dbgr.zip` | 820178 | `7fe9de43172a014603d68eb237f2bdbf519d30b7d66f5a582953f12bb0b982d5` |
| `ref/emulators/binaries/EmuB-S1_V0.9.4/mbs1_win64_094_m68k_dbgr.zip` | 808364 | `e20a11ccad9b41e0278eec4e2663159ce1d4f5c1f7317d8e7d9de3e7c8956483` |
| `ref/emulators/binaries/EmuB-S1_V0.9.4/mbs1_win64_094_z80b_dbgr.zip` | 815515 | `03aee9bfc62286769ec60f2aafba4174f7da3736e13aa45ff68db842539f2550` |
| `ref/emulators/binaries/EmuB-S1_V0.9.4/mbs1_win64_094.zip` | 683796 | `f394fd0c5ee8a1d99c43393688bb5b65e6a414d889fd1be72e2f32b5e4f90d65` |
| `ref/emulators/binaries/local_bml3mk5_win32_191/bml3mk5_win32_191.zip` | 480682 | `bc62615baa7be25a45320396a0827a05088796da729ee48322ee08a222e55115` |

- `EmuB-6892_V2.1.4/`: every asset of GitHub release
  [V2.1.4](https://github.com/bml3mk5/EmuB-6892/releases/tag/V2.1.4) (2026-07-11): macOS universal
  DMG (Cocoa2/SDL2) and Win32/Win64 zips, each with and without the debugger. The zips contain
  `bml3mk5.exe`, readme/spec/history, and `tool/FONT.ROM` (Sasaji's hand-made font, CRC `0b6f2f10`)
  plus the `mkkanji` pseudo-kanji tool. **No system ROMs.**
- `EmuB-S1_V0.9.4/`: every asset of GitHub release
  [V0.9.4](https://github.com/bml3mk5/EmuB-S1/releases/tag/V0.9.4) (2026-07-11): macOS DMGs and
  Win32/Win64 zips (plain, `_dbgr`, `_z80b_dbgr`, `_m68k_dbgr`). The zips contain `mbs1.exe`, docs,
  `tool/S1FONT.ROM` (hand-made, CRC `1340db8a`), `tool/dict/` (pseudo-dictionary generator
  `mkdic.py`/`.pl` + `s1dic.txt`) and `tool/kanji/`. **No system ROMs.**
- The same files, plus `*_source.zip`, are on <http://s-sasaji.ddo.jp/bml3mk5/download.htm> (use plain
  http). The site lists MD5s; see `notes/other-emulators-survey.md`. There are no Linux binaries
  ("untested, distribution stopped").
- `local_bml3mk5_win32_191/bml3mk5_win32_191.zip`: copied from `/Users/alans/Downloads/` (the user's
  own file). EmuB-6892 V1.9.1 for Win32 (2022-12), **with system ROMs included**:
  `598_p16611.ic3` (8 KB, CRC `954b9bad`), `599_p16561.ic4` (8 KB, `b27a48f5`), `600_p16681.ic5`
  (8 KB, `fe3988a5`), `l3bas.rom` (24 KB, `d81baa07`), `font.rom` (4 KB, `0b6f2f10`), plus
  `bml3mk5.ini`/`.log`/`keybind.ini` and `tool/` (FONT.ROM, mkkanji). The CRCs (read from the zip
  directory with `unzip -v`, without extracting) match MAME's `bml3` set exactly. Contents listed with
  `unzip -l`; not extracted.

## Notes written

- `notes/emulators.md`: ranking, build status, device-code map, ROM list, tape formats.
- `notes/emulator-comparison-initial.md`: EmuB-6892 vs MAME bml3 on the key points.
- `notes/other-emulators-survey.md`: web survey of every other L3/S1 emulator, plus MAME history.
- `notes/emub-docs-en/`: English translations of the EmuB docs (index in `INDEX.md`).
- `notes/emub-macos-ffmpeg8.patch`: the build fix for FFmpeg 8 on macOS.
