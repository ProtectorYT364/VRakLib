module vraklib

import net

struct ConnectionRequestAccepted {
mut:
	p                  Packet
	client_address     net.Addr
	system_addresses   [20]net.Addr
	request_timestamp  u64
	accepted_timestamp u64
}

fn (mut r ConnectionRequestAccepted) encode(mut b ByteBuffer) {
	b.put_byte(id_connection_request_accepted)
	r.p.put_address(r.client_address)
	b.put_short(i16(0))
	for _, addr in r.system_addresses {
		r.p.put_address(addr)
	}
	b.put_ulong(r.request_timestamp)
	b.put_ulong(r.accepted_timestamp)
}

fn (mut r ConnectionRequestAccepted) decode(mut b ByteBuffer) {
	r.client_address = r.p.get_address() // _ =
	b.get_bytes(2)
	for i := 0; i < 20; i++ {
		r.system_addresses[i] = r.p.get_address()
		if b.len() == 16 {
			break
		}
	}
	r.request_timestamp = b.get_ulong()
	r.accepted_timestamp = b.get_ulong()
}
