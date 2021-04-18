module vraklib

import net
import encoding.binary
// endian + put/get methods
import math.bits
// import io//BufferedReader

enum Endianness {
	little
	big
}

struct ByteBuffer {
pub mut:
	endianness Endianness = .big
	buffer     []byte
	//	length     u32//TODO remove
	position u32
}

pub fn new_bytebuffer(buffer []byte) ByteBuffer {
	return ByteBuffer{
		// endianness: Endianness.big // Network order
		buffer: buffer
		// length: u32(buffer.len)
		// position: u32(0)
	}
}

pub fn (b ByteBuffer) len() int {
	return b.buffer.len
}

pub fn (b ByteBuffer) remainder() int {
	return b.len() - int(b.position) - 1
}

pub fn (mut b ByteBuffer) feof() bool {
	return b.remainder() <= 0
}

pub fn (mut b ByteBuffer) reset() {
	b.rewind()

	// b.buffer = []byte{len:default_buffer_size}
	b.buffer = []byte{}

	// b.length = u32(b.buffer.len)
}

pub fn (mut b ByteBuffer) trim() {
	b.buffer = b.buffer[..b.position]

	// b.length = u32(b.buffer.len)
}

pub fn (mut b ByteBuffer) rewind() {
	b.position = 0
}

pub fn (mut b ByteBuffer) put_byte(v byte) {
	//	assert b.position + 1 <= b.len()
	unsafe {
		b.buffer[b.position] = v
	}
	b.position++
}

pub fn (mut b ByteBuffer) put_bytes(bytes []byte) {
	size := bytes.len

	//	assert b.position + u32(size) <= b.len()
	for i in 0 .. size {
		unsafe {
			b.buffer[b.position + u32(i)] = bytes[i]
		}
	}
	b.position += u32(size)
}

pub fn (mut b ByteBuffer) put_char(c i8) {
	//	assert b.position + u32(sizeof(i8)) <= b.len()
	unsafe {
		b.buffer[b.position] = byte(c)
	}
	b.position++
}

pub fn (mut b ByteBuffer) put_bool(v bool) {
	//	assert b.position + u32(1) <= b.len()
	unsafe {
		b.buffer[b.position] = if v { byte(0x01) } else { byte(0x00) }
	}
	b.position++
}

// https://doc.rust-lang.org/std/primitive.i16.html -32768...32767

pub fn (mut b ByteBuffer) put_short(v i16) {
	//     assert b.position + u32(sizeof(i16)) <= b.len()
	mut vv := v
	if b.endianness == Endianness.big {
		vv = i16(swap16(u16(v)))
	}
	unsafe {
		b.buffer[b.position] = byte(vv >> i16(8))
		b.buffer[b.position + u32(1)] = byte(vv)
	}
	b.position += u32(sizeof(i16))
}

// https://doc.rust-lang.org/std/primitive.u16.html 0...65535

pub fn (mut b ByteBuffer) put_ushort(v u16) {
	//     assert b.position + u32(sizeof(u16)) <= b.len()
	mut vv := v
	mut bytes := []byte{len: 2}
	if b.endianness == Endianness.big {
		binary.big_endian_put_u16(mut bytes, vv)
	} else {
		binary.little_endian_put_u16(mut bytes, vv)
	}
	b.put_bytes(bytes)
}

pub fn (mut b ByteBuffer) put_triad(vv U24) {
	//     assert b.position + u32(3) <=b.len()
	mut v := u32(vv)
	unsafe {
		b.buffer[b.position] = byte(v >> 16)
		b.buffer[b.position + u32(1)] = byte(v >> 8)
		b.buffer[b.position + u32(2)] = byte(v)
	}
	b.position += u32(3)
}

pub fn (mut b ByteBuffer) put_ltriad(vv U24) {
	//     assert b.position + u32(3) <= b.len()
	mut v := u32(vv)
	unsafe {
		b.buffer[b.position] = byte(v)
		b.buffer[b.position + u32(1)] = byte(v >> 8)
		b.buffer[b.position + u32(2)] = byte(v >> 16)
	}
	b.position += u32(3)
}

pub fn (mut b ByteBuffer) put_int(v int) {
	//     assert b.position + u32(sizeof(int)) <= b.len()
	mut vv := v
	if b.endianness == Endianness.big {
		vv = int(swap32(u32(v)))
	}
	unsafe {
		b.buffer[b.position] = byte(vv >> int(24))
		b.buffer[b.position + u32(1)] = byte(vv >> int(16))
		b.buffer[b.position + u32(2)] = byte(vv >> int(8))
		b.buffer[b.position + u32(3)] = byte(vv)
	}
	b.position += u32(sizeof(int))
}

