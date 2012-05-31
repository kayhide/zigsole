class GridCutter extends Cutter
  constructor: ->
    @nx = 1
    @ny = 1

  cut: (image) ->
    super image

    @count = @nx * @ny
    w = Math.round(@width / @nx)
    h = Math.round(@height / @ny)
    pieces = new Array()
    @parity = 1
    for y in [0...@ny]
      @parity *= -1
      for x in [0...@nx]
        pt00 = new Point(x*w, y*h)
        pt01 = new Point(x*w, y*h + h)
        pt10 = new Point(x* w+ w, y*h)
        pt11 = new Point(x*w + w, y*h + h)
        shape = new Shape()
        shape.graphics.beginBitmapFill(image)
        @parity *= -1
        @draw_curve(shape.graphics,
          @connect_curves(
            [@create_curve(pt00, pt01, @parity),
             @create_curve(pt01, pt11, -@parity),
             @create_curve(pt11, pt10, @parity),
             @create_curve(pt10, pt00, -@parity)]))
        shape.boundary = [x*w, y*h, w, h]
#        shape.cache(shape.boundary...)
        pieces.push(shape)
    pieces

  draw_curve: (g, points) ->
    g.moveTo(points[0].x, points[0].y)
    #for pt in points[1..]
    #  g.lineTo(pt.x, pt.y)
    for pt, i in points[1..] by 3
      g.bezierCurveTo(points[i+1].x, points[i+1].y, points[i+2].x, points[i+2].y, points[i+3].x, points[i+3].y)

  connect_curves: (curves) ->
    points = []
    points.push curves[0][0]
    for pts in curves
      for pt in pts[1..]
        points.push pt
    points
  
  create_curve: (pt0, pt1, parity = 1) ->
    points = []
    points.push pt0
    v1 = pt1.subtract(pt0).scale(0.5)

    mtx = new Matrix2D()
    mtx.rotate(parity * Math.PI * 2 / 3)
    v2 = v1.apply(mtx)
    
    points.push pt0.add(v1.scale(0.2))
    points.push pt0.add(v1)
    points.push pt0.add(v1).add(v2.scale(0.5))
    points.push pt0.add(v1).add(v2)
    points.push pt0.add(v1.scale(2)).add(v2)
    points.push pt0.add(v1.scale(1.5)).add(v2.scale(0.5))
    points.push pt0.add(v1)
    points.push pt0.add(v1.scale(1.8))
    points.push pt1
    points


@GridCutter = GridCutter
