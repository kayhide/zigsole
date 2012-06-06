class TouchController
  constructor: (@puzzle) ->
    @manipulator = new Shape()
    @colors =
      shadow: "#AFF"
    @shadow = null#new Shadow(@colors.shadow, 0, 0, 8)
  
  attach: ->
    Touch.enable(@puzzle.stage)
    
    @puzzle.background.onPress = @onStagePressed
    
    for p in @puzzle.pieces
      p.shape.onPress = @onPiecePressed

    @updateManipulator()
    @manipulator.onPress = @onManipulatorPressed

    Command.onPost.push((cmd) =>
      if cmd instanceof MergeCommand
        @puzzle.container.removeChild(cmd.mergee.shape)
        if @captured?.piece == cmd.piece or @captured?.piece == cmd.mergee
          @release()
      @puzzle.invalidate()
      return
    )
    
    Command.onCommit.push((cmds) =>
      unless @captured?
        @hideManipulator()
        @puzzle.invalidate()
      return
    )

  capture: (p, point) ->
    if @captured?
      @release()
    unless @captured?
      window.console.log("captured[#{p.id}] ( #{point.x}, #{point.y} )")
      @captured =
        piece: p
        point: point
      @showManipulator()
      p.shape.shadow = @shadow
      @puzzle.container.addChild(p.shape)
      
  
  release: ->
    if @captured?
      window.console.log("released[#{@captured.piece.id}]")
      @hideManipulator()
      unless @captured.piece.isAlive()
        @puzzle.container.removeChild(@captured.piece.shape)
      @captured.piece.shape.shadow = null
      @captured = null
      $(@puzzle.stage.canvas).off('mousemove mouseup')
      Command.commit()

  updateManipulator: ->
    g = @manipulator.graphics
    g.clear()
    r = @puzzle.cutter.linear_measure
    g.setStrokeStyle(@puzzle.cutter.linear_measure / 2)
    #g.beginRadialGradientStroke(["#AFF","#0FF"], [0, 1], 0, 0, r*7/8, 0, 0, r*9/8)
    g.beginStroke(@colors.shadow)
    g.drawCircle(0, 0, r)
#    g.setStrokeStyle(2)
#    g.beginRadialGradientStroke(["#000","#0FF"], [0, 1], 0, 0, r*7/8, 0, 0, r*9/8)
#    g.drawPolyStar(0, 0, r * (1 + 1/16), 32, 1/8, 0)
    @manipulator.alpha = 0.4
    @manipulator.shadow = @shadow
  
  showManipulator: () ->
    {piece, point} = @captured
    if piece.isAlive()
      point = @puzzle.container.localToGlobal(point.x, point.y)
      @manipulator.x = point.x
      @manipulator.y = point.y
      @puzzle.foreground.addChild(@manipulator)
      @puzzle.invalidate()

  hideManipulator: ->
    @puzzle.foreground.removeChild(@manipulator)

  onStagePressed: (e) =>
    if @captured?
      @release()
      @puzzle.invalidate()
    window.console.log("stage pressed: ( #{e.stageX}, #{e.stageY} )")
    last_point = new Point(e.stageX, e.stageY)

    first_move = true
    e.onMouseMove = (ev) =>
      if first_move?
        first_move = null
        return
      pt = new Point(ev.stageX, ev.stageY)
      @puzzle.container.x += pt.x - last_point.x
      @puzzle.container.y += pt.y - last_point.y
      
      last_point = pt;
      @puzzle.invalidate();
  
  onPiecePressed: (e) =>
    piece = e.target.piece
    window.console.log("piece[#{e.target.piece.id}] pressed: ( #{e.stageX}, #{e.stageY} )");
    
    point = @puzzle.container.globalToLocal(e.stageX, e.stageY)
    @capture(piece, point)
    @puzzle.invalidate()

    first_move = true
    e.onMouseMove = (ev) =>
      if first_move?
        first_move = null
        return
      pt = @puzzle.container.globalToLocal(ev.stageX, ev.stageY)
      @manipulator.x = ev.stageX
      @manipulator.y = ev.stageY
      vec = pt.subtract(@captured.point)
      @captured.point = pt
      new TranslateCommand(@captured.piece, vec).post()
    e.onMouseUp = (ev) =>
      Command.commit()
      @puzzle.tryMerge(@captured.piece)
    

  onManipulatorPressed: (e) =>
    piece = @captured.piece
    last_point = @manipulator.globalToLocal(e.stageX, e.stageY)
    
    first_move = true
    e.onMouseMove = (ev) =>
      if first_move?
        first_move = null
        return
      pt = @manipulator.globalToLocal(ev.stageX, ev.stageY)
      degree = @getAngle(last_point, pt) * 180 / Math.PI
      center = @manipulator.localToLocal(0, 0, @puzzle.container)
      @manipulator.rotation += degree
      new RotateCommand(piece, center, degree).post()
    e.onMouseUp = (ev) =>
      Command.commit()

  getAngle: (vec0, vec1) ->
    Math.atan2(vec1.y, vec1.x) - Math.atan2(vec0.y, vec0.x)


@TouchController = TouchController
