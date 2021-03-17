module vraklib

struct ConnectionRequest {
mut:
	p                 Packet
	client_guid       u64
	request_timestamp u64
	secure            bool
}

fn (mut r ConnectionRequest) encode(mut b ByteBuffer) {
	b.put_byte(id_connection_request)
	b.put_ulong(r.client_guid)
	b.put_ulong(r.request_timestamp)
	b.put_bool(r.secure)
	b.trim()
}

fn (mut r ConnectionRequest) decode(mut b ByteBuffer) {
	//b.get_byte()
	println(r.p)
	r.client_guid = b.get_ulong()
	println(r.client_guid)
	r.request_timestamp = b.get_ulong()
	println(r.request_timestamp)
	r.secure = b.get_bool()
	println(r.secure)
}
