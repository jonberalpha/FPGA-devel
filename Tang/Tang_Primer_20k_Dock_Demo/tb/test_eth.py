#!/usr/bin/env python3
"""Self-checking test of hdl/eth_server.v: builds ARP / ICMP / TCP frames, runs the iverilog testbench for
each one and verifies the reply (addresses, flags, IP/TCP/ICMP checksums, FCS and page content)."""
import struct, subprocess, sys, zlib

MY_MAC = bytes.fromhex("02544e414720".replace("4e41", "4142")) if False else bytes.fromhex("025441" "4e4720")
MY_IP = bytes([192, 168, 50, 2])
CLI_MAC = bytes.fromhex("aabbccddeeff")
CLI_IP = bytes([192, 168, 50, 1])
failures = 0


def csum(data):
    if len(data) % 2:
        data += b"\0"
    s = sum(struct.unpack("!%dH" % (len(data) // 2), data))
    while s >> 16:
        s = (s & 0xFFFF) + (s >> 16)
    return (~s) & 0xFFFF


def eth(dst, src, et, payload):
    f = dst + src + struct.pack("!H", et) + payload
    return f + b"\0" * max(0, 60 - len(f))


def ip(proto, payload, src=CLI_IP, dst=MY_IP):
    h = struct.pack("!BBHHHBBH4s4s", 0x45, 0, 20 + len(payload), 1, 0x4000, 64, proto, 0, src, dst)
    h = h[:10] + struct.pack("!H", csum(h)) + h[12:]
    return h + payload


def tcp(sport, dport, seq, ack, flags, data=b"", src=CLI_IP, dst=MY_IP):
    h = struct.pack("!HHIIBBHHH", sport, dport, seq, ack, 0x50, flags, 8192, 0, 0)
    pseudo = src + dst + struct.pack("!BBH", 0, 6, len(h) + len(data))
    c = csum(pseudo + h + data)
    return h[:16] + struct.pack("!H", c) + h[18:] + data


def run(name, frame):
    open("sim/rx.hex", "w").write("\n".join("%02x" % b for b in frame) + "\n")
    out = subprocess.run(["vvp", "build/tb_eth.vvp", "+rx=sim/rx.hex", "+tx=sim/tx.hex", "+len=%d" % len(frame)],
                         capture_output=True, text=True).stdout
    info = [l for l in out.splitlines() if l.startswith("TXLEN")]
    tx = bytes(int(l, 16) for l in open("sim/tx.hex").read().split())
    print("%-10s %s" % (name, info[0] if info else out[-200:]))
    return tx, (info[0] if info else "")


def check(cond, msg):
    global failures
    if not cond:
        failures += 1
        print("   FAIL:", msg)


def check_fcs(tx):
    check(len(tx) >= 64, "frame too short (%d)" % len(tx))
    check(zlib.crc32(tx[:-4]) & 0xFFFFFFFF == struct.unpack("<I", tx[-4:])[0], "bad FCS")


def check_ip(tx, proto):
    h = tx[14:34]
    check(csum(h) == 0, "bad IP header checksum")
    check(h[9] == proto, "bad protocol")
    check(h[12:16] == MY_IP and h[16:20] == CLI_IP, "bad IP addresses")


subprocess.run(["iverilog", "-g2005", "-I", "hdl", "-o", "build/tb_eth.vvp", "tb/tb_eth.v", "hdl/eth_server.v"], check=True)

# ---- ARP
arp = struct.pack("!HHBBH6s4s6s4s", 1, 0x0800, 6, 4, 1, CLI_MAC, CLI_IP, b"\0" * 6, MY_IP)
tx, _ = run("ARP", eth(b"\xff" * 6, CLI_MAC, 0x0806, arp))
check_fcs(tx)
check(tx[0:6] == CLI_MAC and tx[6:12] == MY_MAC and tx[12:14] == b"\x08\x06", "ARP eth header")
check(tx[20:22] == b"\x00\x02" and tx[22:28] == MY_MAC and tx[28:32] == MY_IP and tx[32:38] == CLI_MAC and tx[38:42] == CLI_IP, "ARP body")

# ---- ARP for somebody else must be ignored
arp2 = arp[:24] + bytes([192, 168, 50, 99])
tx, _ = run("ARP other", eth(b"\xff" * 6, CLI_MAC, 0x0806, arp2))
check(len(tx) == 0, "answered an ARP for another host")

# ---- ICMP echo
echo = struct.pack("!BBHHH", 8, 0, 0, 0x1234, 1) + bytes(range(48))
echo = echo[:2] + struct.pack("!H", csum(echo)) + echo[4:]
tx, _ = run("ICMP", eth(MY_MAC, CLI_MAC, 0x0800, ip(1, echo)))
check_fcs(tx)
check_ip(tx, 1)
check(tx[34] == 0 and csum(tx[34:34 + len(echo)]) == 0, "ICMP reply type/checksum")
check(tx[38:34 + len(echo)] == echo[4:], "ICMP payload")

# ---- TCP handshake
tx, _ = run("SYN", eth(MY_MAC, CLI_MAC, 0x0800, ip(6, tcp(40000, 80, 1000, 0, 0x02))))
check_fcs(tx)
check_ip(tx, 6)
seg = tx[34:54]
sport, dport, seq, ack, off, flags = struct.unpack("!HHIIBB", seg[:14])
check(sport == 80 and dport == 40000 and flags == 0x12 and ack == 1001, "SYN-ACK fields (%x %d)" % (flags, ack))
check(csum(src_pseudo := (MY_IP + CLI_IP + struct.pack("!BBH", 0, 6, 20)) + seg) == 0, "SYN-ACK TCP checksum")
isn = seq

# ---- HTTP GET with LED command
req = b"GET /l5/on HTTP/1.1\r\nHost: x\r\n\r\n"
tx, info = run("GET", eth(MY_MAC, CLI_MAC, 0x0800, ip(6, tcp(40000, 80, 1001, isn + 1, 0x18, req))))
check_fcs(tx)
check_ip(tx, 6)
tl = struct.unpack("!H", tx[16:18])[0] - 20
seg = tx[34:34 + tl]
sport, dport, seq, ack, off, flags = struct.unpack("!HHIIBB", seg[:14])
check(flags == 0x19 and seq == isn + 1 and ack == 1001 + len(req), "data fields flags=%x seq=%x ack=%d" % (flags, seq, ack))
check(csum(MY_IP + CLI_IP + struct.pack("!BBH", 0, 6, len(seg)) + seg) == 0, "data TCP checksum")
body = seg[20:]
check(body.startswith(b"HTTP/1.1 200 OK"), "HTTP status line")
check(b"LED5 <b>OFF</b>" in body or b"LED5 <b>ON </b>" in body, "LED5 line missing")
check(b"LED5 <b>ON </b>" in body and b"LED4 <b>ON </b>" in body and b"LED3 <b>OFF</b>" in body,
      "LED substitution wrong (led_state=010, /l5/on): " + str([body[i:i+22] for i in range(len(body)) if body.startswith(b'LED', i)]))
clen = int(body.split(b"Content-Length: ")[1].split(b"\r\n")[0])
check(len(body.split(b"\r\n\r\n", 1)[1]) == clen, "Content-Length mismatch")
check("LEDTGL=001" in info and "LEDVAL=001" in info and "REQ=1" in info, "LED command not signalled: " + info)

# ---- LED off command + FIN
req = b"GET /l4/off HTTP/1.1\r\n\r\n"
tx, info = run("GET off", eth(MY_MAC, CLI_MAC, 0x0800, ip(6, tcp(40001, 80, 5000, isn + 1, 0x18, req))))
check("LEDTGL=010" in info and "LEDVAL=000" in info, "off command: " + info)
tx, _ = run("FIN", eth(MY_MAC, CLI_MAC, 0x0800, ip(6, tcp(40000, 80, 1001 + len(req), isn + 700, 0x11))))
check_fcs(tx)
seg = tx[34:54]
_, _, seq, ack, _, flags = struct.unpack("!HHIIBB", seg[:14])
check(flags == 0x10 and ack == 1001 + len(req) + 1 and seq == isn + 700, "FIN ack fields")

# ---- other ports are ignored
tx, _ = run("port 81", eth(MY_MAC, CLI_MAC, 0x0800, ip(6, tcp(40000, 81, 1, 0, 0x02))))
check(len(tx) == 0, "answered a SYN to a closed port")

print("RESULT:", "PASS" if failures == 0 else "FAIL (%d)" % failures)
sys.exit(1 if failures else 0)
