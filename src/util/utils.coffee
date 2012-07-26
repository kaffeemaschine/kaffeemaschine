class @Utils
  # returns whether the 'bit'-th bit is set in n, bit 1 = LSB
  @isBitSet: (n, bit) ->
    if ((n>>>(bit-1)) % 2) is 0
      return false
    else
      return true

  # returns the number n with the 'bit'-th bit set to 1, bit 1 = LSB
  @setBit: (n, bit) ->
    (n | 1<<(bit-1)) >>> 0      

  # return the highest bit set in n in the range from - to, bit 1 = LSB
  @getHighestBitSet: (n, from, to) ->
    for bit in [to..from]
      return bit if @isBitSet(n,bit) is on
    return undefined

  # extract from - to bits from n
  @extractNum: (n, from, to) ->
    num = 0
    for bit in [to..from]
      num = @setBit(num, bit-from+1) if @isBitSet(n,bit) is on
    return num

