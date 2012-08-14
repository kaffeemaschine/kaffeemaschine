class @RamController extends AbstractController
  constructor: (@ram) ->
    @log = Utils.getLogger 'RamController'
    @initRamModal()
    @initListener()
    @initButtonHandlers()

  initRamModal: ->
    for row in [0..255]
      ($ '#modal-ram-table > tbody:last').append "
  <tr id=\"modal-ram-row-#{row}\">
    <td>#{Utils.decToHex row*8, 3}</td>
    <td id=\"modal-ram-b#{row*8}-tf\">00</td>
    <td id=\"modal-ram-b#{row*8+1}-tf\">00</td>
    <td id=\"modal-ram-b#{row*8+2}-tf\">00</td>
    <td id=\"modal-ram-b#{row*8+3}-tf\">00</td>
    <td id=\"modal-ram-b#{row*8+4}-tf\">00</td>
    <td id=\"modal-ram-b#{row*8+5}-tf\">00</td>
    <td id=\"modal-ram-b#{row*8+6}-tf\">00</td>
    <td id=\"modal-ram-b#{row*8+7}-tf\">00</td>
  </tr>"

    parseRamId = (id) ->
      [u,v,w,row] = id.split "-"
      parseInt row
    # update editable cells
    doUpdate = (row) =>
      for offset in [0..7]
        ($ "#modal-ram-val#{offset}-tf").val (Utils.decToHex (@ram.getByte row*8+offset), 2)

    ($ '#modal-ram-table tbody tr').click ->
      ($ '#modal-ram-table tbody tr').removeClass 'ram-selection-highlight'
      unless ($ @).hasClass 'ram-selection-highlight'
        ($ @).addClass 'ram-selection-highlight'
        doUpdate (parseRamId (($ @).attr 'id'))

    ($ '#modal-ram-set-btn').click =>
      row = parseRamId (@getSelectedRamRow().attr 'id')
      for offset in [0..7]
        @ram.setByte row*8+offset, (parseInt ($ "#modal-ram-val#{offset}-tf").val(), 16)
        
    

  initListener: ->
    @ramListener = new RamListener()
    @ramListener.setOnSetFormat (value) ->
      ($ "#ram-byte-label").html "#{value+1} Byte"
    @ramListener.setOnSetMode (value) ->
      switch value
        when 1
          ($ "#ram-mode-label").html "Reading"
        when 2
          ($ "#ram-mode-label").html "Writing"
        else
          ($ "#ram-mode-label").html "Waiting"
    @ramListener.setOnSetMar (value) ->
      ($ "#ram-mar-tf").val (Utils.decToHex value, 3)
    @ramListener.setOnSetMdr (value) =>
      ($ "#ram-mdr-tf").val (Utils.decToHex value, 2+@ram.format*2)
    @ramListener.setOnSetByte (at, value) ->
      console.log "update"
      ($ "#modal-ram-b#{at}-tf").html (Utils.decToHex value, 2)
  
    @log.debug -> 'setting ram listener'
    @ram.setRamListeners [@ramListener]

  initButtonHandlers: ->
    ($ "#ram-mar-btn").click =>
      @showSetValueModal @ram.mar, 0x7FF, 11, (val) =>
        @ram.setMar val
    ($ "#ram-mdr-btn").click =>
      @showSetValueModal @ram.mdr, 0xFFFFFFFF, 32, (val) =>
        @ram.setMdr val
    ($ "#ram-ram-btn").click =>
      @showRamModal()

  getSelectedRamRow: ->
    # find selection row
    row = ($ '#modal-ram-table
              tbody
              tr[class~="ram-selection-highlight"]')
    if row.length isnt 1
      #backup to default selection
      ($ '#modal-ram-table tbody tr').removeClass 'ram-selection-highlight'
      row = ($ '#modal-ram-table tbody tr:first-child')
    row

  showRamModal: ->
    row = @getSelectedRamRow()
    # update values  
    row.trigger('click')
    ($ '#modal-ram').modal('show')