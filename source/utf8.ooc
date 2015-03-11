import structs/ArrayList

UTF8: class{
    ACCEPT := static const 0
    DECLINE := static const 1
    utf8d := const static [
      0 as UInt8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 00..1f
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 20..3f
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 40..5f
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 60..7f
      1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9, // 80..9f
      7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7, // a0..bf
      8,8,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2, // c0..df
      0xa,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x4,0x3,0x3, // e0..ef
      0xb,0x6,0x6,0x6,0x5,0x8,0x8,0x8,0x8,0x8,0x8,0x8,0x8,0x8,0x8,0x8, // f0..ff
      0x0,0x1,0x2,0x3,0x5,0x8,0x7,0x1,0x1,0x1,0x4,0x6,0x1,0x1,0x1,0x1, // s0..s0
      1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,0,1,0,1,1,1,1,1,1, // s1..s2
      1,2,1,1,1,1,1,2,1,2,1,1,1,1,1,1,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,1, // s3..s4
      1,2,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,1,1,1,1,1,1,3,1,3,1,1,1,1,1,1, // s5..s6
      1,3,1,1,1,1,1,3,1,3,1,1,1,1,1,1,1,3,1,1,1,1,1,1,1,1,1,1,1,1,1,1, // s7..s8
  ]

  _state: Int32 = ACCEPT
  _codep: Int32 = 0

  init: func

  reset: func{
      _state = ACCEPT
      _codep = 0
  }

  decode: inline func(byte: UInt32) -> Bool{
      type := utf8d[byte]

      _codep = (_state != ACCEPT) ? \
          (byte & 0x0000003fu) | (_codep << 6) : (0x000000ff >> type) & (byte)

      (_state = utf8d[256+_state*16+type]) == 0
  }

  decode: inline func ~char (byte: Char) -> Bool{ decode(byte as UChar as UInt32) }

  decode: inline func ~int (byte: Int) -> Bool{ decode(byte as UInt32) }

  toUTF: inline func ~arraylist (byte: ArrayList<Char>) -> ArrayList<UInt32>{
      reset()
      result := ArrayList<UInt32> new(byte size)
      for(i in 0..byte size){
          if(decode(byte[i])){
              result add(_codep)
          }
      }
      result
  }

  toUTF: inline func ~char (byte: Char[]) -> UInt32[]{
      result := toUTF(byte as ArrayList<Char>)
      r: UInt32[]
      r data = result toArray() 
      r length = result size
      r
  }

  toUTF: inline func ~string(byte: String) -> UInt32[]{
      arr : Char[]
      arr data = byte toCString()
      arr length = byte size
      toUTF(arr)
  }

  count: inline func ~string (s: String) -> UInt32{
    reset()
    count := 0
    for(i in 0..s size){
        if(decode(s[i])) count += 1
    }
    count
  }
}
