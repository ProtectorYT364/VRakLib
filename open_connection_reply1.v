module vraklib

struct OpenConnectionReply1 {
mut:
    p Packet

	//magic [16]byte
	magic []byte
	server_guid u64
	secure bool
	mtu_size u16//todo u16 or i16?
}

fn (mut r OpenConnectionReply1) encode() {
    r.p.buffer.put_byte(id_open_connection_reply1)
    r.p.buffer.put_bytes(get_packet_magic().data, raknet_magic_length)//TODO check method
    r.p.buffer.put_ulong(r.server_guid)
    r.p.buffer.put_bool(r.secure)
    r.p.buffer.put_ushort(r.mtu_size)//todo u16 or i16?
}

fn (mut r OpenConnectionReply1) decode () {
    r.magic = r.p.buffer.get_bytes(16)
    r.server_guid = r.p.buffer.get_ulong()
    r.secure = r.p.buffer.get_bool()
    r.mtu_size = r.p.buffer.get_ushort()//todo u16 or i16?
}
