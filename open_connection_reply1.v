module vraklib

struct OpenConnectionReply1 {
mut:
	// magic [16]byte
	magic       []byte
	server_guid u64
	secure      bool
	mtu_size    u16 // todo u16 or i16?
}
pub fn (r OpenConnectionReply1) encode() ByteBuffer {
	mut b := empty_buffer()
	b.put_byte(id_open_connection_reply1)
	b.put_bytes(get_packet_magic()) // TODO check method
	b.put_ulong(r.server_guid)
	b.put_bool(r.secure)
	b.put_ushort(r.mtu_size) // todo u16 or i16?
	return b
}
pub fn (mut r OpenConnectionReply1) decode(mut p Packet) {
	mut b := p.buffer_from_packet()
	r.magic = b.get_bytes(get_packet_magic().len)
	r.server_guid = b.get_ulong()
	r.secure = b.get_bool()
	r.mtu_size = b.get_ushort() // todo u16 or i16?
}
