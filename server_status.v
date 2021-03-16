module vraklib

struct ServerStatus{
	server_name string = 'MOTD'
	player_count int
	max_players int = 1337
	show_version bool = true
}
struct PongData{
	pub mut:
	status ServerStatus
	current_protocol int = 422//TODO move to protocol
	server_id int
	gamemode_str string = 'Creative'
	gamemode_int int = 1//TODO gamemode struct
	port int = 19132//TODO net addr port
	software string = 'boundstone'//validate
}

fn(mut p PongData) update_pong_data() string{
	p.server_id = server_guid
	mut ver := ''
	if p.status.show_version { ver = '1.16.200'}//todo get from protocol.current_version
	return 'MCPE;$p.status.server_name;$p.current_protocol;$ver;$p.status.player_count;$p.status.max_players;$server_guid;$p.software;$p.gamemode_str;$p.gamemode_int;$p.port;$p.port;'
	//TODO check if gamemode_int and port are needed or valid
}