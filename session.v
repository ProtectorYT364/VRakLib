module vraklib

import net
import time

const (
	max_split_size  = 128
	max_split_count = 4
	channel_count   = 32
	min_mtu_size    = 400
	max_mtu_size    = 1492
	window_size     = 2048 // should be mutable
)

enum State {
	connecting
	connected
	disconnecting
	disconnected
}

struct TmpMapEncapsulatedPacket {
mut:
	m map[string]EncapsulatedPacket
}

struct TmpMapInt {
mut:
	m map[string]int
	// u32?
}

struct Session {
mut: // This is Conn in go-raknet
	message_index u32
	// u24
	send_ordered_index []u32
	// u24
	send_sequenced_index []int
	// u32?
	receive_ordered_index []int
	// u32?
	receive_sequenced_highest_index []int
	// u32?
	receive_ordered_packets [][]EncapsulatedPacket
	session_manager         SessionManager
	// logger logger
	address net.Addr
	state   State
	// connecting
	mtu_size u16
	id       u64
	split_id u32
	// 0
	send_seq_number u32
	// u24
	// 0
	last_update        time.Time
	disconnection_time f32
	is_temporal        bool
	// true
	// packet_to_send                  []Datagram
	datagram_queue DatagramQueue
	is_active      bool
	// false
	ack_queue  map[string]u32
	nack_queue map[string]u32
	// maybe map[int]Datagram, key is seqNumber
	// recovery_queue                  map[string]Datagram
	recovery_queue RecoveryQueue
	split_packets  map[string]TmpMapEncapsulatedPacket
	need_ack       map[string]TmpMapInt
	// u32?
	send_queue_data       Datagram
	window_start          u32
	window_end            u32
	highest_seq_number    u32
	reliable_window_start int
	reliable_window_end   int
	reliable_window       map[string]bool
	last_ping_time        f32
	// -1
	last_ping_measure int
	// 1
	internal_id int
}

fn new_session(session_manager SessionManager, address net.Addr, client_id u64, mtu_size u16, internal_id int) Session {
	println('$address.saddr, $address.port, $client_id, $mtu_size, $internal_id')
	session := Session{
		send_ordered_index: [u32(0)].repeat(vraklib.channel_count)
		send_sequenced_index: [0].repeat(vraklib.channel_count)
		receive_ordered_index: [0].repeat(vraklib.channel_count)
		receive_sequenced_highest_index: [0].repeat(vraklib.channel_count)
		// receive_ordered_packets: [[]EncapsulatedPacket{}].repeat(channel_count)
		session_manager: session_manager
		address: address
		mtu_size: mtu_size
		id: client_id
		send_queue_data: Datagram{}
		internal_id: internal_id
	}
	return session
}

fn (mut s Session) update() {
	println('SESSION UPDATE')
	/*
	diff := s.highest_seq_number - s.window_start + u32(1)
	assert diff > u32(0)
	if diff > u32(0) {// warning: comparison of unsigned expression >= 0 is always true [-Wtype-limits]
		s.window_start += diff
		s.window_end += diff
	}
	if s.ack_queue.len > 0 {
		// packet := Ack()
		// s.ack_queue = map[string]int{}
	}
	if s.nack_queue.len > 0 {
		// packet := Nack()
		// s.nack_queue = map[string]int{}
	}
	if s.need_ack.len > 0 {
		for _, ack in s.need_ack {
			if ack.m.len == 0 {
				// s.need_ack[i]
				// s.session_manager.notify_ack(s, i)
			}
		}
	}
	s.send_queue()*/
	return
}

fn (mut s Session) send_datagram(mut d Datagram) {
	println('SESSION SEND DATAGRAM $d')

	// mut d := datagram
	if d.sequence_number != u32(-1) {
		s.recovery_queue.queue.delete(d.sequence_number.str())
	}
	d.sequence_number = s.send_seq_number
	s.send_seq_number++
	s.recovery_queue.put(d.sequence_number, d)

	// d,
	b := d.encode()
	println(d)
	s.send_packet(mut new_packet_from_bytebuffer(b, s.address))
}

fn (s Session) send_packet(mut p Packet) { // TODO change to RaklibPacket?
	println('SESSION SEND PACKET $p')

	// mut p := _p
	// p.address = s.address
	// r,
	s.session_manager.send_packet(p)
}

fn (mut s Session) send_ping(reliability byte) {
	mut packet := ConnectedPing{
		client_timestamp: u64(s.session_manager.get_raknet_time_ms())
	}
	b := packet.encode()
	s.queue_connected_packet(new_packet_from_bytebuffer(b, s.address), reliability, 0,
		priority_immediate)
}

