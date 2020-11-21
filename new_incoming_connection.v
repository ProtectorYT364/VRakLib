module vraklib

import net

struct NewIncomingConnection {
mut:
    p Packet

    server_address net.Addr
    system_addresses [20]net.Addr
    request_timestamp u64
    accepted_timestamp u64
}

fn (mut r NewIncomingConnection) encode() {
	r.p.buffer.put_byte(id_new_incoming_connection)
	r.p.put_address(r.server_address)
	for _, addr in r.system_addresses {
		r.p.put_address(addr)
	}
    r.p.buffer.put_ulong(r.request_timestamp)
    r.p.buffer.put_ulong(r.accepted_timestamp)
}

fn (mut r NewIncomingConnection) decode() {
    r.server_address = r.p.get_address()
	for i := 0; i < 20; i++ {
		r.system_addresses[i] = r.p.get_address()
		if r.p.buffer.len() == 16 {
			break
		}
	}
    r.request_timestamp = r.p.buffer.get_ulong()
    r.accepted_timestamp = r.p.buffer.get_ulong()
}