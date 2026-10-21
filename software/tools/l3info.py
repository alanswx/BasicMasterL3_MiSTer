#!/usr/bin/env python3
"""Analyse Basic Master Level 3 / MB-S1 tape and disk images.

Usage: python3 -I l3info.py [--json out.json] FILE...

Formats:
  .l3   binary byte stream (serial bytes without start/stop bits)
  .l3b  ASCII '0'/'1', one char per serial bit (start 0, 8 data LSB first, stop 1s)
  .l3c  ASCII '0'/'1' carrier samples at 4800 Hz (x2 at 1200 baud); CR/LF ignored
  .d88  D88 disk image
Tape blocks: leader $FF..., sync $01 $3C, type, len, data[len], checksum = (type+len+sum(data)) & 255.
type 0 = header (20 bytes: name[8], filetype, asciiflag, gapflag?, ...), 1 = data, $FF = end.
"""
import sys, os, json, hashlib, collections, re

def sha256(path):
    h = hashlib.sha256()
    with open(path, 'rb') as f:
        for chunk in iter(lambda: f.read(1 << 20), b''):
            h.update(chunk)
    return h.hexdigest()

# ---------------------------------------------------------------- bits -> bytes
def serial_bits_to_bytes(bits):
    """bits: str of '0'/'1'. Async frames: start 0, 8 data LSB first, >=1 stop 1."""
    out = bytearray()
    i, n = 0, len(bits)
    errors = 0
    while i < n - 10:
        if bits[i] == '1':
            i += 1
            continue
        # start bit
        b = 0
        for k in range(8):
            if bits[i + 1 + k] == '1':
                b |= 1 << k
        if bits[i + 9] != '1':
            errors += 1
            i += 1
            continue
        out.append(b)
        i += 10
    return bytes(out), errors

def carrier_to_bits(samples, bitlen):
    """samples: str of '0'/'1' only. Return bit string. Short half-cycles=2400Hz='1'."""
    runs = []
    prev, cnt = None, 0
    for c in samples:
        if c == prev:
            cnt += 1
        else:
            if prev is not None:
                runs.append(cnt)
            prev, cnt = c, 1
    runs.append(cnt)
    hist = collections.Counter(runs)
    common = sorted([r for r, _ in hist.most_common(2)])
    if len(common) < 2:
        return '', hist
    thr = (common[0] + common[1]) / 2.0
    bits = []
    cur, acc = None, 0
    for r in runs:
        k = '1' if r < thr else '0'
        if r > common[1] * 3:  # gap / silence
            cur, acc = None, 0
            continue
        if k != cur:
            cur, acc = k, 0
        acc += r
        while acc >= bitlen - 0.5:
            bits.append(k)
            acc -= bitlen
    return ''.join(bits), hist

# ---------------------------------------------------------------- blocks
def parse_blocks(data):
    blocks = []
    i, n = 0, len(data)
    while i < n - 3:
        if data[i] == 0x01 and data[i + 1] == 0x3C:
            t = data[i + 2]
            ln = data[i + 3]
            if i + 4 + ln >= n + (1 if t == 0xFF else 0):
                if i + 4 + ln > n:
                    break
            payload = data[i + 4:i + 4 + ln]
            ck = data[i + 4 + ln] if i + 4 + ln < n else None
            calc = (t + ln + sum(payload)) & 0xFF
            blocks.append({'off': i, 'type': t, 'len': ln, 'data': payload, 'ok': ck == calc})
            i += 5 + ln
        else:
            i += 1
    return blocks

def group_files(blocks):
    files = []
    cur = None
    for b in blocks:
        if b['type'] == 0x00:
            cur = {'header': b, 'data': bytearray(), 'nblocks': 0, 'bad': 0 if b['ok'] else 1, 'end': False}
            files.append(cur)
        elif b['type'] == 0x01:
            if cur is None:
                cur = {'header': None, 'data': bytearray(), 'nblocks': 0, 'bad': 0, 'end': False}
                files.append(cur)
            cur['data'] += b['data']
            cur['nblocks'] += 1
            if not b['ok']:
                cur['bad'] += 1
        elif b['type'] == 0xFF:
            if cur is not None:
                cur['end'] = True
                if not b['ok']:
                    cur['bad'] += 1
            cur = None
    return files

FT = {0: 'BASIC', 1: 'DATA', 2: 'ML'}

