module vraklib

import net
import time
import bstone
import logger

pub struct VRakLib {
pub mut:
	address net.Addr
	// TODO remove
	session_manager SessionManager
	run             bool = true
	// TODO remove
	pong_data PongData
	settings  shared bstone.Settings
}

pub fn new_vraklib(shared settings bstone.Settings) &VRakLib {
	rlock settings {
		address := settings.addr()
		pongdata := PongData{
			status: ServerStatus{
				server_name: settings.motd
				max_players: settings.max_players
				show_version: settings.show_version
			}
			server_id: server_guid
			gamemode_str: settings.gamemode
			gamemode_int: match settings.gamemode {
				'Survival' { 0 }
				'Creative' { 1 }
				'Adventure' { 2 }
				else { 1 }
			}
			port: address.port
		}
		vr := &VRakLib{
			address: address
			pong_data: pongdata
			settings: settings
		}
		return vr
	}
	panic('Could not create new RakLib instance')
}

pub fn (mut r VRakLib) start() {
	logger.log('RakLib thread starting on $r.address', .debug)
	socket := create_socket(r.address) or { panic(err) }

	mut session_manager := new_session_manager(r, socket)
	r.session_manager = session_manager
	session_manager.start() // TODO check if this blocks
	session_manager.stop()
	r.stop()
}

pub fn (mut r VRakLib) stop() {
	r.run = false
	logger.log('Shutting down RakLib', .debug)
	r.session_manager.stop()
}

// timestamp returns a timestamp in milliseconds.
pub fn timestamp() u64 {
	return time.now().unix_time_milli()
}
