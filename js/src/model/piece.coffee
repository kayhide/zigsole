class Piece
  constructor: ->
    @puzzle = null
    @loops = []
    @shape = null
    @draws_stroke = false
    @draws_control_line = false
    @draws_boundary = false
    @draws_center = false

  addLoop: (lp) ->
    @loops.push lp

  removeLoop: (lp) ->
    @loops = (l for l in @loops when l != lp)
 
  getBoundary: ->
    unless @boundary?
      points = []
      points = points.concat(lp.getCurve()) for lp in @loops
      if points.length > 0
        pt0 = points[0].clone()
        pt1 = points[0].clone()
        for pt in points[1..] when pt?
          pt0.x = pt.x if pt.x < pt0.x
          pt0.y = pt.y if pt.y < pt0.y
          pt1.x = pt.x if pt.x > pt1.x
          pt1.y = pt.y if pt.y > pt1.y
        @boundary = [pt0.x, pt0.y, pt1.x - pt0.x, pt1.y - pt0.y]
      else
        @boundary = [0, 0, 0, 0]
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
    for lp in @loops
      @drawCurve(lp.getCurve())
    g.endFill().endStroke()
    boundary = @getBoundary()
    if @draws_boundary
      g.beginStroke(1).rect(boundary...)
    if @draws_control_line
      g.beginStroke(1)
      for lp in @loops
        @drawPolyline(lp.getCurve())
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



@Piece = Piece
