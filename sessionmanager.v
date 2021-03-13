module vraklib

import net
import time

struct SessionManager {
mut:
	server             &VRakLib
	socket             UdpSocket
	sessions           map[string]Session
	session_by_address map[string]Session
	shutdown           bool
	stopwatch          time.StopWatch
	port_checking      bool
	next_session_id    int
}

const(
	server_guid = 123456789
)

pub fn new_session_manager(r &VRakLib, socket UdpSocket) &SessionManager {
	sm := &SessionManager{
		server: r
		socket: socket
		stopwatch: time.new_stopwatch({})
	}
	return sm
}

fn (s SessionManager) get_raknet_time_ms() i64 {
	return s.stopwatch.elapsed().milliseconds()
}

pub fn (mut s SessionManager) run() {
	for !s.shutdown {
		s.receive_packet()
		for i, _ in s.sessions {
			s.sessions[i].update()
		}
	}
}

fn (mut s SessionManager) receive_packet() {
	mut packet := s.socket.receive() or { return }
	// if packet.address.saddr != '192.168.43.240' { return }
	println('received!')
	println(packet)
	//s.shutdown = true
	//return
	 //TODO debug, remove ^
	packet.buffer.print()
	pid := packet.buffer.get_byte()
	if s.session_exists(packet.address) {
		println('Session exists: $packet.address')
		mut session := s.get_session_by_address(packet.address)
		if (pid & bitflag_valid) != 0 {
			println('valid $pid')
			if (pid & bitflag_ack) != 0 {
				println('ack $pid')
				// ACK
				println('ack')
			} else if (pid & bitflag_nak) != 0 {
				println('nack $pid')
				// NACK
				println('nack')
			} else {
				println('datagram $pid')
				datagram := Datagram{
					p: new_packet_from_packet(packet)
				}
				session.handle_packet(datagram)
			}
		}
	} else {
		println('Session not found: $packet.address $pid')
		if pid == id_unconnected_ping {
			mut ping := UnConnectedPing{
				p: new_packet_from_packet(packet)
			}
			ping.decode(mut packet.buffer)
			title := 'MCPE;Minecraft V Server!;419;1.16.100;0;100;$server_guid;boundstone;Creative;'
			len := 35 + title.len
			mut pong := UnConnectedPong{
				p: new_packet([]byte{len:len}, u32(len))
				server_guid: server_guid
				send_timestamp: ping.send_timestamp
				data: title.bytes()
			}
			//packet.buffer.reset()
			pong.encode(mut pong.p.buffer)
			println(pong)
			pong.p.address = ping.p.address
			// pong,
			s.socket.send(pong.p)
		} else if pid == id_open_connection_request1 {
			mut request := OpenConnectionRequest1{
				p: new_packet_from_packet(packet)
			}
			request.decode()
			if request.protocol != 9 {
				mut incompatible := IncompatibleProtocolVersion{
					p: new_packet([]byte{len:26}, u32(26))
					protocol: 10
					server_guid: server_guid
				}
				//packet.buffer.reset()
				incompatible.encode()
				incompatible.p.address = request.p.address
				// incompatible,
				s.socket.send(incompatible.p)
				return
			}
			mut reply := OpenConnectionReply1{
				p: new_packet([]byte{len:28}, u32(28))
				secure: false
				server_guid: server_guid
				mtu_size: request.mtu_size + u16(28)
			}
			//packet.buffer.reset()
			reply.encode()
			reply.p.address = request.p.address
			// reply,
			s.socket.send(reply.p)
		} else if pid == id_open_connection_request2 {
			mut request := OpenConnectionRequest2{
				p: new_packet_from_packet(packet)
			}
			request.decode()
			if request.mtu_size < u16(min_mtu_size) {
				println('Not creating session for $packet.address due to bad MTU size $request.mtu_size')
				return
			}
			mut reply := OpenConnectionReply2{
				p: new_packet([]byte{len:35}, u32(35))
				server_guid: server_guid
				client_address: request.p.address
				mtu_size: request.mtu_size
				secure: false
			}
			//packet.buffer.reset()
			reply.encode()
			reply.p.address = request.p.address
			// reply,
			s.socket.send(reply.p)
			s.create_session(request.p.address, request.client_guid, request.mtu_size)
		}
	}
}

fn (s SessionManager) get_session_by_address(address net.Addr) Session {
	return s.session_by_address[address.str()]
}

fn (s SessionManager) session_exists(address net.Addr) bool {
	return address.str() in s.session_by_address
}

fn (mut s SessionManager) create_session(address net.Addr, client_id u64, mtu_size u16) Session {
	for {
		if s.next_session_id.str() in s.sessions {
			s.next_session_id++
			s.next_session_id &= 0x7fffffff
		} else {
			break
		}
	}
	session := new_session(s, address, client_id, mtu_size, s.next_session_id)
	s.sessions[s.next_session_id.str()] = session
	s.session_by_address[address.str()] = session
	return s.sessions[s.next_session_id.str()]
}

fn (s SessionManager) send_packet(p Packet) {
	s.socket.send(p)
}

fn (mut s SessionManager) open_session(session Session) {
	s.server.open_session(session.internal_id.str(), session.address, session.id)
}

fn (mut s SessionManager) handle_encapsulated(session Session, packet EncapsulatedPacket) {
	s.server.handle_encapsulated(session.internal_id.str(), packet, priority_normal)
}
