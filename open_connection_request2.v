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

fn (mut r OpenConnectionRequest2) encode() {
	r.p.buffer.put_byte(id_open_connection_request2)
	r.p.buffer.put_bytes(get_packet_magic(), raknet_magic_length) // TODO check method
	r.p.put_address(r.server_address)
	r.p.buffer.put_ushort(r.mtu_size) // todo u16 or i16?
	r.p.buffer.put_ulong(r.client_guid)
}

fn (mut r OpenConnectionRequest2) decode() {
	r.magic = r.p.buffer.get_bytes(raknet_magic_length)
	r.server_address = r.p.get_address()
	r.mtu_size = r.p.buffer.get_ushort() // todo u16 or i16?
	r.client_guid = r.p.buffer.get_ulong()
}
