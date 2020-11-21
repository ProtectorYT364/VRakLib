module vraklib

import net

struct ConnectionRequestAccepted {
mut:
    p Packet

    client_address net.Addr
    system_addresses [20]net.Addr
	request_timestamp  u64
	accepted_timestamp u64
}

fn (mut r ConnectionRequestAccepted) encode() {
    r.p.buffer.put_byte(id_connection_request_accepted)
    r.p.put_address(r.client_address)
    r.p.buffer.put_short(i16(0))
    for _, addr in r.system_addresses {
		r.p.put_address(addr)
	}
    r.p.buffer.put_ulong(r.request_timestamp)
    r.p.buffer.put_ulong(r.accepted_timestamp)
}

fn (mut r ConnectionRequestAccepted) decode() {
	r.client_address = r.p.get_address()
	/* _ =  */r.p.buffer.get_bytes(2)
	for i := 0; i < 20; i++ {
		r.system_addresses[i] = r.p.get_address()
		if r.p.buffer.len() == 16 {
			break
		}
	}
    r.request_timestamp = r.p.buffer.get_ulong()
    r.accepted_timestamp = r.p.buffer.get_ulong()
}
