module vraklib

struct ConnectedPing {
mut:
	client_timestamp u64
}

pub fn (r ConnectedPing) encode() ByteBuffer {
	mut b := empty_buffer()
	b.put_byte(id_connected_ping)
	//b.put_ulong(r.client_timestamp)
	b.put_ulong(swap64(r.client_timestamp))
	return b
}

pub fn (mut r ConnectedPing) decode(mut p Packet) {
	mut b := p.buffer_from_packet()
	b.get_byte()//pid
	//r.client_timestamp = b.get_ulong()
	r.client_timestamp = swap64(b.get_ulong())
}