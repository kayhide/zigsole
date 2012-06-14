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
    @background.color = "#002"
    @background.alpha = 0.9
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

    @foreground = new Container()
    @stage.addChild(@foreground)

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

  getBoundary: ->
    rect = Rectangle.createEmpty()
    for p in @pieces when p.isAlive()
      rect.addRectangle(p.getBoundary())
    rect

  shuffle: ->
    s = Math.max(@image.width, @image.height) * 2
    for p in @pieces when p.isAlive()
      center = p.getCenter()
      center = p.shape.localToParent(center.x, center.y)
      new RotateCommand(p, center, Math.random() * 360).post()
      vec = new Point(Math.random() * s, Math.random() * s)
      new TranslateCommand(p, vec.subtract(center)).post()

  centerize: ->
    rect = @getBoundary()
    { scaleX: sx, scaleY: sy } = @container
    @container.x = -rect.x * sx + (window.innerWidth - sx * rect.width) / 2
    @container.y = -rect.y * sy + (window.innerHeight - sy * rect.height) / 2
    @stage.update()

  fit: ->
    rect = @getBoundary()
    sx = window.innerWidth / rect.width
    sy = window.innerHeight / rect.height
    sc = Math.min(sx, sy)
    @container.scaleX = sc
    @container.scaleY = sc
    @container.x = -rect.x * sc + (window.innerWidth - sc * rect.width) / 2
    @container.y = -rect.y * sc + (window.innerHeight - sc * rect.height) / 2
    @stage.update()

  fill: ->
    rect = @getBoundary()
    sx = window.innerWidth / rect.width
    sy = window.innerHeight / rect.height
    sc = Math.max(sx, sy)
    @container.scaleX = sc
    @container.scaleY = sc
    @container.x = -rect.x * sc + (window.innerWidth - sc * rect.width) / 2
    @container.y = -rect.y * sc + (window.innerHeight - sc * rect.height) / 2
    @stage.update()

  zoom: (x, y, scale) ->
    @container.scaleX = @container.scaleX * scale
    @container.scaleY = @container.scaleX
    @container.x = x - (x - @container.x) * scale
    @container.y = y - (y - @container.y) * scale
    @stage.update()

  invalidate: ->
    @invalidated = true


@Puzzle = Puzzle
