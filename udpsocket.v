module vraklib

import net
//import os

const (
    default_buffer_size = 8388608 // 1024 * 1024 * 8
)

pub fn create_socket(ip string, port int) ?Socket {
	s := net.socket_udp() or { panic(err) }
    // level, optname, optvalue
    bufsize := default_buffer_size
    s.setsockopt(C.SOL_SOCKET, C.SO_RCVBUF, &bufsize)
    zero := 0
    s.setsockopt(C.SOL_SOCKET, C.SO_REUSEADDR, &zero)
	s.bind( 19132 ) or { panic(err) }

    return s
}

fn (s Socket) receive() ?Packet {
    bufsize := default_buffer_size
	bytes := [default_buffer_size]byte{}

    size := 16

	res := s.crecv(bytes, bufsize)
    if res == -1 {
        return error('Could not receive the packet.')
    }
	print('Received $res bytes: ' + tos(bytes, res))

    ip := s.peer_ip()
    port := s.get_port()
	print('IP is $ip, Port is $port')

    return Packet {
        buffer: new_bytebuffer(bytes, u32(res))
        ip: ip
        port: port
    }
}

fn (s Socket) send(packet DataPacketHandler, p Packet) ?int {
    mut addr := C.sockaddr_in{}
    addr.sin_family = s.family
    addr.sin_port = p.port
    C.inet_pton(C.AF_INET, p.ip.str, &addr.sin_addr)//TODO look up what this is

    buffer := p.buffer.buffer
    length := p.buffer.length

    size := 16
    res := int(C.sendto(s.sock, buffer, length, 0, &addr, size))//TODO find vlang method
    if res == -1 {
        return error('Could not send the packet')
    }
    return res
}

fn (s Socket) close() {
    s.close()
}