pub fn (mut b ByteBuffer) put_uint(v u32) {
	//     assert b.position + u32(sizeof(u32)) <=b.len()
	mut vv := v
	mut bytes := []byte{len: 4}
	if b.endianness == Endianness.big {
		binary.big_endian_put_u32(mut bytes, vv)
	} else {
		binary.little_endian_put_u32(mut bytes, vv)
	}
	b.put_bytes(bytes)
}

pub fn (mut b ByteBuffer) put_long(v i64) {
	//     assert b.position + u32(sizeof(i64)) <= b.len()
	mut vv := v
	if b.endianness == Endianness.big {
		vv = i64(swap64(u64(v)))
	}
	unsafe {
		b.buffer[b.position] = byte(vv >> i64(56))
		b.buffer[b.position + u32(1)] = byte(vv >> i64(48))
		b.buffer[b.position + u32(2)] = byte(vv >> i64(40))
		b.buffer[b.position + u32(3)] = byte(vv >> i64(32))
		b.buffer[b.position + u32(4)] = byte(vv >> i64(24))
		b.buffer[b.position + u32(5)] = byte(vv >> i64(16))
		b.buffer[b.position + u32(6)] = byte(vv >> i64(8))
		b.buffer[b.position + u32(7)] = byte(vv)
	}
	b.position += u32(sizeof(i64))
}

pub fn (mut b ByteBuffer) put_ulong(v u64) {
	//     assert b.position + u32(sizeof(u64)) <= b.len()
	mut vv := v
	mut bytes := []byte{len: 8}
	if b.endianness == Endianness.big {
		binary.big_endian_put_u64(mut bytes, vv)
	} else {
		binary.little_endian_put_u64(mut bytes, vv)
	}
	b.put_bytes(bytes)

	// b.position += 8
}

pub fn (mut b ByteBuffer) put_float(v f32) {
	//     assert b.position + u32(sizeof(f32)) <= b.len()
	mut vv := v
	if b.endianness == Endianness.big {
		vv = swapf(v)
	}
	as_int := unsafe { &u32(&vv) }
	unsafe {
		b.buffer[b.position] = byte(u32(*as_int) >> u32(24))
		b.buffer[b.position + u32(1)] = byte(u32(*as_int) >> u32(16))
		b.buffer[b.position + u32(2)] = byte(u32(*as_int) >> u32(8))
		b.buffer[b.position + u32(3)] = byte(u32(*as_int))
	}
	b.position += u32(sizeof(f32))
}

pub fn (mut b ByteBuffer) put_double(v f64) {
	//     assert b.position + u32(sizeof(f64)) <= b.len()
	mut vv := v
	if b.endianness == Endianness.big {
		vv = swapd(v)
	}
	as_int := unsafe { &u64(&vv) }
	unsafe {
		b.buffer[b.position] = byte(u64(*as_int) >> u64(56))
		b.buffer[b.position + u32(1)] = byte(u64(*as_int) >> u64(48))
		b.buffer[b.position + u32(2)] = byte(u64(*as_int) >> u64(40))
		b.buffer[b.position + u32(3)] = byte(u64(*as_int) >> u64(32))
		b.buffer[b.position + u32(4)] = byte(u64(*as_int) >> u64(24))
		b.buffer[b.position + u32(5)] = byte(u64(*as_int) >> u64(16))
		b.buffer[b.position + u32(6)] = byte(u64(*as_int) >> u64(8))
		b.buffer[b.position + u32(7)] = byte(u64(*as_int))
	}
	b.position += u32(sizeof(f64))
}

pub fn (mut b ByteBuffer) put_string(v string) {
	b.put_short(i16(v.len))
	if v.len != 0 {
		//     assert b.position + u32(v.len) <= b.len()
		for c in v.bytes() {
			unsafe {
				b.buffer[b.position] = c
				b.position++
			}
		}
	}
}

pub fn (mut b ByteBuffer) get_bytes(size int) []byte {
	assert b.position + u32(size) <= b.len()
	if size == 0 {
		// return []byte
	}
	mut v := []byte{}
	mut i := 0
	for i < size {
		unsafe { v << b.buffer[b.position + u32(i)] }
		i++
	}
	b.position += u32(size)

	// return v.data
	return v
}

pub fn (mut b ByteBuffer) get_byte() byte {
	assert b.position + u32(sizeof(byte)) <= b.len()
	v := unsafe { b.buffer[b.position] }
	b.position++
	return v
}

