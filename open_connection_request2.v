module vraklib

import net

struct OpenConnectionRequest2 {
mut:
	p              Packet
	// magic [16]byte
	magic          []byte
	server_address net.Addr
	mtu_size       u16
	client_guid    u64
}

fn (mut r OpenConnectionRequest2) encode(mut b ByteBuffer) {
	b.put_byte(id_open_connection_request2)
	b.put_bytes(get_packet_magic(), get_packet_magic().len) // TODO check method
	b.put_address(r.server_address)
	b.put_ushort(r.mtu_size) // todo u16 or i16?
	b.put_ulong(r.client_guid)
}

fn (mut r OpenConnectionRequest2) decode(mut b ByteBuffer) {
	r.magic = b.get_bytes(get_packet_magic().len)
	r.server_address = b.get_address()
	r.mtu_size = b.get_ushort() // todo u16 or i16?
	r.client_guid = b.get_ulong()
}
