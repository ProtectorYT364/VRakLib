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
pub fn (mut r OpenConnectionRequest2) encode() ByteBuffer {
	mut b := empty_buffer()
	b.put_byte(id_open_connection_request2)
	r.magic = get_packet_magic()
	b.put_bytes(r.magic)
	b.put_address(r.server_address)
	b.put_ushort(r.mtu_size) // todo u16 or i16?
	b.put_ulong(r.client_guid)
	return b
}
pub fn (mut r OpenConnectionRequest2) decode(mut p Packet) {
	mut b := p.buffer_from_packet()
	println(b.get_byte())//pid
	r.magic = b.get_bytes(16)
	println(r.magic)
	println(b.buffer[b.position..])
	r.server_address = b.get_address()
	r.mtu_size = b.get_ushort() // todo u16 or i16?
	r.client_guid = b.get_ulong()
}
