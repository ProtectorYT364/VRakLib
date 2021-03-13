module vraklib

import net

const (
	default_buffer_size = 8388608 // 1024 * 1024 * 8
)

struct UdpSocket {
mut:
	s net.UdpConn
	a net.Addr
}

pub fn create_socket(addr net.Addr) ?UdpSocket {
	// s := net.socket_udp() or { panic(err) }
	// // level, optname, optvalue
	// bufsize := default_buffer_size
	// s.setsockopt(C.SOL_SOCKET, C.SO_RCVBUF, &bufsize)
	// zero := 0
	// s.setsockopt(C.SOL_SOCKET, C.SO_REUSEADDR, &zero)
	// s.bind( port ) or { panic(err) }
	mut conn := net.listen_udp(addr.port) or { panic(err) }
	//mut conn := net.listen_udp(port)?
	println('listening $conn')
	return UdpSocket{conn,addr}
}

fn (s UdpSocket) receive() ?Packet {
	bufsize := default_buffer_size
	mut c := s.s
	mut buf := []byte{len: bufsize/*, init: 0*/}
	read, addr := c.read(mut buf) or { return none }
	//trim buffer
	buf = buf[..read]
	 println('Got address $addr')
	 println('Got $read bytes')
	 println('Got ${buf.data} data')
	 println(c)
	 c.write(buf) or { panic(err) }
	
			title := 'MCPE;Minecraft V Server!;419;1.16.100;0;100;$server_guid;boundstone;Creative;'
			len := 35 + title.len
			mut pong := UnConnectedPong{
				p: new_packet([]byte{len:len}, u32(len))
				server_guid: server_guid
				//send_timestamp: ping.send_timestamp
				send_timestamp: timestamp()
				data: title.bytes()
			}
			//packet.buffer.reset()
			pong.p.address = addr
			pong.encode(mut pong.p.buffer)


	//c.write_to(addr, pong.p.buffer.buffer) or { panic(err)}
	return Packet{
		buffer: new_bytebuffer(buf, u32(read))
		address: addr
	}
}

fn (s UdpSocket) send(p Packet) ?int {
	println('dialudp')
	println('UdpSocket sending to $p.address')

	return 0
}

fn (mut s UdpSocket) close() {
	s.s.close() or { panic(err) }
}