fn (mut s Session) send_queue() {
	if s.send_queue_data.packets.len > 0 {
		s.send_datagram(mut s.send_queue_data)
		s.send_queue_data = Datagram{
			sequence_number: u32(-1)
		}
	}
}

fn (mut s Session) queue_connected_packet(packet Packet, reliability byte, order_channel int, flag byte) {
	mut encapsulated := EncapsulatedPacket{
		buffer: packet.buffer
		length: u16(packet.buffer.len)
		reliability: reliability
		order_channel: order_channel
	}
	s.add_encapsulated_to_queue(encapsulated, flag)
}

fn (mut s Session) add_to_queue(packet EncapsulatedPacket, flags byte) {
	println('ADD TO QUEUE Packet: $packet Flags: $flags')
	mut p := packet
	priority := flags & 0x07
	if p.need_ack && p.message_index != u32(-1) {
		mut arr := s.need_ack[p.identifier_ack.str()]
		arr.m[p.message_index.str()] = int(p.message_index)
	}
	length := s.send_queue_data.get_total_length()
	if u32(length) + p.get_length() > u32(s.mtu_size - u16(36)) {
		println('too long')
		s.send_queue()
	}
	if p.need_ack {
		println('need ack')
		s.send_queue_data.packets << p
		p.need_ack = false
	} else {
		println('does not need ack')
		s.send_queue_data.packets << p
	}
	if priority == priority_immediate {
		println('prio immediate')
		s.send_queue()
	}
}

fn (mut s Session) add_encapsulated_to_queue(packet EncapsulatedPacket, flags byte) {
	println('ADD ENCAPSULATED TO QUEUE $packet')
	mut p := packet
	p.need_ack = (flags & 0x09) != 0
	println(p.need_ack)
	if p.need_ack {
		s.need_ack[p.identifier_ack.str()] = TmpMapInt{}
	}
	if reliability_is_ordered(p.reliability) {
		p.order_index = s.send_ordered_index[p.order_channel]
		s.send_ordered_index[p.order_channel]++
	} else if reliability_is_sequenced(p.reliability) {
		p.order_index = s.send_ordered_index[p.order_channel]
		p.sequence_index = u32(s.send_sequenced_index[p.order_channel])
		s.send_sequenced_index[p.order_channel]++
	}
	max_size := u16(s.mtu_size) - u16(60)
	if p.length > max_size {
		// mut buffers := []//byte{}
		mut buffers := [][]byte{}
		mut packet_buffers := p.buffer
		for packet_buffers.len > 0 {
			mut end := int(max_size)
			if packet_buffers.len < end {
				end = packet_buffers.len
			}
			println('End: $end')
			buffers << packet_buffers[..end] // push to buffer
			packet_buffers = packet_buffers[end..]
		}
		split_id := s.split_id % 65536
		println('FULL BUFFERS $buffers')
		for count, buffer in buffers {
			mut encapsulated_packet := EncapsulatedPacket{}
			encapsulated_packet.split_id = u16(split_id)
			encapsulated_packet.has_split = true
			encapsulated_packet.split_count = u32(buffers.len)
			encapsulated_packet.reliability = p.reliability
			encapsulated_packet.split_index = u32(count) // int
			encapsulated_packet.buffer << buffer // byte
			encapsulated_packet.length = u16(encapsulated_packet.buffer.len)
			println('Encap new is $encapsulated_packet')
			if reliability_is_reliable(p.reliability) {
				encapsulated_packet.message_index = s.message_index
				s.message_index++
			}
			encapsulated_packet.sequence_index = p.sequence_index
			encapsulated_packet.order_channel = p.order_channel
			encapsulated_packet.order_index = p.order_index
			s.add_to_queue(encapsulated_packet, flags | priority_immediate)
		}
	} else {
		if reliability_is_reliable(p.reliability) {
			p.message_index = s.message_index
			s.message_index++
		}
		s.add_to_queue(p, flags)
	}
}

fn (mut s Session) receive_datagram(d Datagram) {
	s.last_update = time.now()

	// s.SendACK(d.SequenceNumber)
	/*
	mut ack := Ack{
		packets:[d.sequence_number]
		}
		println(ack)
	 b := ack.encode()
	println('Sending ACK $ack')
	s.send_packet(ack.p)//TODO
	*/

	// s.handle_datagram(d)
}

fn (mut s Session) handle_datagram2(d Datagram) {
	for _, packet in d.packets {
		if packet.has_split {
			println('Handle split packet $packet')

			// s.HandleSplitEncapsulated(packet, datagram.Timestamp)
			// TODO FREITAG
		} else {
			println('Handle non-split packet $packet')

			// s.HandleEncapsulated(packet, datagram.Timestamp)
			// TODO FREITAG
		}
	}
}

