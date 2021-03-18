module vraklib

struct ConnectedPong {
mut:
	client_timestamp u64
	server_timestamp u64
}

pub fn (r ConnectedPong) encode() ByteBuffer {
	mut b := empty_buffer()
	b.put_byte(id_connected_pong)
	b.put_ulong(r.client_timestamp)
	b.put_ulong(r.server_timestamp)
	return b
}

pub fn (mut r ConnectedPong) decode(mut p Packet) {
	mut b := p.buffer_from_packet()
	r.client_timestamp = b.get_ulong()
	r.server_timestamp = b.get_ulong()
}
