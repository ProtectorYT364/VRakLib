module vraklib

struct OpenConnectionRequest1 {
mut:
	// magic [16]byte
	magic    []byte
	protocol byte
	mtu_size u16
}

pub fn (mut r OpenConnectionRequest1) encode() ByteBuffer {
	mut b := empty_buffer()
	b.put_byte(id_open_connection_request1)
	r.magic = get_packet_magic()
	b.put_bytes(r.magic)
	b.put_byte(r.protocol)
	len := int(r.mtu_size + 28)
	arr := []byte{len: len}
	b.put_bytes(arr)
	return b
}

pub fn (mut r OpenConnectionRequest1) decode(mut p Packet) {
	mut b := p.buffer_from_packet()
	b.get_byte() // pid
	r.magic = b.get_bytes(16)
	r.protocol = b.get_byte()
	r.mtu_size = u16(b.len()) + 28
}
