module vraklib

pub struct UnConnectedPong {
//mut:
pub mut://TODO just for debug
	p              Packet
	// magic [16]byte
	magic          []byte
	send_timestamp u64
	server_guid    u64
	data           []byte
}

pub fn (mut r UnConnectedPong) encode(mut b ByteBuffer) {
	b.put_byte(id_unconnected_pong)
	b.put_ulong(r.send_timestamp)
	b.put_ulong(r.server_guid)
	r.magic = get_packet_magic()
	b.put_bytes(r.magic)
	b.put_ushort(u16(r.data.len))
	b.put_bytes(r.data)
	b.trim()
}

pub fn (mut r UnConnectedPong) decode(mut b ByteBuffer) {
	r.send_timestamp = b.get_ulong()
	r.server_guid = b.get_ulong()
	r.magic = b.get_bytes(get_packet_magic().len)
	mut l := i16(b.get_short()) // todo u16 or i16?
	println(l)
	// data := []byte{ len: len }
	l = i16(b.length - b.position) // todo u16 or i16?
	r.data = b.get_bytes(l)
}
