module vraklib

struct IncompatibleProtocolVersion {
mut:
	// magic [16]byte
	magic       []byte
	protocol    byte
	server_guid u64
}
pub fn (r IncompatibleProtocolVersion) encode() ByteBuffer {
	mut b := empty_buffer()
	b.put_byte(id_incompatible_protocol_version)
	b.put_byte(r.protocol)
	b.put_bytes(get_packet_magic()) // TODO check method
	b.put_ulong(r.server_guid)
	return b
}
pub fn (mut r IncompatibleProtocolVersion) decode(mut p Packet) {
	mut b := p.buffer_from_packet()
	b.get_byte()//pid
	r.protocol = b.get_byte()
	r.magic = b.get_bytes(16)
	r.server_guid = b.get_ulong()
}
