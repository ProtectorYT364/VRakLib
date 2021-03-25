module vraklib

interface Queue{
	mut lowest u32
	mut highest u32
	mut queue//todo type
}

struct PacketQueue{
mut:
	lowest u32
	highest u32
	queue map[u32]byte[]
}