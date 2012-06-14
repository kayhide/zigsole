class RotateCommand extends TransformCommand
  constructor: (@piece, @center, @degree) ->
    mtx = new Matrix2D()
    mtx.rotate(Math.PI * @degree / 180)
    v0 = @center.subtract(@piece.position)
    v1 = v0.apply(mtx)
    @position = @piece.position.subtract(v1.subtract(v0))
    @rotation = @piece.rotation + @degree

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