pub fn (mut b ByteBuffer) get_char() i8 {
	assert b.position + u32(sizeof(i8)) <= b.len()
	v := unsafe { i8(b.buffer[b.position]) }
	b.position++
	return v
}

pub fn (mut b ByteBuffer) get_bool() bool {
	assert b.position + u32(1) <= b.len()
	v := if unsafe { b.buffer[b.position] == 0x01 } { true } else { false }
	b.position++
	return v
}

pub fn (mut b ByteBuffer) get_short() i16 {
	assert b.position + u32(sizeof(i16)) <= b.len()

	//	return i16(b[1]) | (i16(b[0])<<i16(8))
	// mut v := unsafe {i16(i16(b.buffer[b.position]) << i16(8)) | i16(b.buffer[b.position + u32(1)])}
	mut v := unsafe { i16(b.buffer[b.position + u32(1)]) | (i16(b.buffer[b.position]) << i16(8)) }
	b.position += u32(sizeof(i16))
	if b.endianness == Endianness.big {
		v = i16(swap16(u16(v)))
	}
	return v
}

pub fn (mut b ByteBuffer) get_ushort() u16 {
	assert b.position + u32(sizeof(u16)) <= b.len()
	if b.endianness == Endianness.big {
		mut v := binary.big_endian_u16(b.buffer[b.position..(b.position + 2)])
		b.position += 2
		return v
	} else {
		mut v := binary.little_endian_u16(b.buffer[b.position..(b.position + 2)])
		b.position += 2
		return v
	}
}

pub fn (mut b ByteBuffer) get_triad() U24 {
	assert b.position + u32(3) <= b.len()
	v := unsafe {
		int(int(b.buffer[b.position]) << int(16)) | int(int(b.buffer[b.position + u32(1)]) << int(8)) | int(b.buffer[
			b.position + u32(2)])
	}
	b.position += u32(3)
	return u24(v)
}

pub fn (mut b ByteBuffer) get_ltriad() U24 {
	assert b.position + u32(3) <= b.len()
	v := unsafe {
		int(b.buffer[b.position]) | int(int(b.buffer[b.position + u32(1)]) << int(8)) | int(int(b.buffer[
			b.position + u32(2)]) << int(16))
	}
	b.position += u32(3)
	return u24(u32(v))
}

pub fn (mut b ByteBuffer) get_int() int {
	assert b.position + u32(sizeof(int)) <= b.len()
	mut v := unsafe {
		int(int(b.buffer[b.position]) << int(24)) | int(int(b.buffer[b.position + u32(1)]) << int(16)) | int(int(b.buffer[
			b.position + u32(2)]) << int(8)) | int(b.buffer[b.position + u32(3)])
	}
	b.position += u32(sizeof(int))
	if b.endianness == Endianness.big {
		v = int(swap32(u32(v)))
	}
	return v
}

pub fn (mut b ByteBuffer) get_uint() u32 {
	assert b.position + u32(sizeof(u32)) <= b.len()
	if b.endianness == Endianness.big {
		mut v := binary.big_endian_u32(b.buffer[b.position..(b.position + 4)])
		b.position += 4
		return v
	} else {
		mut v := binary.little_endian_u32(b.buffer[b.position..(b.position + 4)])
		b.position += 4
		return v
	}
}

pub fn (mut b ByteBuffer) get_long() i64 {
	assert b.position + u32(sizeof(i64)) <= b.len()
	mut v := unsafe {
		i64(i64(b.buffer[b.position]) << i64(56)) | i64(i64(b.buffer[b.position + u32(1)]) << i64(48)) | i64(i64(b.buffer[
			b.position + u32(2)]) << i64(40)) | i64(i64(b.buffer[b.position + u32(3)]) << i64(32)) | i64(i64(b.buffer[
			b.position + u32(4)]) << i64(24)) | i64(i64(b.buffer[b.position + u32(5)]) << i64(16)) | i64(i64(b.buffer[
			b.position + u32(6)]) << i64(8)) | i64(b.buffer[b.position + u32(7)])
	}
	b.position += u32(sizeof(i64))
	if b.endianness == Endianness.big {
		v = i64(swap64(u64(v)))
	}
	return v
}

pub fn (mut b ByteBuffer) get_ulong() u64 {
	assert b.position + u32(sizeof(u64)) <= b.len()
	if b.endianness == Endianness.big {
		mut v := binary.big_endian_u64(b.buffer[b.position..(b.position + 8)])
		b.position += 8
		return v
	} else {
		mut v := binary.little_endian_u64(b.buffer[b.position..(b.position + 8)])
		b.position += 8
		return v
	}
}

