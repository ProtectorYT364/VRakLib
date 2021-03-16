module vraklib

// Datagram packets are used to implement a connectionless packet delivery service.
// Each message is routed from one machine to another based solely on information
// contained within that packet. Multiple packets sent from one machine to another
// might be routed differently, and might arrive in any order.
// Packet delivery is not guaranteed.
struct Datagram {
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

fn (mut c Datagram) decode() {
	c.packet_id = c.p.buffer.get_byte()
	c.sequence_number = c.p.buffer.get_ltriad()
	c.packets = encapsulated_packet_from_binary(c.p)
}

fn (mut c Datagram) encode() {
	c.p.buffer.length = c.get_total_length()
	c.p.buffer.buffer = [byte(0)].repeat(int(c.get_total_length()))
	c.p.buffer.put_byte(byte(bitflag_valid) | c.packet_id)
	c.p.buffer.put_ltriad(c.sequence_number)
	for internal_packet in c.packets {
		packet := internal_packet.to_binary()
		c.p.buffer.put_bytes(packet.buffer.buffer, int(packet.buffer.length))
	}
}
