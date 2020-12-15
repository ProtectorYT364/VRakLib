module vraklib

struct UnConnectedPing {
mut:
	p              Packet
	// magic [16]byte
	magic          []byte
	send_timestamp u64
	client_guid    u64
}

fn (mut r UnConnectedPing) encode() {
	r.p.buffer.put_byte(id_unconnected_ping)
	r.p.buffer.put_ulong(r.send_timestamp)
	r.p.buffer.put_bytes(get_packet_magic(), raknet_magic_length) // TODO check method
	r.p.buffer.put_ulong(r.client_guid)
}

fn (mut r UnConnectedPing) decode() {
	r.send_timestamp = r.p.buffer.get_ulong()
	r.magic = r.p.buffer.get_bytes(raknet_magic_length)
	r.client_guid = r.p.buffer.get_ulong()
}
