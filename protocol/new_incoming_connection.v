module vraklib

import utils

struct NewIncomingConnection {
mut:
    p Packet

    address InternetAddress
    system_addresses []InternetAddress
    ping_time i64
    pong_time i64
}

fn (mut r NewIncomingConnection) decode() {
    
}
