class Piece
  constructor: ->
    @edge = null
    @shape = null
    @draws_stroke = false
    @draws_control_line = false
    @draws_boundary = false

  setEdge: (@edge) ->
    for he in @edge.getLoopEdges()
      he.piece = this

  getLoopCurve: ->
    curves = (e.curve for e in @edge.getLoopEdges())
    loop_curve = @connectCurves(curves)

  getBoundary: (points) ->
    if points.length == 0
      null
    else
      pt0 = points[0].clone()
      pt1 = points[0].clone()
      for pt in points[1..] when pt?
        pt0.x = pt.x if pt.x < pt0.x
        pt0.y = pt.y if pt.y < pt0.y
        pt1.x = pt.x if pt.x > pt1.x
        pt1.y = pt.y if pt.y > pt1.y
      [pt0.x, pt0.y, pt1.x - pt0.x, pt1.y - pt0.y]
    
  draw: (image) ->
    g = @shape.graphics
    g.beginBitmapFill(image)
    g.beginStroke(2) if @draws_stroke
    loop_curve = @getLoopCurve()
    @drawCurve(loop_curve)
    g.endFill().endStroke()
    if @draws_control_line
      g.beginStroke(1)
      @drawPolyline(loop_curve)
    @boundary = @getBoundary(loop_curve)
    g.beginStroke(1).rect(@boundary...) if @draws_boundary
    @shape.cache(@boundary[0], @boundary[1], @boundary[2] + 1, @boundary[3] + 1)
  
  drawCurve: (points) ->
    g = @shape.graphics
    g.moveTo(points[0].x, points[0].y)
    for pt, i in points[1..] by 3
      if points[i+1]? and points[i+2]?
        g.bezierCurveTo(points[i+1].x, points[i+1].y, points[i+2].x, points[i+2].y, points[i+3].x, points[i+3].y)
      else
        g.lineTo(points[i+3].x, points[i+3].y)

  drawPolyline: (points) ->
    g = @shape.graphics
    g.moveTo(points[0].x, points[0].y)
    for pt in points[1..] when pt?
      g.lineTo(pt.x, pt.y)

  connectCurves: (curves) ->
    points = []
    points.push curves[0][0]
    for pts in curves
      for pt in pts[1..]
        points.push pt
    points



@Piece = Piece
