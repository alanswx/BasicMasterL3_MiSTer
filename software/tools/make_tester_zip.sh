#!/bin/bash
# Build the private tester zip: RBF + boot0.rom + tapes/disks + README.
# It contains ROMs and commercial software: for named testers only, never a
# public release.
#
# usage: software/tools/make_tester_zip.sh releases/BasicMasterL3_<hash>.rbf [README.txt]
# Run from the repo root. Needs roms/mister/boot0.rom and the local software/
# trees (software/found, software/extracted). Output: releases/BasicMasterL3_tester_<date>.zip
set -e
RBF=$1; README=$2
[ -f "$RBF" ] || { echo "usage: $0 <rbf> [README.txt]"; exit 1; }
DATE=$(date +%Y%m%d)
NAME=BasicMasterL3_tester_$DATE
WORK=$(mktemp -d); P=$WORK/$NAME; G=$P/games/BasicMasterL3
T="$G/Tape - Level 3"; M="$G/Tape - Mark 5"; S1="$G/Tape - MB-S1"; X="$G/Tape - Tests"; D="$G/Disk - MP-1802"
mkdir -p "$P/_Computer" "$T" "$M" "$S1" "$X" "$D"
cp "$RBF" "$P/_Computer/BasicMasterL3_$DATE.rbf"
cp roms/mister/boot0.rom "$G/"
[ -n "$README" ] && cp "$README" "$P/README.txt"

SW=software
cap() { n=$1; echo "$(echo ${n:0:1} | tr a-z A-Z)${n:1}"; }
conv() { python3 -I $SW/tools/l3conv.py "$1" "$2" >/dev/null; }

# File names carry the load command (testers used LOAD on LOADM tapes).
# inufuto: plain L3 builds, Mark 5 builds, S1 builds
for d in $SW/found/inufuto/*/; do
  n=$(cap "$(basename "$d")")
  f=$(find "$d/l3" -name '*.l3' 2>/dev/null | head -1);    [ -n "$f" ] && cp "$f" "$T/$n (LOADM).l3"
  f=$(find "$d/l3mk5" -name '*.l3' 2>/dev/null | head -1); [ -n "$f" ] && cp "$f" "$M/$n (Mk5, LOADM).l3"
  f=$(find "$d/s1" -name '*.l3' 2>/dev/null | head -1);    [ -n "$f" ] && cp "$f" "$S1/$n (S1, LOADM).l3"
done

E=$SW/extracted
cp $E/Cannon-Ball_*/Cannonball.l3 "$T/Cannon Ball (Hudson, LOAD, RUN).l3"
cp "$E/Eric-and-the-Floaters_Hitachi-Basic-Master-Level-3_JA/Bomber Man.l3" "$T/Bomber Man (Hudson, LOAD, RUN).l3"
cp "$E/MELHEN_Hitachi-Basic-Master-Level-3_JA/MELHEN (Maison Ikkoku).l3" "$T/MELHEN (LOAD, RUN).l3"
cp $E/Skating_*/SKATING1.l3 "$M/Skating 1 (load first).l3"
cp $E/Skating_*/SKATING2.l3 "$M/Skating 2.l3"
cp $SW/found/s-sasaji/bmtetris/bmtetris_x/tetris_all.l3 "$M/BM Tetris.l3"
cp $SW/found/s-sasaji/bmblock_010/bmblock_010_x/BLOCK_ALL.l3 "$M/BM Block.l3"
for f in 12lines 25lines 50lines; do cp $SW/found/s-sasaji/50lines/50lines_x/$f.l3 "$X/"; done

# S1 commercial tapes (.l3b/.l3c -> .l3)
conv "$E/Jelda_Hitachi-S1_JA/Jelda (Hitachi S1) [CT].l3b" "$S1/Jelda (LOAD, RUN).l3"
conv "$E/Lode-Runner_Hitachi-S1_JA/Lode Runner Hitachi S1 [CT] (Program).l3b" "$S1/Lode Runner 1 Program (LOAD, RUN).l3"
conv "$E/Lode-Runner_Hitachi-S1_JA/Lode Runner Hitachi S1 [CT] (Data).l3b" "$S1/Lode Runner 2 Data.l3"
for i in 1 2 3; do
  conv "$E/Dezeni-Land_Hitachi-S1_JA/Dezeni Land (Hitachi S1) [CT $i].l3c" "$S1/Dezeni Land $i (not working).l3"
done
LD="$SW/found/local_downloads/rocks-preserved-games_Hitachi_S1/Hitachi S1_x/Hitachi S1"
conv "$LD/Volguard (Hitachi S1) [CT].l3b" "$S1/Volguard (LOAD, RUN).l3"
A=$SW/found/archive.org
conv "$A/nutsandmilkhitachis1/Nuts & Milk (Hitachi S1) - ROM File_x/Nuts & Milk (Hitachi S1) [CT].l3b" "$S1/Nuts & Milk (LOAD, RUN).l3"
conv "$A/mariobrosspecialhitachis1/Mario Bros. Special (Hitachi S1) - ROM File_x/Mario Bros. Special (Hitachi S1) [CT].l3b" "$S1/Mario Bros Special (LOAD, RUN).l3"
for i in 1 2 3; do
  conv "$A/princesstomatointhesaladkingdomhitachis1/Princess Tomato in the Salad Kingdom (Hitachi S1) - ROM Files_x/Princess Tomato in the Salad Kingdom (Hitachi S1) [CT $i].l3c" "$S1/Princess Tomato $i (not working).l3"
done

cp $E/mame_bml3_flop_*/*.d88 "$D/"

mkdir -p releases
OUT=$PWD/releases/$NAME.zip; rm -f "$OUT"
(cd "$WORK" && zip -qr -X "$OUT" "$NAME")
rm -rf "$WORK"
echo "$OUT: $(unzip -l "$OUT" | tail -1)"