pub fn (mut s Session) handle_datagram(mut b ByteBuffer) {
	mut d := Datagram{}
	d.decode(mut b)
	println('decoded datagram: $d')
	s.handle_packet(mut d)
}

pub fn (mut s Session) handle_packet(mut p Datagram) {
	// p.decode()//TODO fix
	println('HANDLE DATAGRAM PACKET $p')
	mut ackpks := []u32{}
	ackpks << p.sequence_number
	mut ack := Ack{
		packets: ackpks
	}
	mut b := ack.encode()
	b.trim()
	println('Sending ACK $ack')
	s.send_packet(mut new_packet_from_bytebuffer(b, s.address)) // TODO
	if u32(p.sequence_number) < s.window_start || u32(p.sequence_number) > s.window_end
		|| p.sequence_number.str() in s.ack_queue {
		// Received duplicate or out-of-window packet
		return
	}
	if p.sequence_number.str() in s.nack_queue {
		s.nack_queue.delete(p.sequence_number.str())
	}
	s.ack_queue[p.sequence_number.str()] = u32(p.sequence_number)
	if s.highest_seq_number < u32(p.sequence_number) {
		s.highest_seq_number = u32(p.sequence_number)
	}
	if u32(p.sequence_number) == s.window_start {
		for {
			if s.window_start.str() in s.ack_queue {
				s.window_end++
				s.window_start++
			} else {
				break
			}
		}
	} else if u32(p.sequence_number) > s.window_start {
		mut i := s.window_start
		for i < u32(p.sequence_number) {
			if !(i.str() in s.ack_queue) {
				s.nack_queue[i.str()] = i
			}
			i++
		}
	} else {
		// received packet before widnow start
		return
	}
	for pp in p.packets {
		s.handle_encapsulated_packet(pp)
	}
}

fn (mut s Session) handle_split(packet EncapsulatedPacket) ?EncapsulatedPacket {
	println('HANDLE SPLIT')
	if packet.split_count >= vraklib.max_split_size || packet.split_index >= vraklib.max_split_size {
		return error('Invalid split packet part')
	}
	if !(packet.split_id.str() in s.split_packets) {
		if s.split_packets.len >= vraklib.max_split_size {
			return error('Invalid split packet part')
		}
		mut tmp := TmpMapEncapsulatedPacket{}
		tmp.m[packet.split_index.str()] = packet
		s.split_packets[packet.split_id.str()] = tmp
	} else {
		mut tmp := s.split_packets[packet.split_id.str()]
		tmp.m[packet.split_index.str()] = packet
	}
	if s.split_packets[packet.split_id.str()].m.len == packet.split_count {
		mut p := EncapsulatedPacket{}
		mut buffer := []byte{}
		p.reliability = packet.reliability
		p.message_index = packet.message_index
		p.sequence_index = packet.sequence_index
		p.order_index = packet.order_index
		p.order_channel = packet.order_channel
		for i in 0 .. (int(packet.split_count) - 1) {
			d := s.split_packets[packet.split_id.str()] // vraklib.TmpMapEncapsulatedPacket
			buffer << d.m[i.str()].buffer // vraklib.EncapsulatedPacket.buffer//warning: initialization of 'unsigned char' from 'byteptr' {aka 'unsigned char *'} makes integer from pointer without a cast; note: (near initialization for '(anonymous)[0]')
			// i++
		}
		p.buffer = buffer
		p.length = u16(buffer.len)
		s.split_packets.delete(packet.split_id.str())
		return p
	}
	return error('')
}