def describe_file(f):
    d = {}
    h = f['header']
    if h is not None:
        hd = h['data']
        name = hd[:8].decode('latin-1').rstrip(' \x00')
        d['name'] = name
        d['ftype'] = FT.get(hd[8], '0x%02X' % hd[8]) if len(hd) > 8 else '?'
        d['ascii'] = (len(hd) > 9 and hd[9] == 0xFF)
        d['hdr_rest'] = hd[8:].hex()
    else:
        d['name'] = None
        d['ftype'] = '?'
    data = bytes(f['data'])
    d['size'] = len(data)
    d['blocks'] = f['nblocks']
    d['bad_ck'] = f['bad']
    d['end_block'] = f['end']
    if d['ftype'] == 'ML':
        segs, exe, i = [], None, 0
        while i + 5 <= len(data):
            if data[i] == 0x00:
                ln = (data[i + 1] << 8) | data[i + 2]
                ad = (data[i + 3] << 8) | data[i + 4]
                segs.append((ad, ln))
                i += 5 + ln
            elif data[i] == 0xFF:
                exe = (data[i + 3] << 8) | data[i + 4]
                i += 5
                break
            else:
                break
        d['segments'] = ['$%04X-$%04X' % (a, a + l - 1) for a, l in segs]
        d['exec'] = '$%04X' % exe if exe is not None else None
    elif d['ftype'] == 'BASIC' and not d.get('ascii'):
        # tokenized: [prefix] link(2) line(2) tokens... 00 ; choose prefix giving consistent link chain
        best = None
        for k in range(0, 6):
            i, chain, prev_link, prev_ln, first = k, 0, None, -1, None
            while i + 4 <= len(data):
                link = (data[i] << 8) | data[i + 1]
                if link == 0:
                    break
                ln = (data[i + 2] << 8) | data[i + 3]
                j = data.find(b'\x00', i + 4)
                if j < 0 or ln <= prev_ln:
                    break
                if first is None:
                    first = (link, ln, j + 1 - i)
                else:
                    pass
                chain += 1
                prev_ln, i = ln, j + 1
                # verify link chain: next line should start at offset link-base
            if first and (best is None or chain > best[1]):
                best = (k, chain, first, prev_ln)
        if best:
            k, chain, (link, ln, l1), last = best
            d['basic_prefix'] = data[:k].hex()
            d['basic_start'] = '$%04X' % (link - l1)
            d['lines'] = chain
            d['line_range'] = '%d-%d' % (ln, last)
        # look for hints
        txt = data.decode('latin-1')
        hints = sorted(set(re.findall(r'&H(FF[0-9A-F]{2})', txt)))
        if hints:
            d['io_refs'] = hints
    return d

def analyse_tape_bytes(data):
    blocks = parse_blocks(data)
    files = group_files(blocks)
    return {'nblocks': len(blocks), 'files': [describe_file(f) for f in files],
            'leader_ff': len(data) - len(data.lstrip(b'\xff'))}

def analyse_l3(path):
    data = open(path, 'rb').read()
    r = analyse_tape_bytes(data)
    r['format'] = 'l3'
    return r

def analyse_l3b(path):
    raw = open(path, 'rb').read().decode('latin-1')
    lines = raw.split('\n')
    bits = re.sub(r'[^01]', '', raw)
    other = collections.Counter(c for c in raw if c not in '01\r\n')
    data, err = serial_bits_to_bytes(bits)
    r = analyse_tape_bytes(data)
    r.update({'format': 'l3b', 'bits': len(bits), 'line_len': len(lines[0].rstrip('\r')),
              'framing_errors': err, 'other_chars': dict(other), 'decoded_bytes': len(data)})
    return r

def analyse_l3c(path):
    raw = open(path, 'rb').read().decode('latin-1')
    lines = raw.split('\n')
    other = collections.Counter(c for c in raw if c not in '01\r\n')
    samples = re.sub(r'[^01]', '', raw)
    r = {'format': 'l3c', 'samples': len(samples), 'line_len': len(lines[0].rstrip('\r')),
         'other_chars': dict(other), 'files': [], 'nblocks': 0, 'decode': {}}
    for bitlen in (8, 4):
        bits, hist = carrier_to_bits(samples, bitlen)
        data, err = serial_bits_to_bytes(bits)
        t = analyse_tape_bytes(data)
        r['halfcycle_hist'] = dict(hist.most_common(6))
        r['decode'][bitlen] = {'framing_errors': err, 'bytes': len(data), 'blocks': t['nblocks'],
                               'good_files': sum(1 for f in t['files'] if f['bad_ck'] == 0 and f['name'])}
        for f in t['files']:
            if f['name'] is None and f['bad_ck']:
                continue
            f['spb'] = bitlen
            r['files'].append(f)
        r['nblocks'] += t['nblocks']
    return r

