class Piece
  constructor: ->
    @puzzle = null
    @edge = null
    @shape = null
    @draws_stroke = true
    @draws_control_line = false
    @draws_boundary = true
    @draws_center = true

  setEdge: (@edge) ->
    for he in @edge.getLoopEdges()
      he.piece = this

  getLoopCurve: ->
    curves = (e.curve for e in @edge.getLoopEdges())
    @connectCurves(curves)

  getBoundary: (points = null) ->
    unless @boundary?
      points = @getLoopCurve() unless points?
      pt0 = points[0].clone()
      pt1 = points[0].clone()
      for pt in points[1..] when pt?
        pt0.x = pt.x if pt.x < pt0.x
        pt0.y = pt.y if pt.y < pt0.y
        pt1.x = pt.x if pt.x > pt1.x
        pt1.y = pt.y if pt.y > pt1.y
      @boundary = [pt0.x, pt0.y, pt1.x - pt0.x, pt1.y - pt0.y]
    @boundary

  getCenter: ->
    boundary = @getBoundary()
    new Point(boundary[0] + boundary[2] / 2, boundary[1] + boundary[3] / 2)
    
  draw: ->
    @shape.uncache()
    @boundary = null
    g = @shape.graphics
    g.clear()
    g.beginBitmapFill(@puzzle.image)
    g.beginStroke(2) if @draws_stroke
    loop_curve = @getLoopCurve()
    @drawCurve(loop_curve)
    g.endFill().endStroke()
    boundary = @getBoundary(loop_curve)
    if @draws_boundary
      g.beginStroke(1).rect(boundary...)
    if @draws_control_line
      g.beginStroke(1)
      @drawPolyline(loop_curve)
    if @draws_center
      center = @getCenter()
      g.beginStroke(2).drawCircle(center.x, center.y, 4)
    @shape.cache(boundary[0] - 1, boundary[1] - 1, boundary[2] + 2, boundary[3] + 2)
  
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
