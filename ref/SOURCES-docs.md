# Documentation sources (Basic Master Level 3 / MB-S1)

Retrieved 2026-10-21 unless noted. Paths are relative to `ref/` unless they start with `roms/`.
sha256 values are of the file as downloaded. For page-image sets, the hash is of the concatenated
images in name order, and a per-file `SHA256SUMS` sits in the folder.
Engineering notes built from these: `notes/hardware-from-manuals.md`, `notes/basic-and-monitor.md`,
`notes/schematic-notes.md`, per-source detail in `notes/sources/`.

## 1. Service manual and technical manuals

| Title | URL | Local path | Size | sha256 | Contents / usefulness |
|---|---|---|---|---|---|
| **Hitachi Personal Computer MB-6890 Service Manual** (English, Rev. 0, 30/12/1981), 123 page images | https://www.manualslib.com/manual/2236613/Hitachi-Mb-6890.html (images from static-data2.manualslib.com/storage/pdf45/224/22367/2236613/images/mb6890_N_bg.jpg) | `docs/service/MB-6890-service-manual/manualslib-pages/p001-p123` | 123 files, 11.6 MB | d5945ed7fbb04df674766ddcd1904b5dac0a20ca1972b288976fb8dd81b00305 | **The service manual MAME cites.** Specs, connector pinouts, IC list, a 40-page circuit explanation (register map Table 6-1, clock tree, decoding, DRAM/video interleave, CRTC/video, character ROM layout, keyboard, cassette, ACIA clocks, light pen, sound, RAM expansion), memory map, adjustments, DIP/chip switches, troubleshooting, test programs (ROM checksum), parts list. **The foldout schematic/PCB/waveform sections are missing** from this copy. Image = printed page + 2 |
| **MP-1802 / MP-3550 Technical Manual** (English), 92 page images | https://www.manualslib.com/manual/1193870/Hitachi-Mp-1802.html | `docs/manuals/MP-1802-technical-manual/p001-p092` | 92 files, 8.8 MB | 35abaa8f352998a58301f9b4af7ade9ee276439a452af0d2545d31f417fb22a6 | 5.25" 2D floppy card + drive: I/O map and bits of `$FF00-$FF07`, NMI wiring, MB8866 clocking, boot ROM decode `$F800-$FEFF`, disk format, connector pinouts, **legible MP-1802 card schematic** (img084-085) and drive schematics |
| Hitachi MP-1802 fitting sheet 「サービスマンの方へ」 (Japanese) | https://archive.org/details/Hitachi_MP-1802 | `docs/manuals/MP-1802/Hitachi_MP-1802.pdf` | 511566 | 35fc47da53272973cfc9270841e8ac50518db20bad5285eb9c80c6a24cbb7915 | Main-board layout (IC2-5, RAM3/4, I/F-1..6), chip-switch settings, Disk BASIC MA-5320 needs 40 KB |

## 2. Hitachi user / BASIC manuals

