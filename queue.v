module vraklib

import time

/*
interface Queue {
}*/

struct PacketQueue {
mut:
 	lowest  U24
 	highest U24
 	//queue   map[U24][]byte//TODO not yet supported by v
 	queue   map[u32][]byte
 }

// put puts a value at the index passed. If the index was already occupied once, false is returned.
fn (mut queue PacketQueue) put(index U24, packet []byte) bool {
	if index < queue.lowest {
		return false
	}
	if index in queue.queue {
		return false
	}
	if index >= queue.highest {
		queue.highest = index + 1
	}
	queue.queue[index] = packet
	return true
}

// fetch attempts to take out as many values from the ordered queue as possible. Upon encountering an index
// that has no value yet, the function returns all values that it did find and takes them out.
fn (mut queue PacketQueue) fetch() ([][]byte) {
	mut packets := [][]byte{}
	for index in queue.lowest..queue.highest {
		if !(u32(index) in queue.queue) {
			break
		}
		packet := queue.queue[u32(index)]
		queue.queue.delete(index.str())
		packets << packet
		queue.lowest = index
	}
	return packets
}

// WindowSize returns the size of the window held by the packet queue.
fn (queue PacketQueue) window_size() U24 {
	return queue.highest - queue.lowest
}

struct DatagramQueue {
mut:
	lowest  u32
	highest u32
	queue   []u32
	// todo Packet or sth here
}

// put puts an index in the queue. If the index was already occupied once, false is returned.
fn (mut queue DatagramQueue) put(index u32) bool {
	if index < queue.lowest {
		return false
	}
	if index in queue.queue {
		return false
	}
	if index >= queue.highest {
		queue.highest = index + 1
	}
	queue.queue << index
	return true
}

// clear attempts to clear as many indices from the queue as possible, increasing the lowest index if and when
// possible.
fn (mut queue DatagramQueue) clear() {
	mut i := queue.lowest
	for index in queue.lowest .. queue.highest {
		if !(u32(index) in queue.queue) {
			break
		}
		queue.queue.delete(index)
		i = u32(index)
	}
	queue.lowest = i
}

// missing returns a slice of all indices in the datagram queue that weren't set using put while within the
// window of lowest and highest index. The queue is cleared after this call.
fn (mut queue DatagramQueue) missing() []u32 {
	mut indices := []u32{}
	for index in queue.lowest .. queue.highest {
		if u32(index) in queue.queue {
			indices << u32(index)
			queue.queue << u32(index)
		}
	}
	queue.clear()
	return indices
}

// WindowSize returns the size of the window held by the datagram queue.
fn (mut queue DatagramQueue) window_size() u32 {
	return queue.highest - queue.lowest
}

struct RecoveryQueue {
mut:
	queue      map[u32]RaklibPacketType
	timestamps map[u32]time.Time

	ptr    int
	delays []time.Duration
}

const (
	delay_record_count = 40
)

// put puts a value at the index passed.
fn (mut queue RecoveryQueue) put(index u32, value RaklibPacketType) {
	queue.queue[index] = value
	queue.timestamps[index] = time.now()
}

// take fetches a value from the index passed and removes the value from the queue. If the value was found, ok
// is true.
fn (mut queue RecoveryQueue) take(index u32) (RaklibPacketType, bool) {
	ok := index in queue.queue
	val := queue.queue[index]
	if ok {
		queue.queue.delete(index.str())
		queue.delays[queue.ptr] = time.now() - queue.timestamps[index]
		queue.ptr++
		if queue.ptr == vraklib.delay_record_count {
			queue.ptr = 0
		}
		queue.timestamps.delete(index.str())
	}
	return val, ok
}

// takeWithoutDelayAdd has the same functionality as take, but does not update the time it took for the
// datagram to arrive.
fn (mut queue RecoveryQueue) take_without_delay_add(index u32) (RaklibPacketType, bool) {
	val := queue.queue[index]
	if index in queue.queue {
		queue.queue.delete(index.str())
		queue.timestamps.delete(index.str())
	} else {
		return val, false
	}
	return val, true
}

// Timestamp returns the a timestamp of the time that a packet with the sequence number passed arrived at in
// the recovery queue. It panics if the sequence number doesn't exist.
fn (mut queue RecoveryQueue) timestamp(sequenceNumber u32) time.Time {
	return queue.timestamps[sequenceNumber]
}

// AvgDelay returns the average delay between the putting of the value into the recovery queue and the taking
// out of it again. It is measured over the last delay_record_count values put in.
fn (mut queue RecoveryQueue) avg_delay() time.Duration {
	mut average := i64(0)
	mut records := 0
	for _, delay in queue.delays {
		if delay == 0 {
			break
		}
		average += delay.milliseconds()
		records++
	}
	if records == 0 {
		// No records yet, generally should not happen. Just return a reasonable amount of time.
		return time.millisecond * 50
	}
	return average / records
}
