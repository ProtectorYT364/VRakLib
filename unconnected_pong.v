module vraklib

struct UnConnectedPong {
mut:
	p              Packet
	// magic [16]byte
	magic          []byte
	send_timestamp u64
	server_guid    u64
	data           []byte
}

fn (mut r UnConnectedPong) encode() {
	r.p.buffer.put_byte(id_unconnected_pong)
	r.p.buffer.put_ulong(r.send_timestamp)
	r.p.buffer.put_ulong(r.server_guid)
	r.p.buffer.put_bytes(get_packet_magic().data, raknet_magic_length)
	r.p.buffer.put_ushort(u16(r.data.len))
	r.p.buffer.put_bytes(&r.data, r.data.len)
}

fn (mut r UnConnectedPong) decode() {
	r.send_timestamp = r.p.buffer.get_ulong()
	r.server_guid = r.p.buffer.get_ulong()
	r.magic = r.p.buffer.get_bytes(raknet_magic_length)
	l := u16(r.p.buffer.get_ushort()) // todo u16 or i16?
	// data := []byte{ len: len }
	r.data = r.p.buffer.get_bytes(l)
}
