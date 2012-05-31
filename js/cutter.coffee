class Cutter
  constructor: ->
    @nx = 1
    @ny = 1
    @width = 1
    @height = 1

  count: ->
    @nx * @ny

  cut: (image) ->
    @width = image.width
    @height = image.height
    w = Math.round(@width / @nx)
    h = Math.round(@height / @ny)
    pieces = new Array()
    for y in [0...@ny]
      for x in [0...@nx]
        shape = new Shape()
        shape.graphics.beginBitmapFill(image)
        shape.graphics.drawRoundRect(x*w, y*h, w, h, w*0.2)
        shape.boundary = [x*w, y*h, w, h]
        shape.cache(shape.boundary...)
        pieces.push(shape)
    pieces


@Cutter = Cutter
