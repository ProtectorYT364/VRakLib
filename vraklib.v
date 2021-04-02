module vraklib

import net
import time
import bstone

pub struct VRakLib {
pub mut:
	address         net.Addr
	session_manager SessionManager
	shutdown        bool
	pong_data       PongData
	config          shared bstone.ServerConfig
	logger          shared bstone.Log
}

pub fn new_vraklib(shared config bstone.ServerConfig, shared logger bstone.Log) &VRakLib { // TODO pass server config for pongdata
	address := rlock config {
		config.addr
	}
	pongdata := PongData{
		server_id: server_guid
		port: address.port
	}
	vr := &VRakLib{
		address: address
		pong_data: pongdata
		config: config
		logger: logger
	}
	return vr
}

pub fn (mut r VRakLib) start() {
	r.logger().log('RakLib thread starting on $r.address', .debug)
	socket := create_socket(r.address, shared r.logger()) or { panic(err) }

	mut session_manager := new_session_manager(r, socket)
	r.session_manager = session_manager
	session_manager.start() // TODO check if this blocks
	session_manager.stop()
	r.stop()
}

pub fn (mut r VRakLib) stop() {
	r.logger().log('Shutting down RakLib', .debug)
	r.shutdown = true
	r.session_manager.stop()
}

// timestamp returns a timestamp in milliseconds.
pub fn timestamp() u64 {
	return time.now().unix_time_milli()
}

pub fn (s VRakLib) logger() shared bstone.Log {
	return s.logger
}
