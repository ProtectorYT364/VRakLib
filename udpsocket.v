module vraklib

import net
import bstone

const (
	default_buffer_size = 8388608 // 1024 * 1024 * 8
)

struct UdpSocket {
mut:
	s      net.UdpConn
	a      net.Addr
	logger shared bstone.Log
}

pub fn create_socket(addr net.Addr, shared logger bstone.Log) ?UdpSocket {
	conn := net.listen_udp(addr.port) or { panic(err) } // binds to local address
	logger.log('UDP Socket listening on $addr', .debug)
	return UdpSocket{conn, addr, logger}
}

fn (s UdpSocket) receive() ?Packet {
	bufsize := vraklib.default_buffer_size
	mut c := s.s // udpconn
	mut buf := []byte{len: bufsize}
	bytes_read, client_addr := c.read(mut buf) or {
		return err

		// return error("could not read") 
	} // addr is from recvfrom, client address
	buf = buf[..bytes_read] // trim buffer
	return Packet{buf, client_addr}
}

fn (s UdpSocket) send(p Packet) ?int {
	// println('Writing to address $p.address: $p.buffer')
	mut sock := s.s
	mut error := sock.write_to(p.address, p.buffer) or { panic(err) } // sends thedata to the client C.sendto, returns int on error, none otherwise
	if error == p.buffer.len {
		println('Success')
		return error
	} else {
		println('Failed')
		return error
	}
}

fn (mut s UdpSocket) close() {
	s.s.close() or { println(err) }
}

fn (s UdpSocket) logger() shared bstone.Log {
	return s.logger
}
