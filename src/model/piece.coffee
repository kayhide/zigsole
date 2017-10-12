class Piece
  constructor: ->
    @puzzle = null
    @loops = []
    @shape = null
    @merger = null
    @_position = new Point()
    @_rotation = 0
    @draws_image = true
    @draws_stroke = false
    @draws_control_line = false
    @draws_boundary = false
    @draws_center = false

  position: (pt) ->
    if pt?
      @_position = pt
      @boundary = null
      this
    else
      @_position

  rotation: (deg) ->
    if deg?
      @_rotation = deg
      @boundary = null
      this
    else
      @_rotation

  matrix: (pt) ->
    mtx = new Matrix2D()
    mtx.rotate(Math.PI * @_rotation / 180)
    mtx.translate(@_position.x, @_position.y)
    mtx

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
      mtx = @matrix()
      for he in @getEdges() when he.mate.loop?.piece == target
        pt = he.getCenter()
        pt0 = pt.apply(mtx)
        pt1 = pt.apply(target.matrix())
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

  getLocalPoints: ->
    points = []
    for lp in @loops
      for pt in lp.getCurve() when pt?
        points.push(pt)
    points

  getLocalBoundary: ->
    Point.boundary(@getLocalPoints())

  getPoints: ->
    mtx = @matrix()
    points = @getLocalPoints()
    (pt.apply(mtx) for pt in points)

  getBoundary: ->
    unless @boundary? and false
      @boundary = Point.boundary(@getPoints())
    @boundary

  getCenter: ->
    @getBoundary().getCenter()

  draw: ->
    @shape.uncache()
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
    boundary = @getLocalBoundary()
    if @draws_boundary
      g.setStrokeStyle(2).beginStroke("#0f0")
      .rect(boundary.x, boundary.y, boundary.width, boundary.height)
    if @draws_control_line
      g.setStrokeStyle(2).beginStroke("#fff")
      for lp in @loops
        @drawPolyline(lp.getCurve())
    if @draws_center
      center = boundary.getCenter()
      g.setStrokeStyle(2).beginFill("#390")
      .drawCircle(center.x, center.y, @puzzle.cutter.linear_measure / 32)

  cache: (padding = 0) ->
    boundary = @getLocalBoundary()
    @shape.cache(boundary.x - padding, boundary.y - padding, boundary.width + padding * 2, boundary.height + padding * 2)

  uncache: ->
    @shape.uncache()

  enbox: ->
    @inner_shape = @shape
    @shape = new Container()
    @shape.copyTransform(@inner_shape)
    @inner_shape.clearTransform()
    @inner_shape.parent.addChild(@shape)
    @shape.addChild(@inner_shape)
    boundary = @getLocalBoundary()

  unbox: ->
    if @inner_shape?
      @inner_shape.copyTransform(@shape)
      @shape.parent.addChild(@inner_shape)
      @shape.remove()
      @shape = @inner_shape
      @inner_shape = null

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
