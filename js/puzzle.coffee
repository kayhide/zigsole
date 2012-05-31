class Puzzle
  constructor: (canvas) ->
    @stage = new Stage(canvas)
    @image = null
    @cutter = null
    @pieces = []
  
  initizlize: (image, cutter) ->
    @image = image
    @cutter = cutter
    
    @stage.enableMouseOver()
    @stage.canvas.onmousewheel = (e) =>
      if e.wheelDelta > 0
        @zoom(e.x, e.y, 1.2)
      else
        @zoom(e.x, e.y, 1/1.2)
    
    @background = new Shape()
    @background.onPress = @onStagePressed
    @background.graphics.beginFill(Graphics.getRGB(0,0,0))
    @background.graphics.rect(0, 0, screen.width, screen.height)
    @stage.addChild(@background)

    @pieces = @cutter.cut(@image)
    for p in @pieces
      @stage.addChild(p)
      p.onPress = @onPiecePressed
  
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


@Puzzle = Puzzle
