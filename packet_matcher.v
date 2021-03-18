module vraklib

fn (mut p Packet) get_packet_from_match(has_session bool) RaklibPacket {
	header := p.buffer[0]
	if has_session {
		if header & 0x40 != 0 {
			mut packet := Ack{}
	packet.decode(mut p)
	return packet
		} else if header & 0x20 != 0 {
			mut packet := Nak{}
	packet.decode(mut p)
	return packet
		} else if header & 0x80 != 0 {
			mut packet := Datagram{}
	packet.decode(mut p)
	return packet
		}
	} else {
		match header {
			id_unconnected_ping {
				mut packet := UnConnectedPing{}
	packet.decode(mut p)
	return packet
			}
			id_open_connection_request1 {
				mut packet := OpenConnectionRequest1{}
				println('PKG MATCHER #2 $packet')
	packet.decode(mut p)
	return packet
			}
			id_open_connection_request2 {
				mut packet := OpenConnectionRequest2{}
	packet.decode(mut p)
	return packet
			}
			else {
				println('PKG MATCHER FAILED')}
		}
	}
	mut packet := RawPacket{}
	packet.decode(mut p)
	return packet//todo return error() instead
}

fn (p RaklibPacket) get_id() int {
	match p {
		Ack { return flag_datagram_ack } // TODO ack vs nak
		//Nak { return flag_datagram_nack } // TODO ack vs nak
		ConnectedPing { return id_connected_ping }
		UnConnectedPing { return id_unconnected_ping }
		//UnConnectedPingOpenConnections { return id_unconnected_ping_open_connections }
		ConnectedPong { return id_connected_pong }
		//DetectLostConnections { return id_detect_lost_connections }
		OpenConnectionRequest1 { return id_open_connection_request1 }
		OpenConnectionReply1 { return id_open_connection_reply1 }
		OpenConnectionRequest2 { return id_open_connection_request2 }
		OpenConnectionReply2 { return id_open_connection_reply2 }
		ConnectionRequest { return id_connection_request }
		ConnectionRequestAccepted { return id_connection_request_accepted }
		NewIncomingConnection { return id_new_incoming_connection }
		//DisconnectNotification { return id_disconnect_notification }
		IncompatibleProtocolVersion { return id_incompatible_protocol_version }
		UnConnectedPong { return id_unconnected_pong }
		else { return -1 }
	}
}
