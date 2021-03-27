module vraklib

import math
import net

const (
	raknet_magic_length     = 16
	bitflag_valid           = 0x80
	bitflag_datagram        = 0x80
	bitflag_ack             = 0x40
	bitflag_nack            = 0x20
	bitflag_packet_pair     = 0x10
	bitflag_continuous_send = 0x08
	bitflag_needs_b_and_as  = 0x04

	flag_datagram_ack       = 0xc0
	flag_datagram_nack      = 0xa0
)

pub struct Packet {
pub mut:
	buffer  []byte
	address net.Addr
}

fn (p Packet) buffer_from_packet() ByteBuffer {
	return ByteBuffer{
		buffer: p.buffer
	}
}

fn empty_buffer() ByteBuffer {
	return ByteBuffer{
		buffer: []byte{len: max_mtu_size}
	}
}

struct EncapsulatedPacket {
pub mut:
	buffer []byte
	length u16
	// TODO maybe remove?
	reliability   byte
	has_split     bool
	message_index u32
	// u24
	sequence_index u32
	// u24
	order_index u32
	// u24
	order_channel  int
	split_count    u32
	split_id       u16
	split_index    u32
	need_ack       bool
	identifier_ack int
}

fn new_packet_from_packet(packet Packet) Packet { // TODO remove
	return new_packet(packet.buffer, packet.address)
}

pub fn new_packet(buffer []byte, addr net.Addr) Packet {
	return Packet{
		buffer: buffer
		address: addr
	}
}

fn new_packet_from_bytebuffer(buffer ByteBuffer, addr net.Addr) Packet {
	return new_packet(buffer.buffer, addr)
}

fn get_packet_magic() []byte {
	return [byte(0x00), 0xff, 0xff, 0x00, 0xfe, 0xfe, 0xfe, 0xfe, 0xfd, 0xfd, 0xfd, 0xfd, 0x12,
		0x34, 0x56, 0x78]
}

fn (p Packet) has_magic() bool {
	println(string(p.buffer))
	println(string(get_packet_magic()))
	return string(p.buffer).contains(string(get_packet_magic()))
}

fn (p RaklibPacket) has_magic() bool {
	return true
}

fn (mut packet Packet) from_binary(mut b ByteBuffer) EncapsulatedPacket { // AKA "read"
	//mut b := _b
	println('FROM BINARY $b')
	mut internal_packet := EncapsulatedPacket{}
	flags := b.get_byte()
	internal_packet.has_split = (flags & splitflag) != 0
	internal_packet.reliability = (flags & 224) >> 5

	/* if b.feof() {
		error('no bytes left to read')
		return internal_packet
	} */
	mut length := u16(math.ceil(b.get_ushort()))
	length >>= 3
	internal_packet.length = u16(length)

	println('length $length')
	if length == 0 {
		error('null encapsulated packet')
		return internal_packet
	}

	if reliability_is_reliable(internal_packet.reliability) {
		internal_packet.message_index = b.get_ltriad()
	}
	if reliability_is_sequenced(internal_packet.reliability) {
		internal_packet.sequence_index = b.get_ltriad()
	}
	if reliability_is_sequenced_or_ordered(internal_packet.reliability) {
		internal_packet.order_index = b.get_ltriad()
		internal_packet.order_channel = b.get_byte()
	}

	if internal_packet.has_split {
		println('IS SPLIT')
		internal_packet.split_count = u32(b.get_int()) // TODO check if this needs to be uint
		internal_packet.split_id = u16(b.get_short()) // TODO check if this needs to be ushort
		internal_packet.split_index = u32(b.get_int()) // TODO check if this needs to be uint
	}

	internal_packet.buffer = b.get_bytes(int(length))
	println(internal_packet)
	return internal_packet
}

fn (p EncapsulatedPacket) to_binary() ByteBuffer { // AKA write
	println('TO BINARY $p')
	if p.buffer.len > 0 {
		return new_bytebuffer(p.buffer)
	}
	mut b := new_bytebuffer([]byte{})

	// mut packet := new_packet([]byte,net.Addr{'0.0.0.0',19132})//TODO GET IP
	b.put_byte(byte((p.reliability << 5) | (if p.has_split { 0x01 } else { 0x00 })))

	// b.put_ushort(u16(p.buffer.len << 3))
	b.put_short(i16(p.buffer.len << 3))
	if reliability_is_reliable(p.reliability) {
		b.put_ltriad(p.message_index)
	}
	if reliability_is_sequenced(p.reliability) {
		b.put_ltriad(p.order_index)
	}
	if reliability_is_sequenced_or_ordered(p.reliability) {
		b.put_ltriad(p.order_index)

		// Order channel, we don't care about this.
		b.put_byte(byte(p.order_channel))
	}
	if p.has_split {
		b.put_int(int(p.split_count)) // TODO check if this needs to be uint
		b.put_short(i16(p.split_id)) // TODO check if this needs to be ushort
		b.put_int(int(p.split_index)) // TODO check if this needs to be uint
	}

	// b.put_bytes(p.buffer)
	b.put_bytes(p.buffer)

	// println(b)
	// b.trim()
	println(b)

	// return packet
	return b
}

fn (e EncapsulatedPacket) get_length() u32 {
	return u32(u16(3) + e.length + u16(if int(e.message_index) != -1 {
		3
	} else {
		0
	}) + u16(if int(e.order_index) != -1 {
		4
	} else {
		0
	}) + u16(if e.has_split {
		10
	} else {
		0
	}))
}
