module vraklib

import net

struct OpenConnectionReply2 {
mut:
    p Packet

	//magic [16]byte
	magic []byte
	server_guid u64
	client_address net.Addr
	mtu_size u16
	secure bool
}

fn (mut r OpenConnectionReply2) encode() {
    r.p.buffer.put_byte(id_open_connection_reply2)
    r.p.buffer.put_bytes(get_packet_magic().data, raknet_magic_length)//TODO check method
    r.p.buffer.put_ulong(r.server_guid)
	r.p.put_address(r.client_address)
    r.p.buffer.put_ushort(r.mtu_size)//todo u16 or i16?
    r.p.buffer.put_bool(r.secure)
}

fn (mut r OpenConnectionReply2) decode () {
    r.magic = r.p.buffer.get_bytes(raknet_magic_length)
    r.server_guid = r.p.buffer.get_ulong()
    r.client_address = r.p.get_address()
    r.mtu_size = r.p.buffer.get_ushort()//todo u16 or i16?
    r.secure = r.p.buffer.get_bool()
}
