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
        if @captured?.piece == cmd.piece
          if cmd instanceof RotateCommand
            @putToActivelayer(cmd.piece)
            @puzzle.activelayer.invalidate()
        else
          p = cmd.piece
          { x: p.shape.x, y: p.shape.y } = p.position()
          p.shape.rotation = p.rotation()
          @puzzle.stage.invalidate()
      if cmd instanceof MergeCommand
        if @captured?.piece == cmd.piece or @captured?.piece == cmd.mergee
          @release()
        cmd.mergee.shape.remove()
        @puzzle.stage.invalidate()
      return
    )

  putToActivelayer: (p) ->
    boundary = p.getBoundary().inflate(10)
    pt0 = @puzzle.container.localToWindow(boundary.x, boundary.y)
    pt1 = @puzzle.container.localToWindow(boundary.x + boundary.width, boundary.y + boundary.height)
    @puzzle.activelayer.copyTransform(@puzzle.container)
    @puzzle.activelayer.x = 0
    @puzzle.activelayer.y = 0
    @puzzle.activelayer.canvas.width = (pt1.x - pt0.x)
    @puzzle.activelayer.canvas.height = (pt1.y - pt0.y)
    $(@puzzle.activelayer.canvas)
    .css('left', pt0.x)
    .css('top', pt0.y)
    .width(@puzzle.activelayer.canvas.width)
    .height(@puzzle.activelayer.canvas.height)
    .show()
    { x: p.shape.x, y: p.shape.y } =
      p.position()
      .from(@puzzle.container)
      .to(@puzzle.activelayer)
    p.shape.rotation = p.rotation()
    @puzzle.activelayer.addChild(p.shape)
    @puzzle.activelayer.update()

  capture: (p, point, event) ->
    if @captured?
      Command.commit()
    else
      window.console.log("captured[#{p.id}] ( #{point.x}, #{point.y} )")
      @captured =
        piece: p
        point: point
      @captured.dragging = true if event?
      
      blur = 8
      p.shape.shadow = new Shadow(@colors.shadow, 0, 0, blur)
      @putToActivelayer(p)
      @puzzle.invalidate()
      $(@puzzle.activelayer.canvas).on(
        drag: (e, ui) =>
          pt =
            new Point(e.clientX, e.clientY)
            .toWindow()
            .to(@puzzle.activelayer)
            .to(@puzzle.container)
          vec = pt.subtract(@captured.point)
          @captured.point = pt
          new TranslateCommand(@captured.piece, vec).post()
          return
        dragstart: (e, ui) =>
          @captured.dragging = true
          @captured.point =
            new Point(e.clientX, e.clientY)
            .toWindow()
            .to(@puzzle.activelayer)
            .to(@puzzle.container)
          return
        mouseup: (e, ui) =>
          @captured.dragging = null
          Command.commit()
          @puzzle.tryMerge(@captured.piece)
          return
        mousewheel: (e) =>
          e = e.originalEvent
          if @captured?
            { piece, point } = @captured
            new RotateCommand(piece, point, -e.wheelDelta / 10).post()
          return
      )
      $(window).on(
        mousemove: (e) =>
          unless @captured?.dragging?
            @captured.point =
              new Point(e.clientX, e.clientY)
              .toWindow()
              .to(@puzzle.activelayer)
              .to(@puzzle.container)
            pt = @captured.point.to(@captured.piece.shape)
            unless @captured.piece.shape.hitTest(pt.x, pt.y)
              @release()
          return
      )
      if event?.type == 'mousedown'
        $(@puzzle.activelayer.canvas).trigger(event)

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
      $(@puzzle.activelayer.canvas).off('drag dragstart mouseup mousewheel')
      $(window).off('mousemove')
      Command.commit()
      @puzzle.invalidate()

  zoom: (x, y, scale) ->
    @puzzle.zoom(x, y, scale)

  dragStage: (event) ->
    [w, h] = [window.screen.width, window.screen.height]
    pt0 = new Point(-w / 2, -h / 2).fromWindow().to(@puzzle.wrapper)
    pt1 = new Point(w * 3 / 2, h * 3 / 2).fromWindow().to(@puzzle.wrapper)
    @puzzle.wrapper.cache(pt0.x, pt0.y, pt1.x - pt0.x, pt1.y - pt0.y)
    last_point = new Point(event.clientX, event.clientY)
    $(window).on(
      mousemove: (e, ui) =>
        pt = new Point(e.clientX, e.clientY)
        @puzzle.wrapper.x += pt.x - last_point.x
        @puzzle.wrapper.y += pt.y - last_point.y
      
        last_point = pt;
        @puzzle.stage.invalidate();
        return
      mouseup: (e, ui) =>
        @puzzle.wrapper.uncache()
        @puzzle.stage.invalidate();
        $(window).off('mousemove mouseup')
        return
    )


@MouseController = MouseController
