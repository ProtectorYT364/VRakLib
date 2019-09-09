import vraklib

fn test_bytebuffer() {
    buffer := [1024]byte

    mut bytebuffer := vraklib.new_bytebuffer(buffer, u32(1024))
    
    bytebuffer.put_string('abcdefg')
    bytebuffer.put_string('MinecraftPacketStringTestLongTextIsPossible? Space Space ')
    bytebuffer.put_ushort(u16(153))
    bytebuffer.put_short(i16(12345))
    bytebuffer.put_int(123456789)
    bytebuffer.put_long(i64(123456789123456789))
    bytebuffer.put_ulong(u64(12345678912345789123))
    //bytebuffer.put_string('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
    bytebuffer.put_float(f32(3214.1567))
    bytebuffer.put_double(f64(3214567585955.1234))

    //println(bytebuffer.length)
    //println(bytebuffer.position)

    bytebuffer.set_position(u32(0))

    println(bytebuffer.get_string())
    println(bytebuffer.get_string())
    println(bytebuffer.get_ushort())
    println(bytebuffer.get_short())
    println(bytebuffer.get_int())
    println(bytebuffer.get_long())
    println(bytebuffer.get_ulong())
    //println(bytebuffer.get_string())
    println(bytebuffer.get_float())
    println(bytebuffer.get_double())

    //bytebuffer.print()

    n := 1
    println(n & 0xFF)
}