module vraklib

import net
import sync
import time

pub struct VRakLib {
pub mut:
	channel_sessions     chan OpenSessionData
	channel_encapsulated chan HandleEncapsulatedData
	channel_packetdata   chan PutPacketData
	address              net.Addr
	session_manager      SessionManager
	shutdown             bool
	pong_data PongData
}

pub fn new_vraklib(address net.Addr) &VRakLib {//TODO pass server config for pongdata
	pongdata := PongData{
		server_id: server_guid
		port: address.port
	}
	vr := &VRakLib{
		address: address
		pong_data: pongdata
	}
	return vr
}

// pub fn (mut r VRakLib) start(ch1 chan OpenSessionData, ch2 chan HandleEncapsulatedData, ch3 chan PutPacketData) {
pub fn (mut r VRakLib) start(ch1 chan OpenSessionData, ch2 chan HandleEncapsulatedData, ch3 chan PutPacketData) {
	println('RakNet thread starting')
	println('Address: ' + r.address.str())
	r.shutdown = false // address,
	socket := create_socket(r.address) or { panic(err) }
	 r.channel_sessions = ch1
	 r.channel_encapsulated = ch2
	 r.channel_packetdata = ch3

	mut session_manager := new_session_manager(r, socket)
	r.session_manager = session_manager
	go session_manager.run()
}

// pub fn (mut r VRakLib) stop() {
// 	println('RakNet thread stopping')
// 	r.shutdown = true
// }

fn (r VRakLib) close_session() {
}

fn (mut r VRakLib) open_session(identifier string, address net.Addr, client_id u64) {
	data := OpenSessionData{identifier, address, client_id}
	r.channel_sessions <- data
}

fn (r VRakLib) handle_encapsulated(identifier string, packet EncapsulatedPacket, flags int) {
	println("VRAKLIB HANDLE ENCAPSULATED")
	// p := BatchPacket {}
	// player.handle_data_packet(p)
}

fn (r VRakLib) put_packet(identifier string, packet Packet, need_ack bool, immediate bool) {
	println("VRAKLIB PUT PACKET")
}

fn (r VRakLib) update_ping() {
}

// timestamp returns a timestamp in milliseconds.
pub fn timestamp() u64 {
	return time.now().unix_time_milli()
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
