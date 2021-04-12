module vraklib

import net
import time
import logger

struct SessionManager {
mut:
	server             &VRakLib
	socket             UdpSocket
	sessions           map[int]Session
	session_by_address map[string]Session
	run                bool = true
	stopwatch          time.StopWatch
	port_checking      bool
	current_tick       i64
	next_session_id    int

	ip_blocks map[string]net.Addr
}

const (
	// server_guid = 1234567890
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

pub fn (mut s SessionManager) start() {
	// TODO share sessions with main thread https://github.com/vlang/v/blob/master/doc/docs.md#shared-objects
	mut threads := []thread{}
	threads << go s.listen_socket()
	threads << go s.tick_sessions()
	threads.wait()

	// s.stop()
}

pub fn (mut s SessionManager) stop() {
	logger.log('Stopping SessionManager', .debug)
	s.run = false
	logger.log('Shutdown listen socket', .debug)
	s.socket.close()
}

fn (mut s SessionManager) listen_socket() {
	for s.server.run {
		// receive individual packets
		mut p := s.socket.receive() or {
			if !s.server.run {
				break
			}
			logger.log(err.msg, .error)
			continue
		}
		s.handle(mut p) or {
			logger.log(err.msg, .error)
			continue
		}
	}
	logger.log('Shutdown listen socket', .debug)
}

fn (mut s SessionManager) handle(mut p Packet) ? {
	mut b := p.buffer_from_packet()
	if !s.session_exists(p.address) { // offline message
		pid := b.get_byte()
		match pid {
			id_unconnected_ping, id_unconnected_ping_open_connections {
				s.handle_unconnected_ping(mut p)
			}
			id_open_connection_request1 {
				s.handle_open_connection_request1(mut p)
			}
			id_open_connection_request2 {
				s.handle_open_connection_request2(mut p)
			}
			else {
				println('PKG MATCHER FAILED')
				if pid & bitflag_datagram == 0 {
					return error('unknown packet received $pid: ' + b.buffer.hex())
				}
				return
			}
		}
		return
	}

	// TODO else
	println('pog')
	mut session := s.get_session_by_address(p.address) // online message
	header_flags := b.get_byte()
	println(b.buffer.hex())
	if header_flags & bitflag_datagram == 0 { // ignore non datagram
		println('non-datagram')
		return
	}

	if header_flags & bitflag_ack != 0 {
		s.handle_ack(mut p)
	} else if header_flags & bitflag_nack != 0 {
		s.handle_nack(mut p)
	} else { // handle datagram
		session.handle_datagram(mut &b)
	}
}

fn (mut s SessionManager) handle_ack(mut p Packet) {
	mut ack := Ack{}
	ack.decode(mut p)
	println('handle_ack $ack')

	// TODO remove packet from recovery
}

fn (mut s SessionManager) handle_nack(mut p Packet) {
	mut nack := Nack{}
	nack.decode(mut p)
	println('handle_nack $nack')

	// TODO resend packets from recovery
}

/*
fn (mut s Session) handle_datagram(mut b ByteBuffer) {
	//mut d := Datagram{}
	//d.decode(mut p)
	println('handle_datagram $b')
	s.handle_packet(mut b)
}*/

fn (mut s SessionManager) tick_sessions() {
	for s.server.run {
		/*
		if s.shutdown {
			return
		}
		*/

		// println('tick $s.current_tick')
		// time.usleep(time.Duration.second /* / 80 */)//TODO fix
		/*
		for index, session := range manager.Sessions {
			manager.update_session(session, index)
		}
		*/

		// s.current_tick++
	}
	logger.log('Shutdown tick sessions', .debug)
}

fn (s SessionManager) get_session_by_address(address net.Addr) Session {
	return s.session_by_address[address.str()]
}

fn (s SessionManager) session_exists(address net.Addr) bool {
	return address.str() in s.session_by_address
}

fn (mut s SessionManager) create_session(address net.Addr, client_id u64, mtu_size u16) Session {
	for {
		if s.next_session_id in s.sessions {
			s.next_session_id++
			s.next_session_id &= 0x7fffffff
		} else {
			break
		}
	}
	session := new_session(s, address, client_id, mtu_size, s.next_session_id)
	s.sessions[s.next_session_id] = session
	s.session_by_address[address.str()] = session
	return s.sessions[s.next_session_id]
}

fn (s SessionManager) send_packet(p Packet) {
	s.socket.send(p) or { panic(err) }
}

fn (mut s SessionManager) open_session(session Session) {
	// s.server.open_session(session.internal_id.str(), session.address, session.id)
}

fn (mut s SessionManager) handle_encapsulated(session Session, packet EncapsulatedPacket) {
	println('SM HANDLE ENCAP $packet')

	// s.server.handle_encapsulated(session.internal_id.str(), packet, priority_normal)
}
