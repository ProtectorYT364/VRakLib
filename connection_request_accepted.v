module vraklib

import net

struct ConnectionRequestAccepted {
mut:
	client_address net.Addr
	//[20]net.Addr
	system_addresses   []net.Addr
	request_timestamp  u64
	accepted_timestamp u64
}

pub fn (r ConnectionRequestAccepted) encode() ByteBuffer {
	mut b := empty_buffer()
	b.put_byte(id_connection_request_accepted)
	b.put_address(r.client_address)
	b.put_short(i16(0))
	println(r.system_addresses)
	for _, addr in r.system_addresses {
		println(addr)
		b.put_address(addr)
	}
	b.put_ulong(r.request_timestamp)
	b.put_ulong(r.accepted_timestamp)
	return b
}

pub fn (mut r ConnectionRequestAccepted) decode(mut p Packet) {
	mut b := p.buffer_from_packet()
	b.get_byte() // pid
	r.client_address = b.get_address()
	println(r.client_address)
	b.get_bytes(2)
	for i in 0..20 {//todo check if 10 or 20
		r.system_addresses << b.get_address()
		// if b.remainder() == 16 {
		if b.remainder() <= 16 {
			break
		}
	}
	r.request_timestamp = b.get_ulong()
	r.accepted_timestamp = b.get_ulong()
}
