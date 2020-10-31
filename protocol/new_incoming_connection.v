module protocol

import vraklib.utils

struct NewIncomingConnection {
mut:
    p Packet

    address utils.InternetAddress
    system_addresses []utils.InternetAddress
    ping_time i64
    pong_time i64
}

fn (mut r NewIncomingConnection) decode() {
    
}
