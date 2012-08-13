
class @MicrocodeParser
  @parseGetPhase: (mc) ->
    actions = []

    # ioswitch: [1,2] = 01_2 -> RAM mode _read_
    if Utils.extractNum(mc.ioswitch, 1, 2) is 1
      actions.push "compute ram"

    # xbus: MSB is R0, LSB is R7, bit _ set -> push R_ to ALU's X register
    # At most one register will be pushed to X
    # Precedence: R0 < ... R7
    toXFrom = Utils.getLowestBitSet mc.xbus, 1, 8
    toXFrom = 8-toXFrom if toXFrom?
    if toXFrom?
      actions.push "push alu.X registers.#{toXFrom}"

    # ybus: MSB is R0, LSB is R7, bit _ set -> push R_ to ALU's Y register
    # At most one register will be pushed to Y
    # Precedence: R0 < ... R7
    toYFrom = Utils.getLowestBitSet mc.ybus, 1, 8
    toYFrom = 8-toYFrom if toYFrom?
    if toYFrom?
      actions.push "push alu.Y registers.#{toYFrom}"

    # ioswitch: [5] = 1 -> push MDR to ALU's Y register
    if Utils.isBitSet(mc.ioswitch, 5) is on
      actions.push "push alu.Y ram.MDR"

    # ioswitch: [4] = 1 -> push MDR to MAC's MCOP register (at most 8 bits)
    if Utils.isBitSet(mc.ioswitch, 4) is on
      actions.push "push mac.MCOP ram.MDR"

    # mode: update MAC's calculation mode
    actions.push "pushval mac.mode #{mc.mode}"

    # mcnext: update MAC's MCN
    actions.push "pushval mac.MCN #{mc.mcnext}"

    # mcnext: [1..4], update MAC's Mask
    actions.push "pushval mac.MASK #{Utils.extractNum(mc.mcnext, 1, 4)}"

    # alufc: update ALU's function code
    actions.push "pushval alu.FC #{mc.alufc}"

    # update MAC's MCAR
    actions.push "push mac.MCAR rom.MCAR"

    #return get phase actions
    actions

  @parseCalcPhase: (mc) ->
    actions = []
    # run alu
    actions.push "compute alu"
    # update CC
    actions.push "push mac.CC alu.CC"
    # run mac
    actions.push "compute mac"
    if Utils.isBitSet mc.alufc, 7
      action.push "info update cc"
    #return calc phase actions
    actions

  @parsePutPhase: (mc) ->
    actions = []
    
    # ioswitch: bit 8: z -> mar
    if Utils.isBitSet(mc.ioswitch, 8) is on
      actions.push "push ram.MAR alu.Z"

    # ioswitch: bit 7: z -> mdr
    if Utils.isBitSet(mc.ioswitch, 7) is on
      actions.push "push ram.MDR alu.Z"

    # ioswitch: bit 6: mdr -> z
    if Utils.isBitSet(mc.ioswitch, 6) is on
      actions.push "push alu.Z ram.MDR"

    # ioswitch: bit 3: mdr -> z
    if Utils.isBitSet(mc.ioswitch, 3) is on
      actions.push "push alu.Z ram.MAR"

    # ioswitch: [1,2] = 10_2 -> RAM mode _write_
    if Utils.extractNum(mc.ioswitch, 1, 2) is 2
      actions.push "compute ram"

    # zbus
    for bit in [1..8]
      if Utils.isBitSet(mc.zbus, bit) is on
        actions.push "push registers.#{8-bit} alu.Z"

    # update mcar
    actions.push "push rom.MCAR mac.MCARNEXT"

    # next microcode
    actions.push "next"

    #return put phase actions
    actions