class Puzzle
  constructor: (canvas) ->
    @stage = new Stage(canvas)
    @image = null
    @cutter = null
    @pieces = []
    @rotation_tolerance = 10
    @translation_tolerance = 0
  
  initizlize: (@image, @cutter) ->
    #@stage.enableMouseOver()
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
    @translation_tolerance = @cutter.linear_measure / 16
    for p, i in @pieces
      p.id = i
      p.puzzle = this
      p.shape = new Shape()
      p.shape.piece = p
      p.draw()
      @container.addChild(p.shape)
      p.shape.onPress = @onPiecePressed

    @stage.addChild(@container)
    @stage.update()
    
    Command.onPost = (cmd) =>
      @stage.update()
      return
    
    Command.onCommit = (cmds) =>
      for cmd in cmds when cmd.isTransformCommand()
        @tryMerge(cmd.piece)
      return

  tryMerge: (piece) ->
    for p in piece.getAdjacentPieces() when p.isWithinTolerance(piece)
      new MergeCommand(p, piece).commit()
      break
    return
  
  zoom: (x, y, scale) ->
    @container.scaleX = @container.scaleX * scale
    @container.scaleY = @container.scaleX
    @container.x = x - (x - @container.x) * scale
    @container.y = y - (y - @container.y) * scale
    @stage.update()
  
  
  onStagePressed: (e) =>
    window.console.log("stage pressed: ( #{e.stageX}, #{e.stageY} )")
    last_point = new Point(e.stageX, e.stageY)
    e.onMouseMove = (ev) =>
      pt = new Point(ev.stageX, ev.stageY)
      @container.x += pt.x - last_point.x
      @container.y += pt.y - last_point.y
      
      last_point = pt;
      @stage.update();
  
  onPiecePressed: (e) =>
    window.console.log("piece[#{e.target.piece.id}] pressed: ( #{e.stageX}, #{e.stageY} )");
    @container.addChild(e.target)
    @stage.update()

    piece = e.target.piece
    
    last_point = @container.globalToLocal(e.stageX, e.stageY)

    local_point = e.target.globalToLocal(e.stageX, e.stageY)
    if local_point.distanceTo(piece.getCenter()) > 0.4 * @cutter.linear_measure
      center = piece.getCenter()
      center = e.target.localToParent(center.x, center.y)
      e.onMouseMove = (ev) =>
        pt = @container.globalToLocal(ev.stageX, ev.stageY)
        vec = pt.subtract(last_point)
        new RotateCommand(e.target.piece, center, vec.x).post()
        last_point = pt
      e.onMouseUp = (ev) =>
        Command.commit()
        
    else
      e.onMouseMove = (ev) =>
        pt = @container.globalToLocal(ev.stageX, ev.stageY)
        vec = pt.subtract(last_point)
        new TranslateCommand(e.target.piece, vec).post()
        last_point = pt
      e.onMouseUp = (ev) =>
        Command.commit()


@Puzzle = Puzzle
