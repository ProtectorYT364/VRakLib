module vraklib

struct OpenConnectionReply1 {
mut:
	p           Packet
	// magic [16]byte
	magic       []byte
	server_guid u64
	secure      bool
	mtu_size    u16 // todo u16 or i16?
}

fn (mut r OpenConnectionReply1) encode(mut b ByteBuffer) {
	b.put_byte(id_open_connection_reply1)
	b.put_bytes(get_packet_magic()) // TODO check method
	b.put_ulong(r.server_guid)
	b.put_bool(r.secure)
	b.put_ushort(r.mtu_size) // todo u16 or i16?
	b.trim()
}

fn (mut r OpenConnectionReply1) decode(mut b ByteBuffer) {
	r.magic = b.get_bytes(get_packet_magic().len)
	r.server_guid = b.get_ulong()
	r.secure = b.get_bool()
	r.mtu_size = b.get_ushort() // todo u16 or i16?
}
