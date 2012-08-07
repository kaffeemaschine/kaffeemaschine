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