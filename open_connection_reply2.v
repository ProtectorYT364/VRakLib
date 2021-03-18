module vraklib

import net

struct OpenConnectionReply2 {
mut:
	// magic [16]byte
	magic          []byte
	server_guid    u64
	client_address net.Addr
	mtu_size       u16
	secure         bool
}
pub fn (r OpenConnectionReply2) encode() ByteBuffer {
	mut b := empty_buffer()
	b.put_byte(id_open_connection_reply2)
	b.put_bytes(get_packet_magic()) // TODO check method
	b.put_ulong(r.server_guid)
	b.put_address(r.client_address)
	b.put_ushort(r.mtu_size) // todo u16 or i16?
	b.put_bool(r.secure)
	return b
}
pub fn (mut r OpenConnectionReply2) decode(mut p Packet) {
	mut b := p.buffer_from_packet()
	r.magic = b.get_bytes(raknet_magic_length)
	r.server_guid = b.get_ulong()
	r.client_address = b.get_address()
	r.mtu_size = b.get_ushort() // todo u16 or i16?
	r.secure = b.get_bool()
}
