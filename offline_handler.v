module vraklib

import time

// HandleUnconnectedMessage handles an incoming unconnected message from a UDPAddr.
// A response will be made for every packet, which gets sent back to the sender.
// A session gets created for the sender once the OpenConnectionRequest2 gets sent.
fn(mut s SessionManager) handle_unconnected_message(packet_interface RaklibPacket, packet Packet) {
	if packet_interface is UnConnectedPing{
			s.handle_unconnected_ping(packet_interface,packet)
		}
		 if packet_interface is OpenConnectionRequest1{
			s.handle_open_connection_request1(packet_interface,packet)
		}
		 if packet_interface is OpenConnectionRequest2{
			s.handle_open_connection_request2(packet_interface,packet)
		}
}

// handleUnconnectedPing handles an unconnected ping.
// An unconnected pong is sent back with the server's pong data.
fn(mut s SessionManager) handle_unconnected_ping(request UnConnectedPing, packet Packet) {
	mut pong := UnConnectedPong{}
	pong.send_timestamp = u64(time.now().unix_time_milli())
	pong.server_guid = server_guid//TODO from s.
	pong.data = s.server.pong_data.update_pong_data().bytes()
	mut b := pong.encode()
	b.trim()
	println('encoded $b $pong')
	s.send_packet(new_packet_from_bytebuffer(b,packet.address))
}

// handleOpenConnectionRequest1 handles an open connection request 1.
// An open connection response 1 is sent back with the MTU size and security.
fn(s SessionManager) handle_open_connection_request1(request OpenConnectionRequest1, packet Packet) {
	mut reply := OpenConnectionReply1{}
	reply.server_guid = server_guid//TODO from s.
	reply.mtu_size = request.mtu_size
	reply.secure = false//TODO from s.
	mut b := reply.encode()
	b.trim()
	s.send_packet(new_packet_from_bytebuffer(b,packet.address))
}

// handleOpenConnectionRequest2 handles an open connection request 2.
// An open connection response 2 is sent back, with the definite MTU size and encryption.
fn(mut s SessionManager) handle_open_connection_request2(_request OpenConnectionRequest2, packet Packet) {
	mut request := _request
	mut reply := OpenConnectionReply2{}
	reply.server_guid = server_guid
	if request.mtu_size < min_mtu_size {
		request.mtu_size = min_mtu_size
	} else if request.mtu_size > max_mtu_size {
		request.mtu_size = max_mtu_size
	}
	reply.mtu_size = request.mtu_size
	reply.secure = false
	reply.client_address = packet.address

	mut b := reply.encode()
	b.trim()

	//s.Sessions[fmt.Sprint(addr)] = NewSession(addr, request.MtuSize, manager)
	s.create_session(packet.address, request.client_guid, request.mtu_size)
	s.send_packet(new_packet_from_bytebuffer(b,packet.address))
}