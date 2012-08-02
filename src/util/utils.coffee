class @Utils
  # returns whether the 'bit'-th bit is set in n, bit 1 = LSB
  @isBitSet: (n, bit) ->
    if (((n>>>(bit-1))>>>0) % 2) is 0
      return false
    else
      return true

  # returns the number n with the 'bit'-th bit set to 1, bit 1 = LSB
  @setBit: (n, bit) ->
    (n | 1<<(bit-1)) >>> 0      

  # returns the number n with the 'bit'-th bit set to 0, bit 1 = LSB
  @unsetBit: (n, bit) ->
    (n ^ 1<<(bit-1)) >>> 0  

  # returns number n with 'bit'-th bit flipped, bit 1 = LSB
  @toggleBit: (n, bit) ->
    if @isBitSet(n, bit)
      return @unsetBit(n,bit)
    else
      return @setBit(n,bit)

  # return the highest bit set in n in the range from - to, bit 1 = LSB
  @getHighestBitSet: (n, from, to) ->
    for bit in [to..from]
      return bit if @isBitSet(n,bit) is on
    return undefined

  # return the lowest bit set in n in the range from - to, bit 1 = LSB
  @getLowestBitSet: (n, from, to) ->
    for bit in [from..to]
      return bit if @isBitSet(n,bit) is on
    return undefined
  

  # extract from - to bits from n
  @extractNum: (n, from, to) ->
    num = 0
    for bit in [to..from]
      num = @setBit(num, bit-from+1) if @isBitSet(n,bit) is on
    return num

  # returns true when unsigned 32 bit value n would be negative in twos complement
  @isNegative: (n) ->
    @isBitSet(n, 32)

  # returns random number of bit length less or equal to n
  @randomBitSequence: (n) ->
    Math.floor(Math.random() * Math.pow(2,n))
