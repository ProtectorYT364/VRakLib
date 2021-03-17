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
	p               Packet
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

fn (mut c Datagram) encode(mut b ByteBuffer) {
	c.p.buffer = new_bytebuffer([]byte{len:int(c.get_total_length())})//TODO check if this can be removed
	c.p.buffer.put_byte(byte(bitflag_valid) | c.packet_id)
	c.p.buffer.put_ltriad(c.sequence_number)
	for internal_packet in c.packets {
		packet := internal_packet.to_binary()
		c.p.buffer.put_bytes(packet.buffer.buffer)
	}
	//b.trim()
}

fn (mut c Datagram) decode() {
	flags := c.p.buffer.get_byte()
	c.packet_pair = (flags & bitflag_packet_pair) != 0
	c.continuous_send = (flags & bitflag_continuous_send) != 0
	c.needs_b_and_as = (flags & bitflag_needs_b_and_as) != 0

	c.sequence_number = c.p.buffer.get_ltriad()

	println(c)
	for !c.p.buffer.feof(){
		c.packets << c.p.from_binary()
	}
	println(c)
}
