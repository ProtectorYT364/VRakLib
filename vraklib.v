module vraklib

import vraklib.utils
import vraklib.server

struct VRakLib {
mut:
    address utils.InternetAddress
    session_manager &server.SessionManager
    shutdown bool
}

pub fn (mut r VRakLib) start(ch1 chan OpenSessionData, ch2 chan HandleEncapsulatedData, ch3 chan PutPacketData) {
    r.shutdown = false

    socket := create_socket(r.address.ip, int(r.address.port)) or { panic(err) }
    session_manager := new_session_manager(r, socket)
    r.session_manager = session_manager

    go session_manager.run()
}

pub fn (mut r VRakLib) stop() {
    r.shutdown = true
}

fn (r VRakLib) close_session() {

}

fn (mut r VRakLib) open_session(identifier string, address utils.InternetAddress, client_id u64) {
}

fn (r VRakLib) handle_encapsulated(identifier string, packet server.EncapsulatedPacket, flags int) {


        //p := BatchPacket {}
        //player.handle_data_packet(p)
}

fn (r VRakLib) put_packet(identifier string, packet server.Packet, need_ack bool, immediate bool) {

}

fn (r VRakLib) update_ping() {
    
}


struct OpenSessionData {
mut:
	identifier string
    address utils.InternetAddress
    client_id u64
}

struct HandleEncapsulatedData {
mut:
	identifier string
    packet server.EncapsulatedPacket
    flags int
}

struct PutPacketData {
mut:
	identifier string
    packet server.EncapsulatedPacket
    flags int
}