module vraklib

struct ConnectionRequest {
mut:
	client_guid       u64
	request_timestamp u64
	secure            bool
}
pub fn (r ConnectionRequest) encode() ByteBuffer {
	mut b := empty_buffer()
	b.put_byte(id_connection_request)
	b.put_ulong(r.client_guid)
	b.put_ulong(r.request_timestamp)
	b.put_bool(r.secure)
	return b
}
pub fn (mut r ConnectionRequest) decode(mut p Packet) {
	mut b := p.buffer_from_packet()
	b.get_byte()//pid
	println(p)
	r.client_guid = b.get_ulong()
	println(r.client_guid)
	r.request_timestamp = b.get_ulong()
	println(r.request_timestamp)
	r.secure = b.get_bool()
	println(r.secure)
}
