class Puzzle
  constructor: (canvas) ->
    @stage = new Stage(canvas)
    @image = null
    @sounds = null
    @cutter = null
    @pieces = []
    @rotation_tolerance = 10
    @translation_tolerance = 0
  
  initizlize: (@image, @cutter) ->
    #@stage.enableMouseOver()
    
    @background = new Shape()
    @background.graphics.beginFill(Graphics.getRGB(0,0,0))
    @background.graphics.rect(0, 0, screen.width, screen.height)
    @stage.addChild(@background)

    @pieces = @cutter.cut(@image)
    @translation_tolerance = @cutter.linear_measure / 16

    @container = new Container()
    @stage.addChild(@container)

    for p, i in @pieces
      p.id = i
      p.puzzle = this
      p.shape = new Shape()
      p.shape.piece = p
      p.draw()
      @container.addChild(p.shape)

    @foreground = new Container()
    @stage.addChild(@foreground)

    @stage.update()
    
    Command.onPost.push((cmd) =>
      @stage.update()
      return
    )
    
    Command.onCommit.push((cmds) =>
      for cmd in cmds when cmd.isTransformCommand()
        @tryMerge(cmd.piece)
      for cmd in cmds when cmd instanceof MergeCommand
        mergee = cmd.mergee
        @container.removeChild(mergee.shape)
        @stage.update()
        @sounds?.merge?.play()
        break
      return
    )

  tryMerge: (piece) ->
    for p in piece.getAdjacentPieces() when p.isWithinTolerance(piece)
      new MergeCommand(p, piece).commit()
      break
    return


@Puzzle = Puzzle
