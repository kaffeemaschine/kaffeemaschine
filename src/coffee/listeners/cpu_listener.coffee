class @CpuListener
  constructor: (@onSignal = undefined, @onNextPhase = undefined,
      @onSetRegister = undefined, @onSetMicrocode = undefined) ->
  setOnSignal: (f) ->
    @onSignal = f
  setOnNextPhase: (f) ->
    @onNextPhase = f
  setOnSetRegister: (f) ->
    @onSetRegister = f
  setOnSetMicrocode: (f) ->
    @onSetMicrocode = f
    
