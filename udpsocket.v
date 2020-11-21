module vraklib

import net

const (
    default_buffer_size = 8388608 // 1024 * 1024 * 8
)

struct UdpSocket {
mut:
    s net.UdpConn
}

pub fn create_socket(ip string, port int) ?UdpSocket {
//	s := net.socket_udp() or { panic(err) }
//    // level, optname, optvalue
//    bufsize := default_buffer_size
//    s.setsockopt(C.SOL_SOCKET, C.SO_RCVBUF, &bufsize)
//    zero := 0
//    s.setsockopt(C.SOL_SOCKET, C.SO_REUSEADDR, &zero)
//	s.bind( port ) or { panic(err) }
//
//    return UdpSocket{ s }
    mut conn := net.listen_udp(port) or {
        panic(err)
    }
    println(conn.str())
    return UdpSocket{ conn }
}

fn (s UdpSocket) receive() ?Packet {
    bufsize := default_buffer_size
	//bytes := [default_buffer_size]byte{}

	//res := s.s.crecv(bytes, bufsize)
    //if res == -1 {
    //    return error('Could not receive the packet.')
    //}
	//print('Received $res bytes: ' + tos(bytes, res))

    //ip := s.s.peer_ip() or { return error('ip cant be get') }
    //port := s.s.get_port()
	//print('IP is $ip, Port is $port')

    //return Packet {
    //    buffer: new_bytebuffer(bytes, u32(res))
    //    address: InternetAddress { ip: ip, port: u16(port), version: byte(4) }
    //}

    mut c := s.s
	mut buf := []byte{ len: bufsize, init: 0 }
	read, addr := c.read(mut buf) or {
		return none
	}
	println('Got address $addr')
	println('Got $read bytes')
	println('Got "${buf.bytestr()}"')
	println('Got "$buf"')

    return none

    //return Packet {
    //    buffer: new_bytebuffer(buf, u32(read))
    //    address: InternetAddress { ip: ip, port: u16(port), version: byte(4) }
    //}
}

fn (s UdpSocket) send(/*r RaklibPacket,*/ p Packet) ?int {
    //TODO - seems to be incomplete in vlang
    //mut addr := C.sockaddr_in{}
    //addr.sin_port = int(p.address.port)
    //C.inet_pton(C.AF_INET, p.address.ip.str, &addr.sin_addr)//TODO look up what this is

    //buffer := p.buffer.buffer
    //length := p.buffer.length

    //size := 16
    //res := int(C.sendto(s.s.sockfd, buffer, length, 0, &addr, size))//TODO find vlang method
    //if res == -1 {
    //    return error('Could not send the packet')
    //}
    //return res

    println(p.address)
    p.buffer.print()
}

fn (s UdpSocket) close() {
    s.s.close()
}