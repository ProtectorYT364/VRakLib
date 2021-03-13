module vraklib

struct OpenConnectionRequest1 {
mut:
	p        Packet
	// magic [16]byte
	magic    []byte
	protocol byte
	mtu_size u16
}

fn (mut r OpenConnectionRequest1) encode(mut b ByteBuffer) {
	b.put_byte(id_open_connection_request1)
	b.put_bytes(get_packet_magic(), raknet_magic_length) // TODO check method
	b.put_byte(r.protocol)
	len := int(r.mtu_size - b.len() + 28)
	arr := []byte{len: len}
	b.put_bytes(arr, len)
}

fn (mut r OpenConnectionRequest1) decode(mut b ByteBuffer) {
	r.mtu_size = u16(b.len() + 1) + 28
	r.magic = b.get_bytes(raknet_magic_length)
	r.protocol = b.get_byte()
}
