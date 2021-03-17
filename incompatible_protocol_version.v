module vraklib

struct IncompatibleProtocolVersion {
mut:
	p           Packet
	// magic [16]byte
	magic       []byte
	protocol    byte
	server_guid u64
}

fn (mut r IncompatibleProtocolVersion) encode(mut b ByteBuffer) {
	b.put_byte(id_incompatible_protocol_version)
	b.put_byte(r.protocol)
	b.put_bytes(get_packet_magic()) // TODO check method
	b.put_ulong(r.server_guid)
	b.trim()
}

fn (mut r IncompatibleProtocolVersion) decode(mut b ByteBuffer) {
	r.protocol = b.get_byte()
	r.magic = b.get_bytes(16)
	r.server_guid = b.get_ulong()
}
