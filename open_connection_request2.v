module vraklib

import net

struct OpenConnectionRequest2 {
mut:
	// magic [16]byte
	magic          []byte
	server_address net.Addr
	mtu_size       u16
	client_guid    u64
}
pub fn (r OpenConnectionRequest2) encode() ByteBuffer {
	mut b := empty_buffer()
	b.put_byte(id_open_connection_request2)
	b.put_bytes(get_packet_magic()) // TODO check method
	b.put_address(r.server_address)
	b.put_ushort(r.mtu_size) // todo u16 or i16?
	b.put_ulong(r.client_guid)
	return b
}
pub fn (mut r OpenConnectionRequest2) decode(mut p Packet) {
	mut b := p.buffer_from_packet()
	r.magic = b.get_bytes(get_packet_magic().len)
	r.server_address = b.get_address()
	r.mtu_size = b.get_ushort() // todo u16 or i16?
	r.client_guid = b.get_ulong()
}
