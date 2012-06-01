class RotateCommand extends Command
  constructor: (@piece, @center, @degree) ->

  execute: ->
    mtx = new Matrix2D()
    mtx.rotate Math.PI * @degree / 180
    local_center = new Point(@center.x - @piece.shape.x, @center.y - @piece.shape.y)
    pos = local_center.apply(mtx)
    vec = pos.subtract(local_center)
    @piece.shape.rotation += @degree
    @piece.shape.x -= vec.x
    @piece.shape.y -= vec.y



@RotateCommand = RotateCommand
