module vraklib

import net

const (
	default_buffer_size = 8388608 // 1024 * 1024 * 8
)

struct UdpSocket {
mut:
	s net.UdpConn
}

pub fn create_socket(port int) ?UdpSocket {
	// s := net.socket_udp() or { panic(err) }
	// // level, optname, optvalue
	// bufsize := default_buffer_size
	// s.setsockopt(C.SOL_SOCKET, C.SO_RCVBUF, &bufsize)
	// zero := 0
	// s.setsockopt(C.SOL_SOCKET, C.SO_REUSEADDR, &zero)
	// s.bind( port ) or { panic(err) }
	//mut conn := net.listen_udp(port) or { panic(err) }
	mut conn := net.listen_udp(port)?
	return UdpSocket{conn}
}

fn (s UdpSocket) receive() ?Packet {
	bufsize := default_buffer_size
	mut c := s.s
	mut buf := []byte{len: bufsize, init: 0}
	read, addr := c.read(mut buf) or { return none }
	mut test := buf.str()
	// println('Got address $addr')
	// println('Got $read bytes')
	// println('Got ${buf.data} bytes')
	return Packet{
		buffer: new_bytebuffer(&test, u32(read))
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
	println('UdpSocket send')
	println(p.address)
	p.buffer.print()
}

fn (s UdpSocket) close() {
	s.s.close()
}
