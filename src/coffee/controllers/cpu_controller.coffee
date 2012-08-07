class @CpuController
  constructor: ->
    @log = Utils.getLogger 'CpuController'
    
    # reset button
    ($ "#power-reset-btn").click =>
      @cpu.reset()

    # init cpu listener
    @log.debug -> "init cpu listener"
    @cpuListener = new CpuListener()
    @cpuListener.setOnSetRegister( (register, value) ->
      ($ "#registers-r#{register}-tf").val(Utils.decToHex(value, 8)))
    @cpuListener.setOnSetMicrocode( (mc) ->
      ($ "#microcode-mode-tf").val(Utils.decToBin(mc.mode, 2))
      ($ "#microcode-mcnext-tf").val(Utils.decToBin(mc.mcnext, 6))
      ($ "#microcode-alufc-tf").val(Utils.decToBin(mc.alufc, 8))
      ($ "#microcode-xbus-tf").val(Utils.decToBin(mc.xbus, 8))
      ($ "#microcode-ybus-tf").val(Utils.decToBin(mc.ybus, 8))
      ($ "#microcode-zbus-tf").val(Utils.decToBin(mc.zbus, 8))
      ($ "#microcode-ioswitch-tf").val(Utils.decToBin(mc.ioswitch, 8))
      ($ "#microcode-byte-tf").val(Utils.decToBin(mc.byte, 2))
      ($ "#info-tarea").val(mc.remarks))

    # init cpu
    @log.debug -> "init cpu"
    @cpu = new Cpu()
    @cpu.setCpuListeners [@cpuListener]
    @cpu.reset()


$(document).ready -> new CpuController()