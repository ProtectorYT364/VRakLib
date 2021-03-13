module vraklib

struct ConnectedPong {
mut:
	p                Packet
	client_timestamp u64
	server_timestamp u64
}

pub fn (mut r ConnectedPong) encode(mut b ByteBuffer) {
	b.put_byte(id_connected_pong)
	b.put_ulong(r.client_timestamp)
	b.put_ulong(r.server_timestamp)
}

pub fn (mut r ConnectedPong) decode(mut b ByteBuffer) {
	r.client_timestamp = b.get_ulong()
	r.server_timestamp = b.get_ulong()
}