| Title | URL | Local path | Size | sha256 | Contents / usefulness |
|---|---|---|---|---|---|
| Hitachi MB-6890 BASIC Master Level 3 User and BASIC Programming Manual (English, Peach) | https://archive.org/details/hitachi-mb-6890-basic-master-level-3-user-and-basic-programming-manual | `docs/manuals/L3-user-and-basic-manual/Hitachi MB-6890 BASIC Master Level 3 user and BASIC programming manual.pdf` | 47719812 | 38ffb6f0137e741821e08eef44580906a624cf170e3e410b30f57186ec33b8b4 | 247 pp, OCR text layer. Specs, power-on screen and bytes-free table, memory map, I/O map (Table S.2), ROM entry points, work area, VRAM/colour-register programming, keyboard test, slot pinout, RS-232C, light pen, MON. Printed p.199 missing |
| Hitachi Basic Master Level 3 MB-6890 Assembler Manual 1983 (Delta Software, English) | https://archive.org/details/Hitachi_Basic_Master_Level_3_MB-6890_Assembler_Manual_1983 | `docs/manuals/L3-assembler-manual-1983/…Assembler_Manual_1983.pdf` | 25013551 | ad69c169f59c26559e26774eb2bf6cb6fe764b25e880c8981ad04146a99cada4 | 123 pp, image only. LOADM/SAVEM/EXEC usage, memory layout tables, DEBUG program commands |
| Hitachi MB-6890 Level-3 Disk BASIC Manual (difficult scan, English) | https://archive.org/details/Hitachi_MB-6890_Level-3_Disk_Basic_Manual_Difficult_Scan | `docs/manuals/L3-disk-basic-manual/…Difficult_Scan.pdf` | 28049977 | e9cba072e2b9569ad35d0af7eba7bf9dd1dd90c30ccd19cc2c51a266b83dbe0d | 164 pp. Disk boot, SS SD 40×16×128 format and directory, BASIC command reference, both character sets, DIP 3/4 page table, error codes |
| Hitachi Personal Computer MB-S1 10/20 Operation Manual (photocopy, English) | https://archive.org/details/Hitachi_Personal_Computer_MB-S1_10_20_Operation_Manual_Photocopy | `docs/manuals/S1-operation-manual/…Operation_Manual_Photocopy.pdf` | 24249268 | 84b63a2728716fde95ecfc6c95b8b4552643b1cc5e991c884282452303f29696 | 129 pp. **§11 "System Description" is the S1 hardware manual**: 1 MB map, MMU, all I/O bit tables (incl. the L3-compatible area), CRTC values, keyboard matrix, PSG, IG, expansion pinout. Printed p.112 (RGB pinout) missing |
| Basic Manual for Hitachi Personal Computer MB-S1 10/20 (English) | https://archive.org/details/Basic_Manual_For_Hitachi_Personal_Computer_MB-S1_1020 | `docs/manuals/S1-basic-manual/…MB-S1_1020.pdf` | 61540952 | d67c0d95587c048d3ea333b12d153659b19fbfec3537dcef7b5f5efc30fa4f63 | 348 pp. S1 BASIC and L3 BASIC reference, MON commands, DEF MAP, PLAY/PSG clock |
| Disk BASIC Manual MS-S101 for MB-S1 (English) | https://archive.org/details/Disk_Basic_Manual_MS-S101_For_Hitachi_Personal_Computer_MB-S1 | `docs/manuals/S1-disk-basic-manual/…MB-S1.pdf` | 29456763 | 78e2d0d595a571a957fb088ed47b99a01aec2bf28fb87281b9cd785d7cb62430 | 144 pp. S1 disk boot, controllers/drives, file system |
| Hitachi MP-3710 mouse manual | https://archive.org/details/Hitachi_MP-3710 | `docs/manuals/MP-3710/Hitachi_MP-3710.pdf` | 640994 | f19831272e889f4583772334974e004ae2f69d54097b8b92afa18fee63cfa032 | MB-S1 mouse (S1 mode only); little hardware detail |

## 3. Third-party technical books and newsletters (Australia, "Peach")

