module vraklib

const (
	id_connected_ping                    = 0x00
	id_unconnected_ping                  = 0x01
	id_unconnected_ping_open_connections = 0x02
	id_connected_pong                    = 0x03
	id_detect_lost_connections           = 0x04
	id_open_connection_request1          = 0x05
	id_open_connection_reply1            = 0x06
	id_open_connection_request2          = 0x07
	id_open_connection_reply2            = 0x08
	id_connection_request                = 0x09
	id_connection_request_accepted       = 0x10
	id_new_incoming_connection           = 0x13
	id_disconnect_notification           = 0x15
	id_incompatible_protocol_version     = 0x19
	id_unconnected_pong                  = 0x1c
	id_user_packet_enum                  = 0x86
)

type RaklibPacketType =  RawPacket | ConnectedPing | ConnectedPong | ConnectionRequest | ConnectionRequestAccepted | IncompatibleProtocolVersion | NewIncomingConnection | OpenConnectionReply1 | OpenConnectionReply2 | OpenConnectionRequest1 | OpenConnectionRequest2 | UnConnectedPing | UnConnectedPong | /* Acknowledgement | */ Ack | Nak

interface RaklibPacket {
    encode() ByteBuffer
    decode(mut p Packet)
}