pub fn (mut b ByteBuffer) get_float() f32 {
	assert b.position + u32(sizeof(f32)) <= b.len()
	mut v := unsafe {
		u32(u32(b.buffer[b.position]) << u32(24)) | u32(u32(b.buffer[b.position + u32(1)]) << u32(16)) | u32(u32(b.buffer[
			b.position + u32(2)]) << u32(8)) | u32(b.buffer[b.position + u32(3)])
	}
	ptr := unsafe { &f32(&v) }
	b.position += u32(sizeof(f32))
	mut vv := *ptr
	if b.endianness == Endianness.big {
		vv = swapf(vv)
	}
	return vv
}

pub fn (mut b ByteBuffer) get_double() f64 {
	assert b.position + u32(sizeof(f64)) <= b.len()
	mut v := unsafe {
		u64(u64(b.buffer[b.position]) << u64(56)) | u64(u64(b.buffer[b.position + u32(1)]) << u64(48)) | u64(u64(b.buffer[
			b.position + u32(2)]) << u64(40)) | u64(u64(b.buffer[b.position + u32(3)]) << u64(32)) | u64(u64(b.buffer[
			b.position + u32(4)]) << u64(24)) | u64(u64(b.buffer[b.position + u32(5)]) << u64(16)) | u64(u64(b.buffer[
			b.position + u32(6)]) << u64(8)) | u64(b.buffer[b.position + u32(7)])
	}
	ptr := unsafe { &f64(&v) }
	b.position += u32(sizeof(f64))
	mut vv := *ptr
	if b.endianness == Endianness.big {
		vv = swapd(vv)
	}
	return vv
}

pub fn (mut b ByteBuffer) get_string() string {
	size := int(b.get_short())
	mut v := []byte{}
	if size > 0 {
		assert b.position + u32(sizeof(string)) <= b.len()
		mut i := 0
		for i < size {
			unsafe { v << b.buffer[b.position] & 0xFF }
			b.position++
			i++
		}
	}
	return unsafe { tos(v.data, size) } // TODO can maybe remove this
}

pub fn (mut b ByteBuffer) put_address(address net.Addr) {
	b.put_byte(4)

	// if address.version == 4 {
	numbers := address.saddr.split('.')
	for num in numbers {
		b.put_byte(byte(~num.int() & 0xFF))
	}
	b.put_ushort(u16(address.port))

	// }
	// TODO IPv6
}

pub fn (mut b ByteBuffer) get_address() net.Addr {
	ver := b.get_byte()
	if ver == 4 {
		ip_bytes := b.get_bytes(4)
		port := b.get_ushort() // u16(address.port)
		// HACK
		address := net.Addr{
			saddr: ((-ip_bytes[0] - 1) & 0xff).str() + '.' + ((-ip_bytes[1] - 1) & 0xff).str() +
				'.' + ((-ip_bytes[2] - 1) & 0xff).str() + '.' + ((-ip_bytes[3] - 1) & 0xff).str()
			port: port
		}
		return address
	} else {
		panic('Only IPv4 is supported for now')
	}

	// TODO IPv6
}

pub fn (b ByteBuffer) get_system_endianness() Endianness {
	$if little_endian {
		return Endianness.little
	}
	return Endianness.big
}

pub fn (b ByteBuffer) print() {
	mut i := 0
	mut str := ''
	for i < b.len() {
		str += unsafe { b.buffer[i].hex() + ' ' }
		if (i + 1) % 8 == 0 || i == int(b.len()) - 1 {
			str += '\n'
		}
		i++
	}
	println(str)
}

pub fn swap16(v u16) u16 {
	return bits.reverse_bytes_16(v)
}

pub fn swap32(v u32) u32 {
	return bits.reverse_bytes_32(v)
}

pub fn swap64(v u64) u64 {
	return bits.reverse_bytes_64(v)
}

pub fn swapf(f f32) f32 {
	assert sizeof(u32) == sizeof(f32)
	as_int := unsafe { &u32(&f) }
	v := swap32(u32(*as_int))
	as_float := unsafe { &f32(&v) }
	return *as_float
}

pub fn swapd(d f64) f64 {
	assert sizeof(u64) == sizeof(f64)
	as_int := unsafe { &u64(&d) }
	v := swap64(u64(*as_int))
	as_double := unsafe { &f64(&v) }
	return *as_double
}
