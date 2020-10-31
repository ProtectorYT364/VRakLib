module protocol

struct OpenConnectionRequest1 {
mut:
    p Packet

    version byte
    mtu_size u16
}

fn (mut r OpenConnectionRequest1) encode() {}

fn (mut r OpenConnectionRequest1) decode() {
    r.p.buffer.get_byte() // Packet ID
    r.p.buffer.get_bytes(raknet_magic_length)
    r.version = r.p.buffer.get_byte()
    r.mtu_size = u16(r.p.buffer.length - r.p.buffer.position)
}
