class @AluListener
  constructor: (@onSetX = undefined, @onSetY = undefined, @onSetZ = undefined, @onSetCC = undefined, @onSetFlags = undefined, @onsetFC = undefined) ->

  @setOnSetX: (f) -> @onSetX = f
  @setOnSetY: (f) -> @onSetY = f
  @setOnSetZ: (f) -> @onSetZ = f
  @setOnSetCC: (f) -> @onSetCC = f
  @setOnSetFlags: (f) -> @onSetFlags = f
  @setOnSetFC: (f) -> @onSetFC = f