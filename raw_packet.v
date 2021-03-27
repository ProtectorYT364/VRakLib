module vraklib

pub struct RawPacket {
pub mut:
	// magic [16]byte
	magic          []byte
	send_timestamp u64
	client_guid    u64
}
pub fn (r RawPacket) encode() ByteBuffer {
	return new_bytebuffer([]byte{})
}

pub fn (mut r RawPacket) decode(mut p Packet) {
}
