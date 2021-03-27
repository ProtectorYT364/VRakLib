module vraklib

import net
import sync
import time

pub struct VRakLib {
pub mut:
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

pub fn (mut r VRakLib) start() {
	println('RakNet thread starting on $r.address')
	socket := create_socket(r.address) or { panic(err) }

	mut session_manager := new_session_manager(r, socket)
	r.session_manager = session_manager
	session_manager.start()//TODO check if this blocks
}

// timestamp returns a timestamp in milliseconds.
pub fn timestamp() u64 {
	return time.now().unix_time_milli()
}