module vraklib

import net

struct NewIncomingConnection {
mut:
	p                  Packet
	server_address     net.Addr
	system_addresses   [20]net.Addr
	request_timestamp  u64
	accepted_timestamp u64
}

fn (mut r NewIncomingConnection) encode(mut b ByteBuffer) {
	b.put_byte(id_new_incoming_connection)
	b.put_address(r.server_address)
	for _, addr in r.system_addresses {
		b.put_address(addr)
	}
	b.put_ulong(r.request_timestamp)
	b.put_ulong(r.accepted_timestamp)
}

fn (mut r NewIncomingConnection) decode(mut b ByteBuffer) {
	r.server_address = b.get_address()
	for i := 0; i < 20; i++ {
		r.system_addresses[i] = b.get_address()
		if b.len() == 16 {
			break
		}
	}
	r.request_timestamp = b.get_ulong()
	r.accepted_timestamp = b.get_ulong()
}
