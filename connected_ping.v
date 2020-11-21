module vraklib

struct ConnectedPing {
mut:
    p Packet

    client_timestamp u64
}

fn (mut r ConnectedPing) encode() {
    r.p.buffer.put_byte(id_connected_ping)
    r.p.buffer.put_ulong(r.client_timestamp)
}

fn (mut r ConnectedPing) decode() {
    r.client_timestamp = r.p.buffer.get_ulong()
}