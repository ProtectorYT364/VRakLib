module vraklib

import net

struct NewIncomingConnection {
mut:
	server_address     net.Addr
	system_addresses   [10]net.Addr//TODO check if 10 or 20
	request_timestamp  u64
	accepted_timestamp u64
}

pub fn (r NewIncomingConnection) encode() ByteBuffer {
	mut b := empty_buffer()
	b.put_byte(id_new_incoming_connection)
	b.put_address(r.server_address)
	for _, addr in r.system_addresses {
		b.put_address(addr)
	}
	b.put_ulong(r.request_timestamp)
	b.put_ulong(r.accepted_timestamp)
	return b
}

pub fn (mut r NewIncomingConnection) decode(mut p Packet) {
	mut b := p.buffer_from_packet()
	b.get_byte() // pid
	r.server_address = b.get_address()
	for i := 0; i < 10; i++ {
		r.system_addresses[i] = b.get_address()
		if b.len() == 16 {
			break
		}
	}
	r.request_timestamp = b.get_ulong()
	r.accepted_timestamp = b.get_ulong()
}
