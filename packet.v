module vraklib

import math
import net

const (
	raknet_magic_length     = 16
	bitflag_valid           = 0x80
	bitflag_ack             = 0x40
	bitflag_nak             = 0x20
	bitflag_packet_pair     = 0x10
	bitflag_continuous_send = 0x08
	bitflag_needs_b_and_as  = 0x04
)

pub struct Packet {
pub mut:
	buffer  ByteBuffer
	address net.Addr
}

struct EncapsulatedPacket {
pub mut:
	buffer         []byte
	length         u16
	reliability    byte
	has_split      bool
	message_index  u32 //u24
	sequence_index u32 //u24
	order_index    u32 //u24
	order_channel  int
	split_count    u32
	split_id       u16
	split_index    u32
	need_ack       bool
	identifier_ack int
}

fn new_packet_from_packet(packet Packet) Packet {
	return new_packet(packet.buffer.buffer, packet.address)
}

pub fn new_packet(buffer []byte, addr net.Addr) Packet {
	buf := new_bytebuffer(buffer)
	return new_packet_from_bytebuffer(buf, addr)
}

fn new_packet_from_bytebuffer(buffer ByteBuffer, addr net.Addr) Packet {
	return Packet{
		buffer: buffer
	 	address: addr
	}
}

fn get_packet_magic() []byte {
	return [byte(0x00), 0xff, 0xff, 0x00, 0xfe, 0xfe, 0xfe, 0xfe, 0xfd, 0xfd, 0xfd, 0xfd, 0x12,
		0x34, 0x56, 0x78]
}

fn encapsulated_packet_from_binary(p Packet) []EncapsulatedPacket {//AKA "read"
println('FROM BINARY $p')
	mut packets := []EncapsulatedPacket{}
	mut packet := p
	for packet.buffer.position < packet.buffer.length {//todo add feof to binarystream: !feof
		mut internal_packet := EncapsulatedPacket{}
		flags := packet.buffer.get_byte()
		println('flags: $flags')
		internal_packet.reliability = (flags & 0xE0) >> 5
		internal_packet.has_split = (flags & splitflag) != 0
		length := packet.buffer.get_ushort()/8
		internal_packet.length = u16(length)
		//if length 0: error
			if reliability_is_reliable(internal_packet.reliability) {
				internal_packet.message_index = packet.buffer.get_ltriad()
			}
			if reliability_is_sequenced(internal_packet.reliability) {
				internal_packet.sequence_index = packet.buffer.get_ltriad()
			}
			if reliability_is_sequenced_or_ordered(internal_packet.reliability) {
				internal_packet.order_index = packet.buffer.get_ltriad()
				internal_packet.order_channel = packet.buffer.get_byte()
			}
		if internal_packet.has_split {
			internal_packet.split_count = u32(packet.buffer.get_int())//TODO check if this needs to be uint
			internal_packet.split_id = u16(packet.buffer.get_short())//TODO check if this needs to be ushort
			internal_packet.split_index = u32(packet.buffer.get_int())//TODO check if this needs to be uint
		}
		internal_packet.buffer = packet.buffer.get_bytes(length)
		println(internal_packet)
		packets << internal_packet
	}
	return packets
}

fn (p EncapsulatedPacket) to_binary() Packet {//AKA write
println('TO BINARY $p')
	mut packet := Packet{
		buffer: new_bytebuffer([]byte{len:int(p.get_length())})
	}
	packet.buffer.put_byte(byte(p.reliability << 5 | (if p.has_split {
		0x01
	} else {
		0x00
	})))
	packet.buffer.put_ushort(u16(p.length << u16(3)))
	if reliability_is_reliable(p.reliability) {
		packet.buffer.put_ltriad(p.message_index)
	}
	if reliability_is_sequenced(p.reliability) {
		packet.buffer.put_ltriad(p.order_index)
	}
	if reliability_is_sequenced_or_ordered(p.reliability) {
		packet.buffer.put_ltriad(p.order_index)
		// Order channel, we don't care about this.
		packet.buffer.put_byte(0)
	}
	if p.has_split {
		packet.buffer.put_int(int(p.split_count))//TODO check if this needs to be uint
		packet.buffer.put_short(i16(p.split_id))//TODO check if this needs to be ushort
		packet.buffer.put_int(int(p.split_index))//TODO check if this needs to be uint
	}
	packet.buffer.put_bytes(p.buffer, int(p.length))
	return packet
}

fn (e EncapsulatedPacket) get_length() u32 {
    return u32(u16(3) + e.length + u16(if int(e.message_index) != -1 { 3 } else { 0 })
     + u16(if int(e.order_index) != -1 { 4 } else { 0 })
     + u16(if e.has_split { 10 } else { 0 }))
}