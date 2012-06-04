class BrowserController
  constructor: (@puzzle) ->
    @uses_manipulator = false
    @manipulator = new Shape()
    @colors =
      shadow: "#AFF"
  
  attach: ->
    @puzzle.activelayer.shadow = new Shadow(@colors.shadow, 0, 0, 8)
    
    $().on('resize', ->
      @puzzle.stage.canvas.width = window.innerWidth
      @puzzle.stage.canvas.height = window.innerHeight
      @puzzle.stage.update()
    )

    $(@puzzle.stage.canvas).on('mousewheel', (e) =>
      e = e.originalEvent
      unless @captured?
        p = @puzzle.stage.getObjectUnderPoint(e.clientX, e.clientY)?.piece
        if p?
          @capture(p, @puzzle.container.globalToLocal(e.clientX, e.clientY))
      if @captured?
        { piece, point } = @captured
        new RotateCommand(piece, point, -e.wheelDelta / 10).post()
      else
        @hideManipulator()
        if e.wheelDelta > 0
          @zoom(e.x, e.y, 1.2)
        else
          @zoom(e.x, e.y, 1/1.2)
      return
    )

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
      @puzzle.stage.update()
      return
    )
    
    Command.onCommit.push((cmds) =>
      unless @manipulator.target?.isAlive()
        @hideManipulator()
        @puzzle.stage.update()
      return
    )

  capture: (p, point) ->
    if @captured?
      Command.commit()
    else
      window.console.log("captured[#{p.id}] ( #{point.x}, #{point.y} )")
      @captured =
        piece: p
        point: point
      @puzzle.container.removeChild(p.shape)
      @puzzle.wrapper.cache(0, 0, @puzzle.stage.canvas.width, @puzzle.stage.canvas.height)
      @puzzle.activelayer.copyTransform(@puzzle.container)
      @puzzle.activelayer.addChild(p.shape)
#      p.cache()
      $(@puzzle.stage.canvas).on(
        mousemove: (e) =>
          pt = @puzzle.container.globalToLocal(e.clientX, e.clientY)
          vec = pt.subtract(@captured.point)
          unless vec.isZero()
            if @captured.mouse_pressed?
              @captured.point = pt
              new TranslateCommand(@captured.piece, vec).post()
            else
              @release()
          return
        mouseup: (e) =>
          if e.which == 1
            @captured.mouse_pressed = null
            Command.commit()
            @puzzle.tryMerge(@captured.piece)
      )

  release: ->
    if @captured?
      window.console.log("released[#{@captured.piece.id}]")
      if @captured.piece.isAlive()
        @puzzle.container.addChild(@captured.piece.shape)
      else
        @puzzle.activelayer.removeChild(@captured.piece.shape)
      @puzzle.wrapper.uncache()
      @captured.piece.uncache()
      Command.commit()
      @captured = null
      $(@puzzle.stage.canvas).off('mousemove mouseup')

  zoom: (x, y, scale) ->
    @puzzle.container.scaleX = @puzzle.container.scaleX * scale
    @puzzle.container.scaleY = @puzzle.container.scaleX
    @puzzle.container.x = x - (x - @puzzle.container.x) * scale
    @puzzle.container.y = y - (y - @puzzle.container.y) * scale
    @puzzle.stage.update()

  updateManipulator: ->
    g = @manipulator.graphics
    g.clear()
    r = Math.min(window.innerWidth, window.innerHeight) / 4
    g.setStrokeStyle(r/4)
    g.beginRadialGradientStroke(["#AFF","#0FF"], [0, 1], 0, 0, r*7/8, 0, 0, r*9/8)
    g.drawCircle(0, 0, r)
    g.setStrokeStyle(2)
    g.beginRadialGradientStroke(["#000","#0FF"], [0, 1], 0, 0, r*7/8, 0, 0, r*9/8)
    g.drawPolyStar(0, 0, r * (1 + 1/16), 32, 1/8, 0)
    @manipulator.alpha = 0.4
  
  showManipulator: (p, center = null) ->
    if @uses_manipulator and p.isAlive()
      unless center
        center = p.shape.getCenter()
        center = p.shape.localToGlobal(center.x, center.y)
      @manipulator.x = center.x
      @manipulator.y = center.y
      @manipulator.target = p
      @puzzle.foreground.addChild(@manipulator)
      @puzzle.stage.update()

  hideManipulator: ->
    @manipulator.target = null
    @puzzle.foreground.removeChild(@manipulator)

  onStagePressed: (e) =>
    @hideManipulator()
    @puzzle.stage.update()
    window.console.log("stage pressed: ( #{e.stageX}, #{e.stageY} )")
    last_point = new Point(e.stageX, e.stageY)
    e.onMouseMove = (ev) =>
      pt = new Point(ev.stageX, ev.stageY)
      @puzzle.container.x += pt.x - last_point.x
      @puzzle.container.y += pt.y - last_point.y
      
      last_point = pt;
      @puzzle.stage.update();
  
  onPiecePressed: (e) =>
    @hideManipulator()
    piece = e.target.piece
    window.console.log("piece[#{e.target.piece.id}] pressed: ( #{e.stageX}, #{e.stageY} )");
    
    point = @puzzle.container.globalToLocal(e.stageX, e.stageY)
    @capture(piece, point)
    @captured.mouse_pressed = true
    @puzzle.stage.update()

  onManipulatorPressed: (e) =>
    piece = @manipulator.target
    last_point = @manipulator.globalToLocal(e.stageX, e.stageY)
    e.onMouseMove = (ev) =>
      pt = @manipulator.globalToLocal(ev.stageX, ev.stageY)
      degree = @getAngle(last_point, pt) * 180 / Math.PI
      center = @manipulator.localToLocal(0, 0, @puzzle.container)
      @manipulator.rotation += degree
      new RotateCommand(piece, center, degree).post()
    e.onMouseUp = (ev) =>
      Command.commit()

  getAngle: (vec0, vec1) ->
    Math.atan2(vec1.y, vec1.x) - Math.atan2(vec0.y, vec0.x)


@BrowserController = BrowserController