fn (mut s Session) handle_encapsulated_packet(packet EncapsulatedPacket) {
	println('HANDLE ENCAPSULATED')
	mut p := packet
	if p.message_index != u32(-1) {
		if p.message_index < s.reliable_window_start || p.message_index > s.reliable_window_end
			|| p.message_index.str() in s.reliable_window {
			return
		}
		s.reliable_window[p.message_index.str()] = true
		if p.message_index == s.reliable_window_start {
			for {
				if s.reliable_window_start.str() in s.reliable_window {
					s.reliable_window.delete(s.reliable_window_start.str())
					s.reliable_window_end++
					s.reliable_window_start++
				} else {
					break
				}
			}
		}
	}
	if packet.has_split {
		pp := s.handle_split(packet) or { return }
		p = pp
	}
	if reliability_is_sequenced_or_ordered(packet.reliability)
		&& (packet.order_channel < 0 || packet.order_channel >= vraklib.channel_count) {
		// Invalid packet
		return
	}
	if reliability_is_sequenced(packet.reliability) {
		if packet.sequence_index < s.receive_sequenced_highest_index[packet.order_channel]
			|| packet.order_index < s.receive_ordered_index[packet.order_channel] {
			// too old sequenced packet
			return
		}
		s.receive_sequenced_highest_index[packet.order_channel] = int(packet.sequence_index + 1)
		s.handle_encapsulated_packet_route(packet)
	} else if reliability_is_ordered(packet.reliability) {
		if packet.order_index == s.receive_ordered_index[packet.order_channel] {
			s.receive_sequenced_highest_index[packet.order_index] = 0
			s.receive_ordered_index[packet.order_channel] = int(packet.order_index + 1)
			s.handle_encapsulated_packet_route(packet)
			mut i := s.receive_ordered_index[packet.order_channel]
			for {
				// d := s.receive_ordered_packets[packet.order_channel]
				// if !d[i] {
				// break
				// }
				dd := s.receive_ordered_packets[packet.order_channel]
				s.handle_encapsulated_packet_route(dd[i])
				s.receive_ordered_packets[packet.order_channel].delete(i)
				i++
			}
			s.receive_ordered_index[packet.order_channel] = i
		} else if packet.order_index > s.receive_ordered_index[packet.order_channel] {
			mut d := s.receive_ordered_packets[packet.order_channel]
			d[packet.order_index] = packet
		} else {
			// duplicate/alredy receive packet
		}
	} else {
		// not ordered or sequenced
		s.handle_encapsulated_packet_route(packet)
	}
}

fn (mut s Session) handle_encapsulated_packet_route(packet EncapsulatedPacket) {
	mut buf := new_bytebuffer(packet.buffer)
	println(buf)
	unsafe {
		pid := buf.get_byte()
		println('Encapsulated, $pid')
		if pid < id_user_packet_enum {
			if s.state == .connecting {
				if pid == id_connection_request {
					mut connection := ConnectionRequest{
						// p: new_packet_from_bytebuffer(buf, s.address)
					}
					p := new_packet_from_bytebuffer(buf, s.address)

					// println(connection.p.buffer)
					connection.decode(mut p)
					println(connection)
					saddr, port := net.split_address('127.0.0.1:$s.session_manager.server.address.port') or {
						println(err)
						return
					} // ?
					sys_addr := net.Addr{
						saddr: saddr
						port: port
					}
					mut accepted := ConnectionRequestAccepted{
						request_timestamp: connection.request_timestamp
						// accepted_timestamp: u64(s.session_manager.get_raknet_time_ms())
						// accepted_timestamp: timestamp()
						accepted_timestamp: connection.request_timestamp
						client_address: s.address
						system_addresses: [s.session_manager.server.address, sys_addr]
					}
					mut b := accepted.encode()
					b.trim()
					s.queue_connected_packet(new_packet_from_bytebuffer(b, s.address),
						reliability_unreliable, 0, priority_immediate)
					println(b.buffer.hex())
					println(accepted)

					// DEBUG
					mut pongd := ConnectionRequestAccepted{}
					mut baf := new_packet(b.buffer, s.address)
					println('BAF $baf')
					pongd.decode(mut baf)
					println(pongd)
					assert accepted.client_address.str() == pongd.client_address.str()
					assert accepted.request_timestamp == pongd.request_timestamp
					assert accepted.accepted_timestamp == pongd.accepted_timestamp

					// TODO assert for server ips
				} else if pid == id_new_incoming_connection {
					mut connection := NewIncomingConnection{}
					pkg := new_packet_from_bytebuffer(buf, s.address)
					connection.decode(mut pkg)
					println(connection)
					if connection.server_address.port == s.session_manager.socket.a.port
						|| !s.session_manager.port_checking {
						s.state = .connected
						s.is_temporal = false
						s.session_manager.open_session(s)
						s.send_ping(reliability_unreliable)
					}
					println('NEW INCOMING CONNECTION')
				}
			} else if pid == id_connected_ping {
				mut ping := ConnectedPing{}
				b := new_packet_from_bytebuffer(buf, s.address)
				ping.decode(mut b)
				println(ping)
			} else if pid == id_connected_pong {
				mut pong := ConnectedPong{}
				b := new_packet_from_bytebuffer(buf, s.address)
				pong.decode(mut b)
				println(pong)
			} else {
				println('Unknown $pid $packet')
			}
		} else if s.state == .connected {
			s.session_manager.handle_encapsulated(s, packet)
		} else {
			// Received packet before connection
		}
	}
}
