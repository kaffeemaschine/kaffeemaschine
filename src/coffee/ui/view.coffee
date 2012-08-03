$(window).resize ->
  console.log(
    $('#registers-r1-btn').offset().top - $('#registers-r0-btn').offset().top
  )

class @ConductorPathView
  constructor: (@strokeStyle = "#000", @fillEmpty = "#fff",
      @lineWidth = 0.5, @pathWidth = 6) ->

    @createCanvas()
    @drawXBus()
    @drawYBus()

  drawXBus: ->
    console.log "drawing x bus"
    @context.strokeStyle = @strokeStyle
    @context.fillStyle = @fillEmpty
    @context.lineWidth = @lineWidth
    xPos = $('#registers').offset().left - $('#overlay').offset().left +
              $('#registers').width()
    yPos = $('#registers-r0-btn').offset().top - $('#overlay').offset().top +
              $('#registers-r0-btn').height()
    offX = 30
    offY = $('#registers-r1-btn').offset().top -
              $('#registers-r0-btn').offset().top
    middleY = 275.5
    endX = $('#alu-z-tf').offset().left - $('#overlay').offset().left +
              $('#alu-z-tf').width()/2
    endY = $('#alu-z-tf').offset().top - $('#overlay').offset().top

    # draw connectors register side
    for register in [0..7]
      @context.beginPath()
      @context.moveTo xPos, yPos + register * offY

      if register is 0
        @context.lineTo xPos+offX+@pathWidth, yPos + register * offY
      else
        @context.lineTo xPos+offX, yPos + register * offY

      @context.moveTo xPos, yPos + @pathWidth + register * offY

      if register is 7
        @context.lineTo xPos+offX+@pathWidth, yPos +
                            @pathWidth + register * offY
      else
        @context.lineTo xPos+offX, yPos + @pathWidth + register * offY

      @context.lineTo xPos+offX, yPos + (register+1) * offY unless register is 7
      @context.stroke()
      @context.beginPath()
      @context.rect xPos, yPos + register*offY+1, offX, @pathWidth-2
      @context.fill()
    @context.beginPath()
    @context.moveTo xPos+offX+@pathWidth, yPos
    @context.lineTo xPos+offX+@pathWidth, middleY
    @context.moveTo xPos+offX+@pathWidth, middleY+@pathWidth
    @context.lineTo xPos+offX+@pathWidth, yPos + @pathWidth + 7 * offY
    @context.stroke()
    @context.beginPath()
    @context.rect xPos+offX+1, yPos+1, @pathWidth-2, 7*offY+@pathWidth-1
    @context.fill()

    #draw middle part and connector alu side
    @context.beginPath()
    @context.moveTo xPos+offX+@pathWidth, middleY
    @context.lineTo endX+@pathWidth, middleY
    @context.lineTo endX+@pathWidth, endY
    @context.moveTo xPos+offX+@pathWidth, middleY+@pathWidth
    @context.lineTo endX, middleY+@pathWidth
    @context.lineTo endX, endY
    @context.stroke()
    @context.beginPath()
    @context.rect xPos+offX+@pathWidth, middleY+1, endX-(xPos+offX+@pathWidth),
                  @pathWidth-2
    @context.rect endX, middleY+1, @pathWidth-2, endY-middleY-1
    @context.fill()

  drawYBus: ->
    console.log "drawing y bus"
    @context.strokeStyle = @strokeStyle
    @context.lineWidth = @lineWidth
    xPos = $('#registers').offset().left - $('#overlay').offset().left +
                $('#registers').width()
    yPos = $('#registers-r0-btn').offset().top - $('#overlay').offset().top +
                $('#registers-r0-btn').height()/3
    offX = 60
    offY = $('#registers-r1-btn').offset().top -
                $('#registers-r0-btn').offset().top
    middleY = 245.5
    endX = $('#alu-y-tf').offset().left - $('#overlay').offset().left +
                $('#alu-y-tf').width()/2
    endY = $('#alu-y-tf').offset().top - $('#overlay').offset().top
    mdrX = $('#ram').offset().left - $('#overlay').offset().left +
                $('#ram').width()
    mdrY = $('#ram-mdr-btn').offset().top - $('#overlay').offset().top +
                $('#ram-mdr-btn').height()/2

    # draw connector mdr side
    @context.beginPath()
    @context.moveTo mdrX, mdrY
    @context.lineTo xPos+offX+@pathWidth, mdrY
    @context.lineTo xPos+offX+@pathWidth, yPos
    @context.moveTo mdrX, mdrY+@pathWidth
    @context.lineTo xPos+offX, mdrY+@pathWidth
    @context.lineTo xPos+offX, yPos
    @context.stroke()
    @context.beginPath()
    @context.rect mdrX, mdrY+1, xPos+offX-mdrX, @pathWidth-2
    @context.rect xPos+offX, mdrY+1, @pathWidth-2, yPos-mdrY
    @context.fill()

    # draw connectors register side
    for register in [0..7]
      @context.beginPath()
      @context.moveTo xPos, yPos + register * offY
      @context.lineTo xPos+offX, yPos + register * offY
      @context.moveTo xPos, yPos + @pathWidth + register * offY

      if register is 7
        @context.lineTo xPos+offX+@pathWidth, yPos + @pathWidth +
                register * offY
      else
        @context.lineTo xPos+offX, yPos + @pathWidth + register * offY
        @context.lineTo xPos+offX, yPos + (register+1) * offY

      @context.stroke()
      @context.beginPath()
      @context.rect xPos, yPos + register*offY+1, offX, @pathWidth-2
      @context.fill()
    @context.beginPath()
    @context.moveTo xPos+offX+@pathWidth, yPos
    @context.lineTo xPos+offX+@pathWidth, middleY
    @context.moveTo xPos+offX+@pathWidth, middleY+@pathWidth
    @context.lineTo xPos+offX+@pathWidth, yPos + @pathWidth + 7 * offY
    @context.stroke()
    @context.beginPath()
    @context.rect xPos+offX+1, yPos+1, @pathWidth-2, 7*offY+@pathWidth-1
    @context.fill()

    #draw middle part and connector alu side
    @context.beginPath()
    @context.moveTo xPos+offX+@pathWidth, middleY
    @context.lineTo endX+@pathWidth, middleY
    @context.lineTo endX+@pathWidth, endY
    @context.moveTo xPos+offX+@pathWidth, middleY+@pathWidth
    @context.lineTo endX, middleY+@pathWidth
    @context.lineTo endX, endY
    @context.stroke()
    @context.beginPath()
    @context.rect xPos+offX+@pathWidth, middleY+1, endX-(xPos+offX+@pathWidth),
                  @pathWidth-2
    @context.rect endX, middleY+1, @pathWidth-2, endY-middleY-1
    @context.fill()

  createCanvas: ->
    @canvas = document.getElementById 'canvas'
    @context = @canvas.getContext '2d'

  clearCanvas: ->
    @context.clearRect 0, 0, @canvas.width, @canvas.height

cpv = new ConductorPathView
console.log "cpv = #{cpv}"
