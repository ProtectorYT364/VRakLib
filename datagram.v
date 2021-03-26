module vraklib

// Datagram packets are used to implement a connectionless packet delivery service.
// Each message is routed from one machine to another based solely on information
// contained within that packet. Multiple packets sent from one machine to another
// might be routed differently, and might arrive in any order.
// Packet delivery is not guaranteed.
struct Datagram {
mut:
	packet_pair     bool
	continuous_send bool
	needs_b_and_as    bool
pub mut:
	packet_id       byte
	sequence_number u32 = -1
	packets         []EncapsulatedPacket
}

fn (c Datagram) get_total_length() u32 {
	mut total_length := u32(4)
	for packet in c.packets {
		total_length += packet.get_length()
	}
	return total_length
}

pub fn (mut r Datagram) encode() ByteBuffer {
	mut b := empty_buffer()
	b.put_byte(byte(bitflag_valid) | r.packet_id)
	b.put_ltriad(r.sequence_number)
	for internal_packet in r.packets {
		packet := internal_packet.to_binary()
		b.put_bytes(packet.buffer)
	}
	return b
}

pub fn (mut c Datagram) decode(mut p Packet) {
	mut b := p.buffer_from_packet()
	b.get_byte()//pid
	flags := b.get_byte()
	c.packet_pair = (flags & bitflag_packet_pair) != 0
	c.continuous_send = (flags & bitflag_continuous_send) != 0
	c.needs_b_and_as = (flags & bitflag_needs_b_and_as) != 0

	c.sequence_number = b.get_ltriad()

	for !b.feof(){
		c.packets << p.from_binary(b)
	}
	println(c)
}
