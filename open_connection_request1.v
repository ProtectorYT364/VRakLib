module vraklib

struct OpenConnectionRequest1 {
mut:
	p        Packet
	// magic [16]byte
	magic    []byte
	protocol byte
	mtu_size u16
}

fn (mut r OpenConnectionRequest1) encode() {
	r.p.buffer.put_byte(id_open_connection_request1)
	r.p.buffer.put_bytes(get_packet_magic().data, raknet_magic_length) // TODO check method
	r.p.buffer.put_byte(r.protocol)
	len := int(r.mtu_size - r.p.buffer.len() + 28)
	arr := []byte{len: len}
	r.p.buffer.put_bytes(&arr, len)
}

fn (mut r OpenConnectionRequest1) decode() {
	r.mtu_size = u16(r.p.buffer.len() + 1) + 28
	r.magic = r.p.buffer.get_bytes(raknet_magic_length)
	r.protocol = r.p.buffer.get_byte()
}
