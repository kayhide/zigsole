class Cutter
  constructor: ->
    @nx = 1
    @ny = 1
    @width = 1
    @height = 1
    @fluctuation = 0
    @irregularity = 0

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
        pt0 = x: x*w, y: y*h
        pt1 = x: x*w + w, y: y*h + h
        shape = new Shape()
        shape.graphics.beginBitmapFill(image)
        .moveTo(pt0.x, pt0.y)
        .lineTo(pt0.x + Math.random()*w*0.3, pt1.y - Math.random()*w*0.3)
        .lineTo(pt1.x - Math.random()*w*0.3, pt1.y - Math.random()*w*0.3)
        .lineTo(pt1.x - Math.random()*w*0.3, pt0.y + Math.random()*w*0.3)
        .lineTo(pt0.x, pt0.y)
        shape.boundary = [x*w, y*h, w, h]
        shape.cache(shape.boundary...)
        pieces.push(shape)
    pieces


@Cutter = Cutter
