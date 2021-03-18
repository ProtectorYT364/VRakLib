module vraklib

pub struct UnConnectedPing {
pub mut:
	// magic [16]byte
	magic          []byte
	send_timestamp u64
	client_guid    u64
}

pub fn (mut r UnConnectedPing) encode() ByteBuffer {
	mut b := empty_buffer()
	b.put_byte(id_unconnected_ping)
	b.put_ulong(r.send_timestamp)
	r.magic = get_packet_magic()
	b.put_bytes(r.magic)
	b.put_ulong(r.client_guid)
	return b
}

pub fn (mut r UnConnectedPing) decode(mut p Packet) {
	mut b := p.buffer_from_packet()
	b.get_byte()//pid
	r.send_timestamp = b.get_ulong()
	r.magic = b.get_bytes(16)
	r.client_guid = b.get_ulong()
}
