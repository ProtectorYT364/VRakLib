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
	conn := net.listen_udp(addr.port) or { panic(err) }//binds to local address
	println('UDP Socket listening on $addr')
	return UdpSocket{conn,addr}
}

fn (s UdpSocket) receive() ?Packet {
	bufsize := default_buffer_size
	mut c := s.s//udpconn
	mut buf := []byte{len: bufsize}
	bytes_read, client_addr := c.read(mut buf) or { return none }//addr is from recvfrom, client address
	//trim buffer
	buf = buf[..bytes_read]
	 //println('Got address $client_addr')
		//println('Got $bytes_read vs $buf.len bytes: "$buf.bytestr()"')
	return Packet{
		buffer: new_bytebuffer(buf)
		address: client_addr
	}
}

fn (s UdpSocket) send(p Packet) ?int {
		//println('Writing to address $p.address: $p.buffer.buffer')
		mut sock := s.s
		mut error := sock.write_to(p.address, p.buffer.buffer) or { panic(err) }//sends thedata to the client C.sendto, returns int on error, none otherwise
		if error == p.buffer.length{
		//println('Success')
		return error
		}else{
		println('Failed')
		return error}
}

fn (mut s UdpSocket) close() {
	s.s.close() or { panic(err) }
}