| Title | URL | Local path | Size | sha256 | Contents / usefulness |
|---|---|---|---|---|---|
| **Peach ROM Notes**, Rossell & Viccars, rev 2 (1982) | https://archive.org/details/Peach_ROM_Notes_By_Bruce_Rossell_And_Howard_Viccars_rev_2 | `docs/peach/Peach-ROM-Notes-rev2/…rev_2.pdf` | 32948907 | 17d27e9060a4714013b877927cb36878df05895b09899c66a077248a40f8c8ac | 81 pp, typed English, OCR. **Commentary on the MB-6890 ROM disassembly** (not a full listing): I/O bits, CRTC values, work area, vectors, keyboard code table, cassette block format, ROM entry points, token tables |
| Notes on Hitachi Peach Double Density DOS, Peter Calder (1983) | https://archive.org/details/Notes_On_Hitachi_Peach_Double_Density_DOS_By_Peter_Calder | `docs/peach/Peach-DD-DOS-notes-Calder/…Calder.pdf` | 7523250 | 90b353201e5ad7889ea713529448fdcfb0250c1ce90e270f285c0e7764372f89 | FDC registers, bootstrap and loader listings, DD disk format, directory/FAT/FCB |
| Peach User Notes v2n3 (+v2n4 pages), 1984 | https://archive.org/details/Peach_User_Notes_Volume_2_Number_3 | `docs/peach/Peach-User-Notes-v2n3/…Number_3.pdf` | 6371832 | faba88e7b5eaeb8a6941c00894434cd3f88e709e978a6a98d027d83fdd97f77d | MB-S1 review, S1 compatibility with MB-6890 cards, B mode at 1 MHz, cursor offset, options list |
| The Australian Phase v1n3 (Feb/Mar 1985) | https://archive.org/details/The_Australian_Phase_A_Magazine_For_Japanese_Micros | `docs/magazines/Australian-Phase-A/…Japanese_Micros.pdf` | 16133640 | 737d76490c622fc916e50697a0445492950769506c9a7905eef424cb322dcb48 | Calder's "Interfacing to the MB-6890": slot pinout and I/O page allocation table; CRTC reprogramming program; RGB pinout; S1/30 review |
| NZ Bits & Bytes issue 1-06 (1982) | https://archive.org/details/nzbitsandbytes-1-06 | `docs/magazines/NZ-Bits-and-Bytes-1-06/NZ-bits-and-bytes-issue-1-06.pdf` | 17114539 | 4676e293dbf3e03f28fdffe04aa57d42e75d3ece03b84b60122f32dd6b677b22 | MB-6890 review with spec box |
| "Hitachi Peach Booklet in Japanese" (actually the MB-S1 Mouse Utility manual) | https://archive.org/details/Hitachi_Peach_Booklet_in_Japanese | `docs/peach/Peach-booklet-japanese/…Japanese.pdf` | 11165342 | 64013544f9aa0e259343bab4005d42b49c8a999df16ae364faf970e77d4fc81c | Mis-titled; S1 load/autostart procedures only |
| Hitachi Peach brochure (205×300 mm) | https://archive.org/details/Hitachi_Peach_205x300mm | `docs/peach/Peach-205x300mm/Hitachi_Peach_205x300mm.pdf` | 25205967 | 85526cac8884adfb55015bfb74ba7513f4ef5ad7e611622593ef5bb0cc43f3a6 | Sales brochure, specs, options tree |
| Hitachi S1 brochure (export, MB-S1/10) | https://archive.org/details/Hitachi_S1_Brochure | `docs/brochures/S1-brochure/Hitachi_S1_Brochure.pdf` | 1013960 | c0047dfc464336991f127b505728715126690cfe7b509358b07025835dcac161 | Spec sheet (RAM breakdown, 1 MB space, palette) |
| ProCalc for the Hitachi Peach | https://archive.org/details/Procalc_for_the_Hitachi_Peach | `docs/peach/Procalc/Procalc_for_the_Hitachi_Peach.pdf` | 6137161 | 21e68b5904ca98c5ae367e22f131d8b0664c6a1d8eb0cf6b49cde4fbb995e52b | Spreadsheet manual; no hardware |
| Micro Data (BJS Software Systems) for Hitachi Peach | https://archive.org/details/Micro_Data_BJS_Software_Systems_For_Hitachi_Peach | `docs/peach/MicroData-BJS-catalog/…Peach.pdf` | 3150570 | b8cd45f70b21a2403714aef5161488459b6cfdcb6c340114b1d41eefa1215200 | Database software manual; no hardware |

## 4. Web pages

