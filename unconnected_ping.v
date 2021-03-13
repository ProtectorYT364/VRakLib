module vraklib

pub struct UnConnectedPing {
mut:
	p              Packet
	// magic [16]byte
	magic          []byte
	send_timestamp u64
	client_guid    u64
}

pub fn (mut r UnConnectedPing) encode(mut b ByteBuffer) {
	b.put_byte(id_unconnected_ping)
	b.put_ulong(r.send_timestamp)
	b.put_bytes(get_packet_magic(), raknet_magic_length) // TODO check method
	b.put_ulong(r.client_guid)
}

pub fn (mut r UnConnectedPing) decode(mut b ByteBuffer) {
	r.send_timestamp = b.get_ulong()
	r.magic = b.get_bytes(raknet_magic_length)
	r.client_guid = b.get_ulong()
	println(r)
}
