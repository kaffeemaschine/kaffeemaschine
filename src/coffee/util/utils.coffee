log = log4javascript.getLogger()

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

  # returns true when unsigned 32 bit value n would be negative
  # in twos complement
  @isNegative: (n) ->
    @isBitSet(n, 32)

  # returns random number of bit length less or equal to n
  @randomBitSequence: (n) ->
    Math.floor(Math.random() * Math.pow(2,n))

  @getLogger: (prefix) ->
    # Prefixes each logging statement with the given prefix.
    # Accepts 2 or 3 arguments:
    #   prefixLogging(logfun, callback)
    #   prefixLogging(logfun, invoker, callback)
    prefixLogging:(logfun, invoker, callback) ->
      if callback?
        msg = callback.call(invoker)
      else
        callback = invoker
        msg = callback()
      logfun.call(log, '[' + prefix + '] ' + msg)
    trace: (invoker, callback) ->
      @prefixLogging(log.trace, invoker, callback) if log.isTraceEnabled()
    debug: (invoker, callback) ->
      @prefixLogging(log.debug, invoker, callback) if log.isDebugEnabled()
    info: (invoker, callback) ->
      @prefixLogging(log.info, invoker, callback) if log.isInfoEnabled()
    warn: (invoker, callback) ->
      @prefixLogging(log.warn, invoker, callback) if log.isWarnEnabled()
    error: (invoker, callback) ->
      @prefixLogging(log.error, invoker, callback) if log.isErrorEnabled()
    fatal: (invoker, callback) ->
      @prefixLogging(log.fatal, invoker, callback) if log.isFatalEnabled()

  @decToHex: (decimal, chars) ->
    (decimal + Math.pow(16, chars)).toString(16).slice(-chars).toUpperCase()
  @decToBin: (decimal, chars) ->
    (decimal + Math.pow(2, chars)).toString(2).slice(-chars)

  @functionCodeToText: (functionCode) ->
    copyCC = Utils.isBitSet(functionCode, 7)

    if Utils.isBitSet(functionCode, 7)
      fc = Utils.unsetBit(functionCode, 7)
    else
      fc = functionCode

    switch fc
      # 0: NOP
      when 0
        result = "NOP"
      # 1: -Z->Z
      when 1
        result = "-Z -> Z"
      # 2: X->Z
      when 2
        result = "X -> Z"
      # 3: -X->Z
      when 3
        result = "-X -> Z"
      # 4: Y->Z
      when 4
        result = "Y -> Z"
      # 5: -Y->Z
      when 5
        result = "-Y -> Z"
      # 6: Y->Z, X<->Y
      when 6
        result = "Y -> Z, X <-> Y"
      # 7: X->Z, X<->Y
      when 7
        result = "X -> Z, X <-> Y"
      # 8: Y->Z, Y->X
      when 8
        result = "Y -> Z, Y -> X"
      # 9: X+1->Z
      when 9
        result = "X+1 -> Z"
      # 10: X-1->Z
      when 10
        result = "X-1 -> Z"
      # 11: X+Y->Z
      when 11
        result = "X+Y -> Z"
      # 12: X-Y->Z
      when 12
        result = "X-Y -> Z"
      # 13: X*Y->Z
      when 13
        result = "X*Y -> Z"
      # 14: X/Y->Z
      when 14
        result = "X/Y -> Z"
      # 15: X%Y->Z
      when 15
        result = "X%Y -> Z"
      # 16: X SAL Y->Z
      when 16
        result = "X SAL Y -> Z"
      # 17: X SAR Y->Z
      when 17
        result = "X SAR Y -> Z"
      # 18: CMP arithm. X Y->Z
      when 18
        result = "CMPa X Y -> Z"
      # 19: X AND Y -> Z
      when 19
        result = "X AND Y -> Z"
      # 20: X NAND Y -> Z
      when 20
        result = "X NAND Y -> Z"
      # 21: X OR Y -> Z
      when 21
        result = "X OR Y -> Z"
      # 22: X NOR Y -> Z
      when 22
        result = "X NOR Y -> Z"
      # 23: X XOR Y -> Z
      when 23
        result = "X NOR Y -> Z"
      # 24: X NXOR Y -> Z
      when 24
        result = "X NXOR Y -> Z"
      # 25: X SLL Y -> Z
      when 25
        result = "X SLL Y -> Z"
      # 26: X SLR Y -> Z
      when 26
        result = "X SLR Y -> Z"
      # 27: CMP log. X Y -> Z
      when 27
        result = "CMPl X Y -> Z"
      # 28: 0->X
      when 28
        result = "0 -> X"
      # 29: 0xFFFFFFFF->X
      when 29
        result = "0xFFFFFFFF -> X"
      # 30: 0->Y
      when 30
        result = "0 -> Y"
      # 31: 0xFFFFFFFF->Y
      when 31
        result = "0xFFFFFFFF -> Y"
      else
        log.debug -> "fc else..."
        # 32-47: FC-32->X, X->Z
        if fc >= 32 and fc < 48
          result = "#{Utils.decToHex fc-32, 8} -> X, X -> Z"
        # 48-63: FC-48->Y, Y->Z
        else if fc >= 48 and fc < 64
          result = "#{Utils.decToHex fc-42, 8} -> Y, Y -> Z"
    result += ", CC" if copyCC is on
    result