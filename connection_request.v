module vraklib

struct ConnectionRequest {
mut:
    p Packet

	client_guid u64
	request_timestamp u64
	secure bool
}

fn (mut r ConnectionRequest) encode() {
    r.p.buffer.put_byte(id_connection_request)
    r.p.buffer.put_ulong(r.client_guid)
    r.p.buffer.put_ulong(r.request_timestamp)
    r.p.buffer.put_bool(r.secure)
}

fn (mut r ConnectionRequest) decode() {
    r.p.buffer.get_byte()
    r.client_guid = r.p.buffer.get_ulong()
    r.request_timestamp = r.p.buffer.get_ulong()
    r.secure = r.p.buffer.get_bool()
}
