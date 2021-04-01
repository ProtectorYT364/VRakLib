module vraklib

pub struct UnConnectedPong {
//mut:
pub mut://TODO just for debug
	// magic [16]byte
	magic          []byte
	send_timestamp u64
	server_guid    u64
	data           []byte
}

pub fn (mut r UnConnectedPong) encode() ByteBuffer {
	mut b := empty_buffer()
	b.put_byte(id_unconnected_pong)
	b.put_ulong(r.send_timestamp)
	b.put_ulong(r.server_guid)
	r.magic = get_packet_magic()
	b.put_bytes(r.magic)
	//b.put_ushort(u16(r.data.len))
	b.put_ushort(u16(r.data.len))
	b.put_bytes(r.data)
	return b
}

pub fn (mut r UnConnectedPong) decode(mut p Packet) {
	mut b := p.buffer_from_packet()
	b.get_byte()//pid
	r.send_timestamp = u64(b.get_ulong())
	r.server_guid = u64(b.get_ulong())
	r.magic = b.get_bytes(16)
	mut l := u16(b.get_ushort()) // todo u16 or i16?
	r.data = b.get_bytes(l)
}
