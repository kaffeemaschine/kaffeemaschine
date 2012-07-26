class @MacListener
  constructor: (@onSetMode = undefined, @onSetCC = undefined, @onSetMask = undefined, @onSetTimes4 = undefined, @onSetMcop = undefined, @onSetMcarNext = undefined, @onSetMcn = undefined, @onSetMcar = undefined) ->
  setOnSetMode: (f) ->
    @onSetMode = f
  setOnSetCC: (f) ->
    @onSetCC = f
  setOnSetMask: (f) ->
    @onSetMask = f
  setOnSetTimes4: (f) ->
    @onSetTimes4 = f
  setOnSetMcop: (f) ->
    @onSetMcop = f
  setOnSetMcarNext: (f) ->
    @onSetMcarNext = f
  setOnSetMcn: (f) ->
    @onSetMcn = f
  setOnSetMcar: (f) ->
    @onSetMcar = f