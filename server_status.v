module vraklib

struct ServerStatus {
mut:
	server_name  string = 'MOTD'
	player_count int
	max_players  int  = 1337
	show_version bool = true
}

pub struct PongData {
pub mut:
	status           ServerStatus
	current_protocol int = 422
	// TODO move to protocol
	version   string = '1.16.200'
	server_id int
	// u64?
	gamemode_str string = 'Creative'
	gamemode_int int    = 1
	// TODO gamemode struct
	port int = 19132
	// TODO net addr port
	software string = 'boundstone'
	// validate
}

pub fn (mut p PongData) update_pong_data() string {
	p.server_id = server_guid
	mut ver := p.version
	if !p.status.show_version {
		ver = ''
	}

	// todo get from protocol.current_version
	return 'MCPE;$p.status.server_name;$p.current_protocol;$ver;$p.status.player_count;$p.status.max_players;$server_guid;$p.software;$p.gamemode_str;$p.gamemode_int;$p.port;$p.port;'

	// TODO check if gamemode_int and port are needed or valid
}

pub fn (mut p PongData) from_string(_data string) {
	data := _data.trim_right(';')
	mut splitted := data.split(';')

	// todo error if not enough data
	splitted = splitted[1..] // trim 'MCPE'
	p.status.server_name = splitted[0]
	p.current_protocol = splitted[1].int()
	p.version = splitted[2]
	p.status.player_count = splitted[3].int()
	p.status.max_players = splitted[4].int()
	p.server_id = splitted[5].int()
	p.software = splitted[6]
	p.gamemode_str = splitted[7]
	if splitted.len > 8 {
		p.gamemode_int = splitted[8].int()
	}
	if splitted.len > 9 {
		p.port = splitted[9].int()
	}

	// idk why there are 2 ports, ignore for now
}
