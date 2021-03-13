module vraklib

import net

struct OpenConnectionReply2 {
mut:
	p              Packet
	// magic [16]byte
	magic          []byte
	server_guid    u64
	client_address net.Addr
	mtu_size       u16
	secure         bool
}

fn (mut r OpenConnectionReply2) encode(mut b ByteBuffer) {
	b.put_byte(id_open_connection_reply2)
	b.put_bytes(get_packet_magic(), raknet_magic_length) // TODO check method
	b.put_ulong(r.server_guid)
	r.p.put_address(r.client_address)
	b.put_ushort(r.mtu_size) // todo u16 or i16?
	b.put_bool(r.secure)
}

fn (mut r OpenConnectionReply2) decode(mut b ByteBuffer) {
	r.magic = b.get_bytes(raknet_magic_length)
	r.server_guid = b.get_ulong()
	r.client_address = r.p.get_address()
	r.mtu_size = b.get_ushort() // todo u16 or i16?
	r.secure = b.get_bool()
}
