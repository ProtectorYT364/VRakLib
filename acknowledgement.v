module vraklib

struct Ack {
mut:
	p                Packet
	packets []u32
}

pub fn (mut r Ack) encode(mut b ByteBuffer) {
	b.put_byte(flag_datagram_ack)

	r.packets.sort(a < b)

	mut packet_count := r.packets.len

	if packet_count == 0 {
		b.put_short(0)
		return
	}

	mut stream := new_bytebuffer([]byte{len:default_buffer_size})//TODO without len

	mut pointer := 1
	mut first_packet := r.packets[0]
	mut last_packet := r.packets[0]

	mut interval_count := 1

	for pointer < packet_count {
		mut current_packet := r.packets[pointer]
		mut difference := current_packet - last_packet

		if difference == 1 {
			last_packet = current_packet
		} else {
			if first_packet == last_packet {
				stream.put_byte(1)
				stream.put_ltriad(last_packet)
				current_packet = last_packet
			} else {
			stream.put_byte(0)
				stream.put_ltriad(first_packet)
				stream.put_ltriad(last_packet)

				last_packet = current_packet
				first_packet = last_packet
			}
			interval_count++
		}

		pointer++
	}

	if first_packet == last_packet {
				stream.put_byte(1)
				stream.put_ltriad(first_packet)
	} else {
				stream.put_byte(0)
				stream.put_ltriad(first_packet)
				stream.put_ltriad(last_packet)
	}

	b.put_short(i16(interval_count))
	//b.put_bytes(stream.buffer)
	stream.trim()
	b.put_bytes(stream.buffer)
	b.trim()
}

pub fn (mut r Ack) decode(mut b ByteBuffer) {
	packet_count := b.get_short()//ushort?
	mut count := 0
	for i := 0; i < packet_count && !r.p.buffer.feof() && count < 4096; i++ {
		if b.get_byte() == 0 {
			start := b.get_ltriad()
			mut end := b.get_ltriad()

			if (end - start) > 512 {
				end = start + 512
			}

			for pack := start; pack < end; pack++ {
				r.packets << pack
				count++
			}

		} else {
			r.packets << b.get_ltriad()
			count++
		}
	}
}