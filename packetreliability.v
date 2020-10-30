module vraklib

const (
    unreliable = 0x00
    unreliable_sequenced = 0x01
    reliable = 0x02
    reliable_ordered = 0x03
    reliable_sequenced = 0x04
    unreliable_with_ack_receipt = 0x05
    reliable_with_ack_receipt = 0x06
    reliable_ordered_with_ack_receipt = 0x07
)

const (
    priority_normal = 0
    priority_immediate = 1
)

fn reliability_is_reliable(reliability byte) bool {
    return reliability == reliable ||
        reliability == reliable_ordered_with_ack_receipt ||
        reliability == reliable_sequenced ||
        reliability == reliable_with_ack_receipt ||
        reliability == reliable_ordered_with_ack_receipt
}

fn reliability_is_sequenced(reliability byte) bool {
    return reliability == unreliable_sequenced ||
        reliability == reliable_sequenced
}

fn reliability_is_ordered(reliability byte) bool {
    return reliability == reliable_ordered ||
        reliability == reliable_ordered_with_ack_receipt
}

fn reliability_is_sequenced_or_ordered(reliability byte) bool {
    return reliability == unreliable_sequenced ||
        reliability == reliable_ordered ||
        reliability == reliable_sequenced ||
        reliability == reliable_ordered_with_ack_receipt
}