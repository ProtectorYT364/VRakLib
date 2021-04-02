module vraklib

const (
	reliability_unreliable                        = 0x00
	reliability_unreliable_sequenced              = 0x01
	reliability_reliable                          = 0x02
	reliability_reliable_ordered                  = 0x03
	reliability_reliable_sequenced                = 0x04
	reliability_unreliable_with_ack_receipt       = 0x05
	reliability_reliable_with_ack_receipt         = 0x06
	reliability_reliable_ordered_with_ack_receipt = 0x07

	splitflag                                     = 0x10
)

const (
	priority_normal    = 0
	priority_immediate = 1
)

fn reliability_is_reliable(reliability byte) bool {
	return reliability == vraklib.reliability_reliable
		|| reliability == vraklib.reliability_reliable_ordered_with_ack_receipt
		|| reliability == vraklib.reliability_reliable_sequenced
		|| reliability == vraklib.reliability_reliable_with_ack_receipt
		|| reliability == vraklib.reliability_reliable_ordered_with_ack_receipt
}

fn reliability_is_sequenced(reliability byte) bool {
	return reliability == vraklib.reliability_unreliable_sequenced
		|| reliability == vraklib.reliability_reliable_sequenced
}

fn reliability_is_ordered(reliability byte) bool {
	return reliability == vraklib.reliability_reliable_ordered
		|| reliability == vraklib.reliability_reliable_ordered_with_ack_receipt
}

fn reliability_is_sequenced_or_ordered(reliability byte) bool {
	return reliability == vraklib.reliability_unreliable_sequenced
		|| reliability == vraklib.reliability_reliable_ordered
		|| reliability == vraklib.reliability_reliable_sequenced
		|| reliability == vraklib.reliability_reliable_ordered_with_ack_receipt
}
