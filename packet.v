module vraklib

import math
import net

const (
    raknet_magic_length = 16

    bitflag_valid = 0x80
    bitflag_ack = 0x40
    bitflag_nak = 0x20

    bitflag_packet_pair = 0x10
    bitflag_continuous_send = 0x08
    bitflag_needs_b_and_as = 0x04
)

pub struct Packet {
pub mut:
    buffer ByteBuffer

    address net.Addr
}

struct EncapsulatedPacket {
pub mut:
    buffer byteptr
    length u16
    reliability byte
    has_split bool
    message_index int
    sequence_index int
    order_index int
    order_channel byte
    split_count int
    split_id u16
    split_index int
    need_ack bool
    identifier_ack int
}

struct Datagram {
// Datagram packets are used to implement a connectionless packet delivery service.
// Each message is routed from one machine to another based solely on information
// contained within that packet. Multiple packets sent from one machine to another
// might be routed differently, and might arrive in any order.
// Packet delivery is not guaranteed.
pub mut:
    p Packet

    packet_id byte
    sequence_number int = -1
    packets []EncapsulatedPacket
}

fn new_packet_from_packet(packet Packet) Packet {
    return Packet {
        buffer: new_bytebuffer(packet.buffer.buffer, packet.buffer.length)
        address: packet.address
    }
}

fn new_packet(buffer byteptr, length u32) Packet {
    return Packet {
        buffer: new_bytebuffer(buffer, length)
    }
}

fn new_packet_from_bytebuffer(buffer ByteBuffer) Packet {
    return Packet {
        buffer: buffer
    }
}

fn get_packet_magic() []byte {
    return [ byte(0x00), 0xff, 0xff, 0x00, 0xfe, 0xfe, 0xfe, 0xfe, 0xfd, 0xfd, 0xfd, 0xfd, 0x12, 0x34, 0x56, 0x78 ]
}

fn (mut p Packet) put_address(address net.Addr) {
    p.buffer.put_byte(4)
    //if address.version == 4 {
        numbers := address.saddr.split('.')
        for num in numbers {
            p.buffer.put_char(i8(~num.int() & 0xFF))
        }
        p.buffer.put_ushort(u16(address.port))
    //}
    //TODO IPv6
}

fn (mut p Packet) get_address() net.Addr {
    ver := p.buffer.get_byte()
    if ver == 4 {
        ip_bytes := p.buffer.get_bytes(4)
        port := p.buffer.get_ushort()//u16(address.port)
        println(ip_bytes.str())//TODO
        println(port.str())//TODO

        //HACK
        address := net.Addr{ saddr: ((-ip_bytes[0]-1)&0xff).str() + '.' + ((-ip_bytes[1]-1)&0xff).str() + '.' + ((-ip_bytes[2]-1)&0xff).str() + '.' + ((-ip_bytes[3]-1)&0xff).str(), port: port}
        println(address)
        return address
    } else {
        panic('Only IPv4 is supported for now')
    }
    //TODO IPv6
}

fn encapsulated_packet_from_binary(p Packet) []EncapsulatedPacket {
    mut packets := []EncapsulatedPacket{}
    mut packet := p
    for packet.buffer.position < packet.buffer.length {
        mut internal_packet := EncapsulatedPacket{}
        flags := packet.buffer.get_byte()
        internal_packet.reliability = (flags & 0xE0) >> 5
        internal_packet.has_split = (flags & 0x10) > 0

        length := int(math.ceil(f32(packet.buffer.get_ushort()) / f32(8)))
        internal_packet.length = u16(length)

        if internal_packet.reliability > reliability_unreliable {
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
        }
        if internal_packet.has_split {
            internal_packet.split_count = packet.buffer.get_int()
            internal_packet.split_id = u16(packet.buffer.get_short())
            internal_packet.split_index = packet.buffer.get_int()
        }
        internal_packet.buffer = packet.buffer.get_bytes(&length).data
        packets << internal_packet
        // println('length: ${internal_packet.length}')
        // println('reliability: ${internal_packet.reliability}')
        // println('has_split: ${internal_packet.has_split}')
        // println('message_index: ${internal_packet.message_index}')
        // println('sequence_index: ${internal_packet.sequence_index}')
        // println('order_index: ${internal_packet.order_index}')
        // println('order_channel: ${internal_packet.order_channel}')
        // println('split_count: ${internal_packet.split_count}')
        // println('split_id: ${internal_packet.split_id}')
        // println('split_index: ${internal_packet.split_index}')
    }
    return packets
}

fn (p EncapsulatedPacket) to_binary() Packet {
    mut packet := Packet{ buffer: new_bytebuffer([byte(0)].repeat(int(p.get_length())).data, p.get_length()) }
    packet.buffer.put_byte(byte(p.reliability << 5 | (if p.has_split { 0x01 } else { 0x00 })))
    packet.buffer.put_ushort(u16(p.length << u16(3)))

    if reliability_is_reliable(p.reliability) {
        packet.buffer.put_ltriad(p.message_index)
    }

    if reliability_is_sequenced(p.reliability) {
        packet.buffer.put_ltriad(p.order_index)
    }
    if reliability_is_sequenced_or_ordered(p.reliability) {
        packet.buffer.put_ltriad(p.order_index)
        packet.buffer.put_byte(p.order_channel)
    }

    if p.has_split {
        packet.buffer.put_int(p.split_count)
        packet.buffer.put_short(i16(p.split_id))
        packet.buffer.put_int(p.split_index)
    }

    packet.buffer.put_bytes(p.buffer, int(p.length))
    return packet
}

fn (e EncapsulatedPacket) get_length() u32 {
    return u32(u16(3) + e.length + u16(if e.message_index != -1 { 3 } else { 0 })
     + u16(if e.order_index != -1 { 4 } else { 0 })
     + u16(if e.has_split { 10 } else { 0 }))
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
    c.p.buffer.buffer = [byte(0)].repeat(int(c.get_total_length())).data

    c.p.buffer.put_byte(byte(bitflag_valid) | c.packet_id)
    c.p.buffer.put_ltriad(c.sequence_number)
    for internal_packet in c.packets {
        packet := internal_packet.to_binary()
        c.p.buffer.put_bytes(packet.buffer.buffer, int(packet.buffer.length))
    }
}