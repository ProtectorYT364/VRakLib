module server

import net
import vraklib.protocol
import vraklib.utils

const (
    default_buffer_size = 8388608 // 1024 * 1024 * 8
)

struct UdpSocket {
mut:
    s net.Socket
}

pub fn create_socket(ip string, port int) ?UdpSocket {
	s := net.socket_udp() or { panic(err) }
    // level, optname, optvalue
    bufsize := default_buffer_size
    s.setsockopt(C.SOL_SOCKET, C.SO_RCVBUF, &bufsize)
    zero := 0
    s.setsockopt(C.SOL_SOCKET, C.SO_REUSEADDR, &zero)
	s.bind( port ) or { panic(err) }

    return UdpSocket{ s }
}

fn (s UdpSocket) receive() ?protocol.Packet {
    bufsize := default_buffer_size
	bytes := [default_buffer_size]byte{}

	res := s.s.crecv(bytes, bufsize)
    if res == -1 {
        return error('Could not receive the packet.')
    }
	print('Received $res bytes: ' + tos(bytes, res))

    ip := s.s.peer_ip() or { return }
    port := s.s.get_port()
	print('IP is $ip, Port is $port')

    return protocol.Packet {
        buffer: utils.new_bytebuffer(bytes, u32(res))
        address: utils.InternetAddress { ip: ip, port: u16(port), version: byte(4) }
    }
}

fn (s UdpSocket) send(packet protocol.DataPacketHandler, p protocol.Packet) ?int {
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
}

fn (s UdpSocket) close() {
    s.s.close()
}