#!/usr/bin/env python3
# Build boot0.rom for the Basic Master Level 3 / MB-S1 core from MAME ROM sets.
#
#   python3 make_boot0.py bml3.zip mbs1.zip bml3mp1802.zip [bml3mp1805.zip] [-o boot0.rom]
#
# Arguments are MAME zips (merged or non-merged) or directories holding the
# files. ROMs are found by CRC32, so file names do not matter. bml3mp1805 is
# optional (the core does not use the MP-1805 yet); without it that area is $FF.
#
# Layout (163840 bytes, see the comment at the top of rtl/core.v):
#   $00000  Level 3 BASIC, $A000-$FFFF (bml3: ic3 + ic4 + ic5),   24K
#           also used by the MB-S1 in Level 3 mode
#   $06000  MP-1802 boot ROM ($F800-$FFFF overlay)                 2K
#   $06800  MP-1805 boot ROM ($F800-$FFFF overlay)                 2K
#   $08000  character font (mbs1 font.rom)                         4K
#   $10000  S1 BASIC 1 (s1bas1.rom)                               32K
#   $18000  S1 BASIC 2: s1rom2.rom, s1romi.rom at the top         32K
#   $20000  S1 dictionary ROM (not dumped, $FF)                   32K
import argparse, hashlib, os, sys, zipfile, zlib

ROMS = {                      # name: (crc32, size)
  'ic3':    (0x954b9bad, 8192),
  'ic4':    (0xb27a48f5, 8192),
  'ic5':    (0xfe3988a5, 8192),
  'font':   (0xd1f27c5a, 4096),
  's1bas1': (0xefb80721, 32768),
  's1rom2': (0xe266108c, 32256),
  's1romi': (0x81cc0e4d, 16),
  'mp1802': (0x8d0dc101, 2048),
  'mp1805': (0xb532d8d9, 2048),
}
OPTIONAL = {'mp1805'}
SHA1 = '49fbfae9f4f459bb79d01d6063df0f8f799f63d0'   # with every ROM present

def scan(paths):
  found = {}
  def add(data):
    c = zlib.crc32(data) & 0xffffffff
    for k, (crc, size) in ROMS.items():
      if c == crc and len(data) == size:
        found[k] = data
  for p in paths:
    if os.path.isdir(p):
      for f in sorted(os.listdir(p)):
        f = os.path.join(p, f)
        if os.path.isfile(f) and os.path.getsize(f) <= 65536:
          add(open(f, 'rb').read())
    elif zipfile.is_zipfile(p):
      with zipfile.ZipFile(p) as z:
        for i in z.infolist():
          if i.file_size <= 65536:
            add(z.read(i))
    else:
      sys.exit('%s: not a zip file or directory' % p)
  return found

def main():
  ap = argparse.ArgumentParser(description='Build boot0.rom from MAME bml3/mbs1 ROM sets.')
  ap.add_argument('src', nargs='+', help='MAME zips or directories')
  ap.add_argument('-o', '--out', default='boot0.rom')
  a = ap.parse_args()
  r = scan(a.src)
  missing = [k for k in ROMS if k not in r and k not in OPTIONAL]
  if missing:
    sys.exit('missing ROMs: ' + ', '.join(missing) +
             ' (need MAME sets bml3, mbs1 and bml3mp1802)')
  img = bytearray(b'\xff' * 0x28000)
  def put(off, data): img[off:off + len(data)] = data
  put(0x00000, r['ic3'] + r['ic4'] + r['ic5'])
  put(0x06000, r['mp1802'])
  if 'mp1805' in r: put(0x06800, r['mp1805'])
  put(0x08000, r['font'])
  put(0x10000, r['s1bas1'])
  put(0x18000, r['s1rom2'])
  put(0x20000 - 16, r['s1romi'])
  with open(a.out, 'wb') as f:
    f.write(img)
  sha = hashlib.sha1(img).hexdigest()
  print('%s: %d bytes, sha1 %s' % (a.out, len(img), sha))
  if 'mp1805' not in r:
    print('bml3mp1805 not found: MP-1805 area left empty (the core does not use it)')
  elif sha != SHA1:
    sys.exit('unexpected sha1 (expected %s)' % SHA1)

if __name__ == '__main__':
  main()
