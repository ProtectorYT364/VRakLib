module vraklib

import net
import sync

pub struct VRakLib {
pub mut:
	channel_sessions     chan OpenSessionData
	channel_encapsulated chan HandleEncapsulatedData
	channel_packetdata   chan PutPacketData
	port                 int
	address              net.Addr
	// session_manager &SessionManager
	session_manager      &SessionManager
	shutdown             bool
}

// pub fn (mut r VRakLib) start(ch1 chan OpenSessionData, ch2 chan HandleEncapsulatedData, ch3 chan PutPacketData) {
pub fn (mut r VRakLib) start(address net.Addr) {
	println('RakNet thread starting')
	println('Address: ' + address.str())
	r.shutdown = false // address,
	socket := create_socket(r.port) or { panic(err) }
	// r.address = socket.s.sock.address() or { panic(err) }
	r.address = address
	println(r.port)
	println(r.address)
	mut session_manager := new_session_manager(r, socket)
	r.session_manager = session_manager
	// r.channel_sessions = ch1
	// r.channel_encapsulated = ch2
	// r.channel_packetdata = ch3
	go session_manager.run()
}

pub fn (mut r VRakLib) stop() {
	println('RakNet thread stopping')
	r.shutdown = true
}

fn (r VRakLib) close_session() {
}

fn (mut r VRakLib) open_session(identifier string, address net.Addr, client_id u64) {
	data := OpenSessionData{identifier, address, client_id}
	r.channel_sessions <- data
}

fn (r VRakLib) handle_encapsulated(identifier string, packet EncapsulatedPacket, flags int) {
	// p := BatchPacket {}
	// player.handle_data_packet(p)
}

fn (r VRakLib) put_packet(identifier string, packet Packet, need_ack bool, immediate bool) {
}

fn (r VRakLib) update_ping() {
}

struct OpenSessionData {
mut:
	identifier string
	address    net.Addr
	client_id  u64
}

struct HandleEncapsulatedData {
mut:
	identifier string
	packet     EncapsulatedPacket
	flags      int
}

struct PutPacketData {
mut:
	identifier string
	packet     EncapsulatedPacket
	flags      int
}
