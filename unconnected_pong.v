module vraklib

pub struct UnConnectedPong {
mut:
	p              Packet
	// magic [16]byte
	magic          []byte
	send_timestamp u64
	server_guid    u64
pub mut://TODO just for debug
	data           []byte
}

pub fn (mut r UnConnectedPong) encode(mut b ByteBuffer) {
	b.put_byte(id_unconnected_pong)
	b.put_ulong(r.send_timestamp)
	b.put_ulong(r.server_guid)
	b.put_bytes(get_packet_magic(), raknet_magic_length)
	b.put_ushort(u16(r.data.len))
	b.put_bytes(r.data, r.data.len)
}

pub fn (mut r UnConnectedPong) decode(mut b ByteBuffer) {
	r.send_timestamp = b.get_ulong()
	r.server_guid = b.get_ulong()
	r.magic = b.get_bytes(raknet_magic_length)
	println('Magic seems fine: $r.magic')
	println('Pos: $b.position')
	//l := u16(b.get_ushort()) // todo u16 or i16?
	mut l := i16(b.get_short()) // todo u16 or i16?
	println('Bytes: $l')
	println('Pos: $b.position')
	// data := []byte{ len: len }
	l = i16(b.length - b.position) // todo u16 or i16?
	println('leftover Bytes: $l')
	println('leftover buffer: $b.buffer')
	r.data = b.get_bytes(l)
}
