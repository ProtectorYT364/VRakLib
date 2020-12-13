module vraklib

struct ConnectedPong {
mut:
	p                Packet
	client_timestamp u64
	server_timestamp u64
}

fn (mut r ConnectedPong) encode() {
	r.p.buffer.put_byte(id_connected_pong)
	r.p.buffer.put_ulong(r.client_timestamp)
	r.p.buffer.put_ulong(r.server_timestamp)
}

fn (mut r ConnectedPong) decode() {
	r.client_timestamp = r.p.buffer.get_ulong()
	r.server_timestamp = r.p.buffer.get_ulong()
}
