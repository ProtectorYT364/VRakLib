module vraklib

struct IncompatibleProtocolVersion {
mut:
	p           Packet
	// magic [16]byte
	magic       []byte
	protocol    byte
	server_guid u64
}

fn (mut r IncompatibleProtocolVersion) encode() {
	r.p.buffer.put_byte(id_incompatible_protocol_version)
	r.p.buffer.put_byte(r.protocol)
	r.p.buffer.put_bytes(get_packet_magic(), raknet_magic_length) // TODO check method
	r.p.buffer.put_ulong(r.server_guid)
}

fn (mut r IncompatibleProtocolVersion) decode() {
	r.protocol = r.p.buffer.get_byte()
	r.magic = r.p.buffer.get_bytes(16)
	r.server_guid = r.p.buffer.get_ulong()
}
