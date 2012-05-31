class Puzzle
  constructor: (canvas) ->
    @stage = new Stage(canvas)
    @image = null
    @pieces = []
    @nx = 10
  
  cut: ->
    w = @image.width / @nx
    h = @image.height / @ny
    for y in [0...@ny]
      for x in [0...@nx]
        p = x: x*w, y: y*h, w: w, h: h
        @pieces.push(p)
  
  pieceCount: ->
    @nx*@ny
  
  initizlize: (image) ->
    @image = image
    @aspect_ratio = @image.width / @image.height
    @ny = Math.round(@nx / @aspect_ratio)
    @cut()
    
    @stage.enableMouseOver()
    
    @background = new Shape()
    @background.onPress = @onStagePressed
    @background.graphics.beginFill(Graphics.getRGB(0,0,0))
    @background.graphics.rect(0, 0, screen.width, screen.height)
    @stage.addChild(@background)
    
    for p in puzzle.pieces
      shape = new Shape()
      shape.graphics.beginBitmapFill(@image)
      shape.graphics.drawRoundRect(p.x, p.y, p.w, p.h, p.w*0.2)
      shape.cache(p.x, p.y, p.w, p.h)
      @stage.addChild(shape)
      shape.onPress = @onPiecePressed
  
  update: ->
    @stage.update()
  
  updateBackground: ->
    @background.x = - @stage.x / @stage.scaleX
    @background.y = - @stage.y / @stage.scaleY
    @background.scaleX = 1 / @stage.scaleX
    @background.scaleY = 1 / @stage.scaleY
  
  zoom: (x, y, scale) ->
    @stage.scaleX = @stage.scaleX * scale
    @stage.scaleY = @stage.scaleX
    @stage.x = x - (x - @stage.x) * scale
    @stage.y = y - (y - @stage.y) * scale
    @updateBackground()
    @stage.update()
  
  
  onStagePressed: (e) =>
    window.console.log('stage pressed: ' + e.stageX + ', ' + e.stageY)
    window.console.log(this)
    last_point = new Point(e.stageX, e.stageY)
    e.onMouseMove = (ev) =>
      pt = new Point(ev.stageX, ev.stageY)
      window.console.log(pt.y - last_point.y)
      @stage.x += pt.x - last_point.x
      @stage.y += pt.y - last_point.y
      
      last_point = pt;
      @updateBackground();
      @stage.update();
  
  onPiecePressed: (e) =>
    window.console.log('shape pressed: ' + e.stageX + ', ' + e.stageY);
    @stage.addChild(e.target)
    @stage.update()
    
    last_point = @stage.globalToLocal(e.stageX, e.stageY)
    e.onMouseMove = (ev) =>
      pt = @stage.globalToLocal(ev.stageX, ev.stageY)
      e.target.x += pt.x - last_point.x
      e.target.y += pt.y - last_point.y
      
      last_point = pt
      @stage.update()

$( ->
  field = document.getElementById("field")
  field.width = window.innerWidth
  field.height = window.innerHeight
  
  puzzle = new Puzzle(field)
  
  image = new Image()
  image.onload = ->
    puzzle.initizlize(image)
    puzzle.update()
    $("#info").text("#{puzzle.pieceCount()} ( #{puzzle.nx} x #{puzzle.ny} )")
    
  image.src = "/easel/test/AA145_L.jpg"
  

  window.puzzle = puzzle
  
  field.onmousewheel = (e) ->
    if e.wheelDelta > 0
      puzzle.zoom(e.x, e.y, 1.2)
    else
      puzzle.zoom(e.x, e.y, 1/1.2)
  
  window.onresize = ->
    field.width = window.innerWidth
    field.height = window.innerHeight
    puzzle.update();
)
