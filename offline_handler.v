module vraklib

import time

// HandleUnconnectedMessage handles an incoming unconnected message from a UDPAddr.
// A response will be made for every packet, which gets sent back to the sender.
// A session gets created for the sender once the OpenConnectionRequest2 gets sent.
// fn (mut s SessionManager) handle_unconnected_message(packet_interface RaklibPacket, packet Packet) {
// 	if packet_interface is UnConnectedPing {
// 		mut p := packet_interface
// 		//println(p)
// 		s.handle_unconnected_ping(p, packet)
// 	}
// 	else if packet_interface is OpenConnectionRequest1 {
// 		mut p := packet_interface
// 		println(p)
// 		s.handle_open_connection_request1(p, packet)
// 	}
// 	else if packet_interface is OpenConnectionRequest2 {
// 		mut p := packet_interface
// 		println(p)
// 		s.handle_open_connection_request2(p, packet)
// 	}
// }

// handleUnconnectedPing handles an unconnected ping.
// An unconnected pong is sent back with the server's pong data.
fn (mut s SessionManager) handle_unconnected_ping(mut p Packet) {
	mut ping := UnConnectedPing{}
	ping.decode(mut p)
	println('handle_unconnected_ping $ping')

	//println(request)
	mut pong := UnConnectedPong{}
	pong.send_timestamp = timestamp()
	pong.server_guid = server_guid // TODO from s.
	pong.data = s.server.pong_data.update_pong_data().bytes()
	mut b := pong.encode()
	b.trim()
	s.send_packet(new_packet_from_bytebuffer(b, p.address))
	//DEBUG
	/* mut pongd := UnConnectedPong{}
	pongd.decode(mut new_packet_from_bytebuffer(b,p.address))
	println(pong)
	println(pongd) */
	//assert pong == pongd
}

// handleOpenConnectionRequest1 handles an open connection request 1.
// An open connection response 1 is sent back with the MTU size and security.
fn (s SessionManager) handle_open_connection_request1(mut p Packet) {
	mut request := OpenConnectionRequest1{}
	request.decode(mut p)
	println('handle_open_connection_request1 $request')
	
	mut reply := OpenConnectionReply1{}
	reply.server_guid = server_guid // TODO from s.
	println(reply.server_guid)
	reply.mtu_size = request.mtu_size
	println(reply.mtu_size)
	reply.secure = false // TODO from s.
	println(reply.secure)
	mut b := reply.encode()
	b.trim()
	s.send_packet(new_packet_from_bytebuffer(b, p.address))
	//DEBUG
	/* mut pongd := OpenConnectionReply1{}
	pongd.decode(mut new_packet_from_bytebuffer(b,p.address))
	println(reply)
	println(pongd) */
	//assert reply == pongd
}

// handleOpenConnectionRequest2 handles an open connection request 2.
// An open connection response 2 is sent back, with the definite MTU size and encryption.
fn (mut s SessionManager) handle_open_connection_request2(mut p Packet) {
	mut request := OpenConnectionRequest2{}
	request.decode(mut p)
	println('handle_open_connection_request2 $request')

	mut reply := OpenConnectionReply2{}
	reply.server_guid = server_guid
	println(reply.server_guid)
	if request.mtu_size < min_mtu_size {
		reply.mtu_size = min_mtu_size
	} else if request.mtu_size > max_mtu_size {
		reply.mtu_size = max_mtu_size
	} else{
		reply.mtu_size = request.mtu_size
	}
	println(reply.mtu_size)
	reply.secure = false
	reply.client_address = p.address

	mut b := reply.encode()
	b.trim()
	println(reply)

	// s.Sessions[fmt.Sprint(addr)] = NewSession(addr, request.MtuSize, manager)
	println('s.create_session $request.client_guid')
	s.create_session(p.address, request.client_guid, u16(request.mtu_size))
	s.send_packet(new_packet_from_bytebuffer(b, p.address))

	//DEBUG
	/* mut pongd := OpenConnectionReply2{}
	pongd.decode(mut new_packet_from_bytebuffer(b,p.address))
	println(reply)
	println(pongd) */
	//assert reply == pongd
}
