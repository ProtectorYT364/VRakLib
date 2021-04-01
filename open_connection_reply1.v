module vraklib

struct OpenConnectionReply1 {
mut:
	// magic [16]byte
	magic       []byte
	server_guid u64
	secure      bool
	mtu_size    u16 // todo u16 or i16?
}
pub fn (mut r OpenConnectionReply1) encode() ByteBuffer {
	mut b := empty_buffer()
	b.put_byte(id_open_connection_reply1)
	r.magic = get_packet_magic()
	b.put_bytes(r.magic)
	b.put_ulong(r.server_guid)
	b.put_bool(r.secure)
	b.put_ushort(r.mtu_size) // todo u16 or i16?
	return b
}
pub fn (mut r OpenConnectionReply1) decode(mut p Packet) {
	mut b := p.buffer_from_packet()
	b.get_byte()//pid
	r.magic = b.get_bytes(16)
	r.server_guid = b.get_ulong()
	r.secure = b.get_bool()
	r.mtu_size = b.get_ushort() // todo u16 or i16?
}
