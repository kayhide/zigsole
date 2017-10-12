class RotateCommand extends TransformCommand
  constructor: (@piece, @center, @degree) ->
    mtx = new Matrix2D()
    mtx.translate(-@center.x, -@center.y)
    mtx.rotate(Math.PI * @degree / 180)
    mtx.translate(@center.x, @center.y)
    @position = @piece.position().apply(mtx)
    @rotation = @piece.rotation() + @degree

  squash: (cmd) ->
    if (cmd instanceof RotateCommand and
        cmd.piece == @piece and
        cmd.center == @center)
      @degree += cmd.degree
      { @position, @rotation } = cmd
      true
    else
      false

  isValid: ->
    @piece?.isAlive() and @center?


@RotateCommand = RotateCommand
