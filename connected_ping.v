module vraklib

struct ConnectedPing {
mut:
	p                Packet
	client_timestamp u64
}

pub fn (mut r ConnectedPing) encode(mut b ByteBuffer) {
	b.put_byte(id_connected_ping)
	b.put_ulong(r.client_timestamp)
	b.trim()
}

pub fn (mut r ConnectedPing) decode(mut b ByteBuffer) {
	r.client_timestamp = b.get_ulong()
}