| Title | URL | Local path | Size | sha256 | Contents / usefulness |
|---|---|---|---|---|---|
| s-sasaji: Basic Master Level 3 / MB-S1 site (mirror, `wget -r -np -k -p --wait=1`, archives/ROM extensions rejected) | http://s-sasaji.ddo.jp/bml3mk5/ | `web/s-sasaji/s-sasaji.ddo.jp/bml3mk5/` (log `web/s-sasaji-bml3mk5.log`) | 846 files, 33 MB | (tree; not hashed) | **Best Japanese hardware reference**: `systemio.htm` (all I/O bits incl. `$FFD7` per model, `$FFE8`), `memory.htm`, `keyboard.htm`, `tape.htm`, `screen.htm`, `basicwork.htm`, `basicsub.htm` (ROM entry points), `floppy.htm`, bus-takeover pages (`l3busctl.htm`, `s1busctl.htm`), S1 keyboard circuit, option-card projects, emulator docs. Digest: `notes/sources/s-sasaji.md` |
| s-sasaji: ベーマガ program index for BM machines (mirror) | http://s-sasaji.ddo.jp/bm/ | `web/s-sasaji/s-sasaji.ddo.jp/bm/` (log `web/s-sasaji-bm.log`) | 561 files, 61 MB | (tree) | Index of BASIC Magazine type-in programs for L3/S1 (leads for software) |
| leadedsolder: Hitachi Basic Master Level III Mark II cleaning/pickup (2023-05-09) | https://www.leadedsolder.com/2023/05/09/hitachi-basic-master-level-iii-mark-ii-cleaning-pickup.html | `web/leadedsolder/bm3-mk2-cleaning-pickup.html` (+ `page-requisites/` with images) | 31856 | 46cb110ae3b10abc70d3aeebd242c3b08636ee4639d41985efe1f472a49200ff | Mark II teardown photos (board, chips). The only leadedsolder BM3 post found |
| randoc: "Hitachi Basic Master family" (linked from leadedsolder) | https://randoc.wordpress.com/2021/04/02/hitachi-basic-master-family/ | `web/randoc/hitachi-basic-master-family.html` | 123525 | 4cc359027f1c02a315186eb15aa327d0e3f3e059b192819aa2906dd2e3cfa236 | Family overview / history |
| Wikipedia (ja): ベーシックマスター (Level 3 is a section; the Level 3 title redirects here) | https://ja.wikipedia.org/wiki/ベーシックマスター | `web/wikipedia/ja-BasicMaster.html` | 182436 | acad6bc64a4c067a767794a7c6adb234a56919ae9c14a7cb7c92e3a4a69cacac | Model history, specs |
| Wikipedia (ja): 日立・MB-S1 | https://ja.wikipedia.org/wiki/日立・MB-S1 | `web/wikipedia/ja-MB-S1.html` | 43585 | 525f5332c526102d5f2eaa94d3f7aaccaf92c0eed646ed1d96a06758aeb38a96 | S1 models and specs |
| Wikipedia (en): Hitachi Basic Master Level 3 | https://en.wikipedia.org/wiki/Hitachi_Basic_Master_Level_3 | `web/wikipedia/en-BasicMasterLevel3.html` | 51147 | c760008146d4711ffd977384ebfa53a45c712713be34de5fc3fda93780edbb06 | |
| Wikipedia (en): Hitachi MB-S1 | https://en.wikipedia.org/wiki/Hitachi_MB-S1 | `web/wikipedia/en-MB-S1.html` | 50352 | 1453219f8dcf64329eacf8234b804c07ca35ab8c4a07229620db5049edf1a88f | |
| Wikipedia (en): Hitachi Peach | https://en.wikipedia.org/wiki/Hitachi_Peach | `web/wikipedia/en-HitachiPeach.html` | 50352 | f4178a1d9996b793fa9fc67c96c50b7073b29b6ad1ea80a3fa50535f5d212583 | |
| Wikipedia (en): Hitachi Basic Master | https://en.wikipedia.org/wiki/Hitachi_Basic_Master | `web/wikipedia/en-BasicMaster.html` | 50723 | 028cfca4b24ed842163312b3a2db8fda17152316008786b443eeed9d18c0a2e6 | |
| S1 Wiki (seesaawiki, EUC-JP) | https://seesaawiki.jp/mb-s1/ | `web/s1wiki/seesaawiki.jp/mb-s1/` (content pages in `d/`) | 1.4 MB | (tree) | S1 address space, system I/O (common and mode A), system calls (MMASGN, PSGSYC…), V-RAM layout, BASIC commands, floppy notes |
| KtJ Dragon: 日立S1 misc | https://ktjdragon.com/nb/misc/atari_mbs1 | `web/misc/ktjdragon-mbs1.html` | 18225 | 2f55e7cb9c4791bcbb5156e6f0c2e50d8fd987c7cf0090c4d23d147f43e7452d | S1 notes |
| かべきんブログ: S1-CP/M80 移植作戦 その15 | http://asakita.net/kabekin/2018/10/16014.html | `web/misc/kabekin-s1cpm-15.html` | 223654 | cbbec98bc151acaa9bd93d4e071cfc91b965bc64e5dd7f65bafb4f63610f9cb9 | S1 BIOS/MMU work for a CP/M port; whole series under tag `s1` |
| 旧コン研: MB-S1 モデル30/40 | http://kyucom.sblo.jp/article/187126120.html | `web/misc/kyucom-mbs1-30-40.html` | 20045 | 0ef0a16bd9fc9462aceebf926b0bd8e08be9cd422c3ef9d64476d84485d1edcc | S1/30-40 hardware photos |
| note (kzn): The Solitary Thoroughbred "Hitachi MB-S1" | https://note.com/kazushinakamura/n/nf86cf45c7631 | `web/misc/note-kzn-mbs1.html` | 284936 | 2999200e519c6688ec5f23e1772e1bcec995b1b6411998876f6249f9a0f5576e | S1 history/MMU overview |