# ---------------------------------------------------------------- d88
def analyse_d88(path):
    d = open(path, 'rb').read()
    name = d[:17].split(b'\x00')[0].decode('latin-1')
    wp = d[0x1A]
    media = {0x00: '2D', 0x10: '2DD', 0x20: '2HD', 0x30: '1D', 0x40: '1DD'}.get(d[0x1B], hex(d[0x1B]))
    size = int.from_bytes(d[0x1C:0x20], 'little')
    offs = [int.from_bytes(d[0x20 + 4 * i:0x24 + 4 * i], 'little') for i in range(164)]
    first = min([o for o in offs if o] or [0x2B0])
    ntab = (first - 0x20) // 4 if first >= 0x20 else 164
    sectors = {}  # (c,h,r) -> (n, dens, data)
    tracks = 0
    geom = collections.Counter()
    for ti, o in enumerate(offs[:ntab]):
        if not o or o >= len(d):
            continue
        tracks += 1
        p = o
        nsec = int.from_bytes(d[p + 4:p + 6], 'little')
        trk_desc = []
        for s in range(nsec):
            if p + 16 > len(d):
                break
            c, h, r, n = d[p], d[p + 1], d[p + 2], d[p + 3]
            dens = d[p + 6]
            sz = int.from_bytes(d[p + 14:p + 16], 'little')
            sectors[(ti, c, h, r)] = (n, dens, d[p + 16:p + 16 + sz])
            trk_desc.append((sz, 'S' if dens == 0x40 else 'D'))
            p += 16 + sz
        szs = collections.Counter(trk_desc)
        geom[(ti == 0, nsec, tuple(sorted(szs)))] += 1
    res = {'format': 'd88', 'name': name, 'media': media, 'write_protect': bool(wp), 'size_hdr': size,
           'tracks_present': tracks, 'track_table': ntab}
    res['geometry'] = ['%s%d trk: %d sec x %s' % ('trk0 ' if k[0] else '', v, k[1],
                       ','.join('%d%s' % s for s in k[2])) for k, v in geom.most_common()]
    # directory: L3/S1 DISK BASIC, cyl 20
    dirents = []
    for ent_size, kind in ((32, '2D'),):
        cand = []
        for (ti, c, h, r), (n, dens, data) in sectors.items():
            if c == 20:
                logical = r if h == 0 else (r + 16 if r <= 16 else r)
                cand.append((logical, data))
        cand.sort()
        two_d = any(len(x[1]) == 256 for x in cand)
        lo, hi = (5, 23) if two_d else (7, 16)
        res['dir_layout'] = 'L3S1-2D (cyl20 sec5-23)' if two_d else 'L3-1S (cyl20 sec7-16)'
        for logical, data in cand:
            if lo <= logical <= hi:
                for k in range(0, len(data) - 31, 32):
                    e = data[k:k + 32]
                    if e[0] in (0x00, 0xFF, 0xE5, 0x40):
                        continue
                    nm = e[:8]
                    if not all(0x20 <= x < 0x7F or x >= 0xA1 for x in nm):
                        continue
                    nmx = nm.decode('latin-1').rstrip()
                    ext = e[8:11].decode('latin-1').rstrip()
                    dirents.append('%s%s t=%02X/%02X' % (nmx, '.' + ext if ext.strip() else '', e[11], e[12]))
    res['directory'] = dirents[:60]
    return res

# ---------------------------------------------------------------- main
def main(argv):
    out_json = None
    if argv and argv[0] == '--json':
        out_json = argv[1]
        argv = argv[2:]
    results = []
    for p in argv:
        ext = os.path.splitext(p)[1].lower()
        r = {'path': p, 'bytes': os.path.getsize(p), 'sha256': sha256(p)}
        try:
            if ext == '.l3':
                r.update(analyse_l3(p))
            elif ext == '.l3b':
                r.update(analyse_l3b(p))
            elif ext == '.l3c':
                r.update(analyse_l3c(p))
            elif ext == '.d88':
                r.update(analyse_d88(p))
            else:
                r['format'] = ext.lstrip('.')
        except Exception as e:
            r['error'] = repr(e)
        results.append(r)
        if not out_json:
            print(json.dumps(r, ensure_ascii=False))
    if out_json:
        with open(out_json, 'w') as f:
            json.dump(results, f, ensure_ascii=False, indent=1)

if __name__ == '__main__':
    main(sys.argv[1:])
