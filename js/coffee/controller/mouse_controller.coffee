class MouseController
  constructor: (@puzzle) ->
    @colors =
      shadow: "#AFF"
  
  attach: ->
    @activelayer = new Container()
    @puzzle.stage.addChild(@activelayer)
  
    $(@puzzle.stage.canvas).on('mousewheel', (e) =>
      e = e.originalEvent
      unless @captured?
        p = @puzzle.stage.getObjectUnderPoint(e.clientX, e.clientY)?.piece
        if p?
          @capture(p, @puzzle.container.globalToLocal(e.clientX, e.clientY))
      unless @captured?
        if e.wheelDelta > 0
          @zoom(e.x, e.y, 1.2)
        else
          @zoom(e.x, e.y, 1/1.2)
      return
    )

    $(@puzzle.stage.canvas).on('mousedown', (e) =>
      pt = new Point(e.offsetX, e.offsetY)
      p = @puzzle.stage.getObjectUnderPoint(pt.x, pt.y)?.piece
      if p?
        @capture(p, pt.to(@puzzle.container), e)
        return
      @dragStage(e)
      return
    )

    Command.onPost.push((cmd) =>
      if cmd instanceof TransformCommand
        p = cmd.piece
        { x: p.shape.x, y: p.shape.y } = p.position()
        p.shape.rotation = p.rotation()
        @puzzle.invalidate()
      if cmd instanceof MergeCommand
        if @captured?.piece == cmd.piece or @captured?.piece == cmd.mergee
          @release()
        cmd.mergee.shape.remove()
        @puzzle.invalidate()
      return
    )

  putToActivelayer: (p) ->
    @activelayer.copyTransform(@puzzle.container)
    @activelayer.addChild(p.shape)

  capture: (p, point, event) ->
    unless @captured?
      window.console.log("captured[#{p.id}] ( #{point.x.toFixed(2)}, #{point.y.toFixed(2)} )")
      @captured =
        piece: p
        point: point
      @captured.dragging = true if event?.type == 'mousedown'
      
      blur = 8
      p.shape.shadow = new Shadow(@colors.shadow, 0, 0, blur)
      @putToActivelayer(p)
      @cacheStage()
      @puzzle.invalidate()
      $(window).on(
        mousedown: (e) =>
          if @captured?
            pt = new Point(e.clientX, e.clientY)
              .fromWindow()
              .to(@puzzle.container)
            @captured.point = pt
            @captured.dragging = true
          return
        mouseup: (e) =>
          if @captured?
            @captured.dragging = null
            @puzzle.tryMerge(@captured.piece)
          return
        mousewheel: (e) =>
          e = e.originalEvent
          if @captured?
            { piece, point } = @captured
            new RotateCommand(piece, point, -e.wheelDelta / 10).post()
          return
        mousemove: (e) =>
          if @captured?.dragging?
            pt0 = @captured.point
            @captured.point = new Point(e.clientX, e.clientY)
              .fromWindow()
              .to(@puzzle.container)
            vec = @captured.point.subtract(pt0)
            new TranslateCommand(@captured.piece, vec).post()
          else
            @captured.point = new Point(e.clientX, e.clientY)
              .fromWindow()
              .to(@puzzle.container)
            pt = @captured.point.to(@captured.piece.shape)
            unless @captured.piece.shape.hitTest(pt.x, pt.y)
              @release()
          return
      )

  release: ->
    if @captured?
      window.console.log("released[#{@captured.piece.id}]")
      p = @captured.piece
      p.shape.shadow = null
      if p.isAlive()
        { x: p.shape.x, y: p.shape.y } = p.position()
        p.shape.rotation = p.rotation()
        @puzzle.container.addChild(p.shape)
      @captured = null
      $(window).off('mousedown mouseup mousemove mousewheel')
      Command.commit()
      @cacheStage(false)
      @puzzle.invalidate()

  zoom: (x, y, scale) ->
    @puzzle.zoom(x, y, scale)

  cacheStage: (b = true) ->
    if b
      [w, h] = [window.screen.width, window.screen.height]
      pt0 = new Point(-w / 2, -h / 2).fromWindow().to(@puzzle.wrapper)
      pt1 = new Point(w * 3 / 2, h * 3 / 2).fromWindow().to(@puzzle.wrapper)
      @puzzle.wrapper.cache(pt0.x, pt0.y, pt1.x - pt0.x, pt1.y - pt0.y)
    else
      @puzzle.wrapper.uncache()
    return

  dragStage: (event) ->
    @cacheStage()
    last_point = new Point(event.clientX, event.clientY)
    $(window).on(
      mousemove: (e) =>
        pt = new Point(e.clientX, e.clientY)
        @puzzle.wrapper.x += pt.x - last_point.x
        @puzzle.wrapper.y += pt.y - last_point.y
      
        last_point = pt;
        @puzzle.invalidate();
        return
      mouseup: (e) =>
        pt =
          new Point(0, 0)
          .from(@puzzle.container)
          .to(@puzzle.wrapper.parent)
        { x: @puzzle.container.x, y: @puzzle.container.y } = pt
        @puzzle.wrapper.x = 0
        @puzzle.wrapper.y = 0
        $(window).off('mousemove mouseup')
        @cacheStage(false)
        @puzzle.invalidate();
        return
    )


@MouseController = MouseController