## 5. ROM dumps found (not executed)

| Title | URL | Local path | Size | sha256 | Notes |
|---|---|---|---|---|---|
| Hitachi S1 (日立MB-S1) BIOS Files | https://archive.org/details/hitachis1biosfiles | `roms/archive.org-hitachis1biosfiles/BIOS_Hitachi_S1.zip` (left zipped) | 74017 | 3baae968da8d37ab78e1e162e6372f9efb85910c4aeb35bd08b903f7b92c73cf | Contains FONT.ROM (4096), ROM1.ROM (24320, L3 BASIC `$A000-$FEFF`), ROM2.ROM (16, vectors), S1BAS1.ROM (32768), S1ROM2.ROM (32256), S1ROMI.ROM (16): the EmuB-S1 file set. Downloaded after the user lifted the ROM restriction |
| ROM listing/commentary | — | `docs/peach/Peach-ROM-Notes-rev2/` | | | See §3. The service manual's ROM-C test gives a checksum (A = 18, B = 178) for validating a v1.0 L3 set |

## 6. Found but not obtained (leads)

- **MB-6890 Service Manual, 29 MB PDF** (probably with the foldout schematics): 1000bit.it
  https://www.1000bit.it/scheda.asp?id=980 → `support/manuali/download.asp?id=1083`. Downloads need a
  (free) registered account, which I did not create. The same page lists, all login-gated: MP-3550/MP-1802
  Technical Manual (id=1086, we have the manualslib copy), MP-3550/MP-1802 Disk BASIC manual (id=1085),
  Level-3 BASIC reference card (id=1084), C14-2170 monitor service/user manuals (id=1079/1080), MP-3630
  dual FDD manual (id=1082), "Enjoyable programming with Hitachi Peach" batches 1-2 (id=1129/1130),
  "Using the Hitachi Peach as an Intelligent Terminal" (id=1127), 3.5" FDD and accessories (id=1128),
  and a Peach brochure.
- computerarchive.org once hosted `files/comp/manuals/hitachi/Hitachi Personal Computer MB-6890 Service
  Manual.pdf` (cited in comp.sys.m6809); the domain no longer resolves and the Wayback Machine has no copy.
- Books cited by s-sasaji: I/O別冊「ベーシックマスター活用研究」, 「S1活用研究」 (工学社); an MB-S1 schematic
  printed in I/O magazine; the S1 FM card schematic in I/O 1986-05.
- Magazines on archive.org (not downloaded; OCR too poor to locate L3 hardware articles by full-text
  search): I/O 1980-1987 (ids `Io19xxxx`, `io-19xxxx`), 月刊マイコン (`micom-19xx-xx`), ASCII, マイコン
  BASICマガジン (`micomBASIC_19xx-xx`, `micom-basic-magazine-issue-N`), Byte 1982-05 "Japanese Computers"
  (`byte-magazine-1982-05`, has an MB-6890 mention). Oh!HITACHI is not on archive.org.
- cooblog "日立MB-S1（月刊ASCII 1984年8月号）" (https://cooblog.blog.ss-blog.jp/2020-04-11): unreachable
  from here; describes the ASCII 1984-08 S1 article (custom MMU rationale).
- No Hitachi Japanese-language L3 manuals (取扱説明書, Level-3 BASIC マニュアル, ハードウェア解説) and
  nothing specific to the Mark II or Mark 5 were found online.
