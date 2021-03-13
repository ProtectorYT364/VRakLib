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
	//server_guid = 1234567890
	server_guid = 16966519777446909958
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
		//for i, _ in s.sessions {
		//	s.sessions[i].update()//todo maybe only update current session?
		//}
	}
}

fn (mut s SessionManager) receive_packet() {
	mut packet := s.socket.receive() or { return }
	pid := packet.buffer.get_byte()
	println('received $pid $packet!')
	//packet.buffer.rewind()
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
			title := 'MCPE;Minecraft V Server!;422;1.16.200;0;100;$server_guid;boundstone;Creative;'
			len := 35 + title.len
			mut buf := []byte{len: len}
			mut pong := UnConnectedPong{
				p: new_packet(buf, packet.address)//TODO remove
				server_guid: server_guid
				send_timestamp: ping.send_timestamp
				//send_timestamp: timestamp()
				data: title.bytes()
			}
			//packet.buffer.reset()
			pong.encode(mut pong.p.buffer)
			pong.p.address = packet.address
			s.socket.send(pong.p) or { panic(err) }
		} else if pid == id_open_connection_request1 {
			mut request := OpenConnectionRequest1{
				p: new_packet_from_packet(packet)
			}
			request.decode(mut packet.buffer)
			println(request)
			if request.protocol != 10 {
				mut incompatible := IncompatibleProtocolVersion{
					p: new_packet([]byte{len:26}, packet.address)
					protocol: 10
					server_guid: server_guid
				}
				//packet.buffer.reset()
				incompatible.encode(mut incompatible.p.buffer)
				incompatible.p.address = request.p.address
				// incompatible,
				s.socket.send(incompatible.p) or { panic(err) }
				return
			}
			mut reply := OpenConnectionReply1{
				p: new_packet([]byte{len:28}, packet.address)
				secure: false
				server_guid: server_guid
				mtu_size: request.mtu_size + u16(28)
			}
			//packet.buffer.reset()
			reply.encode(mut reply.p.buffer)
			println(reply)
			reply.p.address = request.p.address
			// reply,
			s.socket.send(reply.p) or { panic(err) }
		} else if pid == id_open_connection_request2 {
			println(packet.buffer.buffer.bytestr())
			packet.buffer.print()
			mut request := OpenConnectionRequest2{
				p: new_packet_from_packet(packet)
			}
			request.decode(mut packet.buffer)
			println(request)
			if request.mtu_size < u16(min_mtu_size) {
				println('Not creating session for $packet.address due to bad MTU size $request.mtu_size')
				return
			}
			mut reply := OpenConnectionReply2{
				p: new_packet([]byte{len:35}, packet.address)
				server_guid: server_guid
				client_address: request.p.address
				mtu_size: request.mtu_size
				secure: false
			}
			//packet.buffer.reset()
			reply.encode(mut reply.p.buffer)
			reply.p.address = request.p.address
			// reply,
			s.socket.send(reply.p) or { panic(err) }
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
	println(p)
	s.socket.send(p) or { panic(err) }
}

fn (mut s SessionManager) open_session(session Session) {
	s.server.open_session(session.internal_id.str(), session.address, session.id)
}

fn (mut s SessionManager) handle_encapsulated(session Session, packet EncapsulatedPacket) {
	s.server.handle_encapsulated(session.internal_id.str(), packet, priority_normal)
}
