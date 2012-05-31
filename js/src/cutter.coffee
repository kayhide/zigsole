class Cutter
  constructor: ->
    @count = 1
    @width = 1
    @height = 1
    @fluctuation = 0
    @irregularity = 0

  cut: (image) ->
    @width = image.width
    @height = image.height
    return

  getBoundary: (points) ->
    if points.length == 0
      null
    else
      pt0 = points[0].clone()
      pt1 = points[0].clone()
      for pt in points[1..]
        pt0.x = pt.x if pt.x < pt0.x
        pt0.y = pt.y if pt.y < pt0.y
        pt1.x = pt.x if pt.x > pt1.x
        pt1.y = pt.y if pt.y > pt1.y
      [pt0.x, pt0.y, pt1.x - pt0.x, pt1.y - pt0.y]

@Cutter = Cutter
