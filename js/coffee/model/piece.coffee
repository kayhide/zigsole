class Piece
  constructor: ->
    @puzzle = null
    @loops = []
    @shape = null
    @merger = null
    @draws_image = true
    @draws_stroke = false
    @draws_control_line = false
    @draws_boundary = false
    @draws_center = false

  addLoop: (lp) ->
    @loops.push(lp)
    lp.piece.removeLoop(lp) if lp.piece?
    lp.piece = this

  removeLoop: (lp) ->
    @loops = (l for l in @loops when l != lp)

  getEntity: ->
    if @merger?
      @getMerger()
    else
      this

  getMerger: ->
    merger = @merger
    while merger?.merger?
      merger = merger.merger
    merger

  isAlive: ->
    !@merger?
    
  isWithinTolerance: (target) ->
    if Math.abs(@getDegreeTo(target)) < @puzzle.rotation_tolerance
      for he in @getEdges() when he.mate.loop?.piece == target
        pt = he.getCenter()
        pt0 = @shape.localToParent(pt.x, pt.y)
        pt1 = target.shape.localToParent(pt.x, pt.y)
        if pt0.distanceTo(pt1) < @puzzle.translation_tolerance
          return true
    return false

  getDegreeTo: (target) ->
    deg = (target.shape.rotation - @shape.rotation) % 360
    if deg > 180
      deg - 360
    else if deg <= -180
      deg + 360
    else
      deg

  getEdges: ->
    edges = []
    for lp in @loops
      for he in lp.getEdges()
        edges.push(he)
    edges

  getAdjacentPieces: ->
    pieces = {}
    for he in @getEdges() when he.mate.loop?
      p = he.mate.loop.piece.getEntity()
      pieces[p.id] = p
    (value for key, value of pieces when value != this)

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
    if @draws_image
      g.beginBitmapFill(@puzzle.image)
    else
      g.beginFill("#9fa")
    if @draws_stroke
      g.setStrokeStyle(2).beginStroke("#f0f")
    for lp in @loops
      @drawCurve(lp.getCurve())
    g.endFill().endStroke()
    boundary = @getBoundary()
    if @draws_boundary
      g.setStrokeStyle(2).beginStroke("#0f0").rect(boundary...)
    if @draws_control_line
      g.setStrokeStyle(2).beginStroke("#fff")
      for lp in @loops
        @drawPolyline(lp.getCurve())
    if @draws_center
      center = @getCenter()
      g.beginStroke(2).drawCircle(center.x, center.y, 4)

  cache: ->
    boundary = @getBoundary()
    @shape.cache(boundary[0] - 10, boundary[1] - 10, boundary[2] + 20, boundary[3] + 20)

  uncache: ->
    @shape.uncache()

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
