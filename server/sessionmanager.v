module server

import vraklib.protocol
import vraklib.utils

struct SessionManager {
mut:
    server VRakLib

    socket UdpSocket
    sessions map[string]Session
    session_by_address map[string]Session

    shutdown bool

    start_time_ms int

    port_checking bool

    next_session_id int
}

fn (s SessionManager) get_raknet_time_ms() i64 {
    return 0 - s.start_time_ms // TODO
}

pub fn (mut s SessionManager) run() {
    for !s.shutdown {
        s.receive_packet()

        for i, _ in s.sessions {
            s.sessions[i].update()
        }
    }
}

fn (mut s SessionManager) receive_packet() {
    packet := s.socket.receive() or { return }
    if packet.buffer.buffer.len < 1 { return }
    pid := unsafe { packet.buffer.buffer[0] }

    if s.session_exists(packet.address) {
        mut session := s.get_session_by_address(packet.address)

        if (pid & bitflag_valid) != 0 {
            if (pid & bitflag_ack) != 0 {
                // ACK
                println('ack')
            } else if (pid & bitflag_nak) != 0 {
                // NACK
                println('nack')
            } else {
                datagram := protocol.Datagram { p: protocol.new_packet_from_packet(packet) }
                session.handle_packet(datagram)
            }
        }
    } else {
        if pid == id_un_connected_ping {
            mut ping := protocol.UnConnectedPing { p: protocol.new_packet_from_packet(packet) }
            ping.decode()

            title := 'MCPE;Minecraft V Server!;361;1.12.0;0;100;123456789;Test;Survival;'
            len := 35 + title.len
            mut pong := protocol.UnConnectedPong {
                p: protocol.new_packet([byte(0)].repeat(len).data, u32(len))
                server_id: 123456789
                ping_id: ping.ping_id
                str: title
            }
            pong.encode()
            pong.p.address = ping.p.address

            s.socket.send(pong, pong.p)
        } else if pid == id_open_connection_request1 {
            mut request := protocol.OpenConnectionRequest1 { p: protocol.new_packet_from_packet(packet) }
            request.decode()
            
            if request.version != 9 {
                mut incompatible := protocol.IncompatibleProtocolVersion {
                    p: protocol.new_packet([byte(0)].repeat(26).data, u32(26))
                    version: 9
                    server_id: 123456789
                }
                incompatible.encode()
                incompatible.p.address = request.p.address

                s.socket.send(incompatible, incompatible.p)
                return
            }

            mut reply := protocol.OpenConnectionReply1 {
                p: protocol.new_packet([byte(0)].repeat(28).data, u32(28))
                security: false
                server_id: 123456789
                mtu_size: request.mtu_size + u16(28)
            }
            reply.encode()
            reply.p.address = request.p.address

            s.socket.send(reply, reply.p)
        } else if pid == id_open_connection_request2 {
            mut request := protocol.OpenConnectionRequest2 { p: protocol.new_packet_from_packet(packet) }
            request.decode()

            if request.mtu_size < u16(min_mtu_size) {
                println('Not creating session for ${packet.address.ip} due to bad MTU size ${request.mtu_size}')
                return
            }

            mut reply := protocol.OpenConnectionReply2 {
                p: protocol.new_packet([byte(0)].repeat(35).data, u32(35))
                server_id: 123456789
                client_address: request.p.address
                mtu_size: request.mtu_size
                security: false
            }
            reply.encode()
            reply.p.address = request.p.address

            s.socket.send(reply, reply.p)
            s.create_session(request.p.address, request.client_id, request.mtu_size)
        }
    }
}

fn (s SessionManager) get_session_by_address(address utils.InternetAddress) Session {
    return s.session_by_address['$address.ip:${address.port.str()}']
}

fn (s SessionManager) session_exists(address utils.InternetAddress) bool {
    return '$address.ip:${address.port.str()}' in s.session_by_address
}

fn (mut s SessionManager) create_session(address utils.InternetAddress, client_id u64, mtu_size u16) &Session {
    for {
        if s.next_session_id.str() in s.sessions {
            s.next_session_id++
            s.next_session_id &= 0x7fffffff
        } else {
            break
        }
    }

    session := new_session(s, address, client_id, mtu_size, s.next_session_id)
    s.sessions[s.next_session_id.str()] = session
    s.session_by_address['$address.ip:${address.port.str()}'] = session
    return &session
}

fn (s SessionManager) send_packet(packet protocol.DataPacketHandler, p protocol.Packet) {
    s.socket.send(packet, p)
}

fn (mut s SessionManager) open_session(session Session) {
    s.server.open_session(session.internal_id.str(), session.address, session.id)
}

fn (mut s SessionManager) handle_encapsulated(session Session, packet protocol.EncapsulatedPacket) {
    s.server.handle_encapsulated(session.internal_id.str(), packet, priority_normal)
}