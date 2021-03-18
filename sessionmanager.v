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
	current_tick      i64
	next_session_id    int

	ip_blocks map[string]net.Addr
}

const(
	server_guid = 1234567890
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

pub fn (mut s SessionManager) start() {
	//TODO share sessions with main thread https://github.com/vlang/v/blob/master/doc/docs.md#shared-objects
	mut threads := []thread{}
	threads << go s.process_incoming_packets()
	threads << go s.tick_sessions()
	threads.wait()
}

fn (mut s SessionManager) process_incoming_packets() {
	mut p := s.socket.receive() or { return }
	//TODO IP block check
	mut pk := p.get_packet_from_match(s.session_exists(p.address))//also decodes
	println(pk)

	//raw packet function

	if pk.has_magic(){
		s.handle_unconnected_message(pk, p)
	}else{
		if !s.session_exists(p.address){ return}
		mut session := s.get_session_by_address(p.address)
		match pk{
			Datagram{
				//session.ReceiveWindow.AddDatagram(datagram)
			}
			/* Ack{
				//session.HandleACK(ack)
			}
			Nak{
				//session.HandleNACK(nack)
			} *///TODO
			else{}
		}
	}
}

fn(mut s SessionManager) tick_sessions(){
	for {
		if s.shutdown {
			return
		}
		return
		//println('tick $s.current_tick')
		//time.usleep(time.Duration.second /* / 80 */)//TODO fix
		/* for index, session := range manager.Sessions {
			manager.update_session(session, index)
		} */
		//s.current_tick++
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
	println('SESSION MANAGER SEND PACKET $p')
	s.socket.send(p) or { panic(err) }
}

fn (mut s SessionManager) open_session(session Session) {
	//s.server.open_session(session.internal_id.str(), session.address, session.id)
}

fn (mut s SessionManager) handle_encapsulated(session Session, packet EncapsulatedPacket) {
	println('SM HANDLE ENCAP $packet')
	//s.server.handle_encapsulated(session.internal_id.str(), packet, priority_normal)
}
