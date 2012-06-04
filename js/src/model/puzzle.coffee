class Puzzle
  constructor: (canvas) ->
    @stage = new Stage(canvas)
    @image = null
    @sounds = null
    @cutter = null
    @pieces = []
    @rotation_tolerance = 24
    @translation_tolerance = 0
  
  initizlize: (@image, @cutter) ->
    #@stage.enableMouseOver()
    
    @background = new Shape()
    @background.graphics.beginFill(Graphics.getRGB(0,0,0))
    @background.graphics.rect(0, 0, screen.width, screen.height)
    @stage.addChild(@background)

    @pieces = @cutter.cut(@image)
    @translation_tolerance = @cutter.linear_measure / 8

    @wrapper = new Container()
    @stage.addChild(@wrapper)
    
    @container = new Container()
    @wrapper.addChild(@container)

    @activelayer = new Container()
    @stage.addChild(@activelayer)

    for p, i in @pieces
      p.id = i
      p.puzzle = this
      p.shape = new Shape()
      p.shape.piece = p
      p.draw()
      @container.addChild(p.shape)
    @shuffle()
    @fit()

    @foreground = new Container()
    @stage.addChild(@foreground)

    @stage.update()
    
    Command.onPost.push((cmd) =>
      if cmd instanceof MergeCommand
        @sounds?.merge?.play()
      return
    )

  tryMerge: (piece) ->
    for p in piece.getAdjacentPieces() when p.isWithinTolerance(piece)
      new MergeCommand(p, piece).commit()
      break
    return

  shuffle: ->
    s = Math.max(@image.width, @image.height) * 2
    for p in @pieces when p.isAlive()
      center = p.getCenter()
      center = p.shape.localToParent(center.x, center.y)
      new RotateCommand(p, center, Math.random() * 360).execute()
      vec = new Point(Math.random() * s, Math.random() * s)
      new TranslateCommand(p, vec.subtract(center)).execute()

  fit: ->
    rect = Rectangle.getEmpty()
    for p in @pieces when p.isAlive()
      for pt in p.getBoundary().getCornerPoints()
        rect.addPoint(pt1 = p.shape.localToParent(pt.x, pt.y))
    sx = window.innerWidth / rect.width
    sy = window.innerHeight / rect.height
    sc = Math.min(sx, sy)
    @container.scaleX = sc
    @container.scaleY = sc
    @container.x = -rect.x * sc + (window.innerWidth - sc * rect.width) / 2
    @container.y = -rect.y * sc + (window.innerHeight - sc * rect.height) / 2


@Puzzle = Puzzle
