class MouseController
  constructor: (@puzzle) ->
    @colors =
      shadow: "#AFF"
  
  attach: ->
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
        if e.wheelDelta > 0
          @zoom(e.x, e.y, 1.2)
        else
          @zoom(e.x, e.y, 1/1.2)
      return
    )

    
    @puzzle.background.onPress = @onStagePressed
    
    for p in @puzzle.pieces
      p.shape.onPress = @onPiecePressed

    Command.onPost.push((cmd) =>
      if cmd instanceof TransformCommand
        cmd.piece.shape.x = cmd.position.x
        cmd.piece.shape.y = cmd.position.y
        cmd.piece.shape.rotation = cmd.rotation
      if cmd instanceof MergeCommand
        if @captured?.piece == cmd.piece or @captured?.piece == cmd.mergee
          @release()
        cmd.mergee.shape.remove()
      @puzzle.invalidate()
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
      @puzzle.activelayer.copyTransform(@puzzle.container)
      blur = 8 / @puzzle.container.scaleX
      p.shape.shadow = new Shadow(@colors.shadow, 0, 0, blur)
      p.enbox()
      p.cache(blur)
      @puzzle.activelayer.addChild(p.shape)
      @puzzle.wrapper.cache(0, 0, window.innerWidth, window.innerHeight)
      $(@puzzle.stage.canvas).on(
        mousemove: (e) =>
          pt = @puzzle.container.globalToLocal(e.clientX, e.clientY)
          vec = pt.subtract(@captured.point)
          unless vec.isZero()
            @captured.point = pt
            if @captured.mouse_pressed?
              new TranslateCommand(@captured.piece, vec).post()
            else
              lpt = @captured.piece.shape.globalToLocal(e.clientX, e.clientY)
              unless @captured.piece.shape.hitTest(lpt.x, lpt.y)
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
      @puzzle.wrapper.uncache()
      p = @captured.piece
      p.unbox()
      p.uncache()
      p.shape.shadow = null
      @captured = null
      $(@puzzle.stage.canvas).off('mousemove mouseup')
      Command.commit()
      @puzzle.invalidate()

  zoom: (x, y, scale) ->
    @puzzle.zoom(x, y, scale)

  onStagePressed: (e) =>
    last_point = new Point(e.stageX, e.stageY)
    e.onMouseMove = (ev) =>
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
    @captured.mouse_pressed = true
    @puzzle.invalidate()


@MouseController = MouseController
