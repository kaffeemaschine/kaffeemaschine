class @CpuListener
  constructor: (@onSignal = undefined, @onNextPhase = undefined, @onSetRegister = undefined) ->
  setOnSignal: (f) ->
    @onSignal = f
  setOnNextPhase: (f) ->
    @onNextPhase = f
  setOnSetRegister: (f) ->
    @onSetRegister = f