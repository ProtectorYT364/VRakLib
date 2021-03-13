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
	 //c.write(buf)
	
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


	// c.write_to(addr, pong.p.buffer.buffer) or { panic(err)}
	return Packet{
		buffer: new_bytebuffer(buf, u32(read))
		address: addr
	}
}

fn (s UdpSocket) send(p Packet) ?int {
	// TODO - seems to be incomplete in vlang
	// mut addr := C.sockaddr_in{}
	// addr.sin_port = int(p.address.port)
	// C.inet_pton(C.AF_INET, p.address.ip.str, &addr.sin_addr)//TODO look up what this is
	// buffer := p.buffer.buffer
	// length := p.buffer.length
	// size := 16
	// res := int(C.sendto(s.s.sockfd, buffer, length, 0, &addr, size))//TODO find vlang method
	// if res == -1 {
	// return error('Could not send the packet')
	// }
	// return res
	//mut c := s.s//udpconn
	mut c := net.dial_udp(s.a.str(), p.address.str()) or { panic(err) }
	// defer {
	// 	c.close() or {panic(err) }
	// }
	println('dialudp')
	println(c)
	buf := p.buffer.buffer
	//c.write(buf) or { panic(err) }
	c.write_to(p.address, buf) or { panic(err) }
	println('UdpSocket send to $p.address')
	//p.buffer.print()
	c.close()
	return buf.len//TODO
}

fn (mut s UdpSocket) close() {
	s.s.close()
}
