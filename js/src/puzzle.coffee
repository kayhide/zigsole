class Puzzle
  constructor: (canvas) ->
    @stage = new Stage(canvas)
    @image = null
    @cutter = null
    @pieces = []
  
  initizlize: (@image, @cutter) ->
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

    @container = new Container()
    
    @pieces = @cutter.cut(@image)
    for p in @pieces
      @container.addChild(p)
      p.onPress = @onPiecePressed

    @stage.addChild(@container)
  
  update: ->
    @stage.update()
  
  zoom: (x, y, scale) ->
    @container.scaleX = @container.scaleX * scale
    @container.scaleY = @container.scaleX
    @container.x = x - (x - @container.x) * scale
    @container.y = y - (y - @container.y) * scale
    @stage.update()
  
  
  onStagePressed: (e) =>
    window.console.log('stage pressed: ' + e.stageX + ', ' + e.stageY)
    window.console.log(this)
    last_point = new Point(e.stageX, e.stageY)
    e.onMouseMove = (ev) =>
      pt = new Point(ev.stageX, ev.stageY)
      window.console.log(pt.y - last_point.y)
      @container.x += pt.x - last_point.x
      @container.y += pt.y - last_point.y
      
      last_point = pt;
      @stage.update();
  
  onPiecePressed: (e) =>
    window.console.log('shape pressed: ' + e.stageX + ', ' + e.stageY);
    @container.addChild(e.target)
    @stage.update()
    
    last_point = @container.globalToLocal(e.stageX, e.stageY)
    e.onMouseMove = (ev) =>
      pt = @container.globalToLocal(ev.stageX, ev.stageY)
      e.target.x += pt.x - last_point.x
      e.target.y += pt.y - last_point.y
      
      last_point = pt
      @stage.update()


@Puzzle = Puzzle
