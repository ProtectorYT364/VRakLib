module vraklib

struct IncompatibleProtocolVersion {
mut:
    p Packet

    version byte
    server_id i64
}

fn (mut r IncompatibleProtocolVersion) encode() {
    r.p.buffer.put_byte(id_incompatible_protocol_version)
    r.p.buffer.put_byte(r.version)
    r.p.buffer.put_bytes(get_packet_magic().data, raknet_magic_length)
    r.p.buffer.put_long(r.server_id)
}

fn (r IncompatibleProtocolVersion) decode() {}
