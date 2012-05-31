class GridCutter extends Cutter
  constructor: ->
    super
    @nx = 1
    @ny = 1

  cut: (image) ->
    super image
    
    @count = @nx * @ny
    w = Math.round(@width / @nx)
    h = Math.round(@height / @ny)

    edges = @create_edges()
    @create_points edges

    parity = 1
    for y in [0...@ny]
      parity *= -1
      for x in [0...@nx]
        parity *= -1
        for he in edges[y][x].getLoopEdges()
          parity *= -1
          p = if Math.random() < @irregularity
            parity
          else
            -parity
          unless he.curve?
            he.setCurve @create_curve(he, p)

    pieces = new Array()
    for y in [0...@ny]
      for x in [0...@nx]
        he = edges[y][x]
        curves = (e.curve for e in he.getLoopEdges())
        shape = he.facet
        shape.graphics.beginBitmapFill(image).beginStroke(2)
        loop_curve = @connect_curves(curves)
        @draw_curve(shape.graphics, loop_curve)
        shape.boundary = @getBoundary(loop_curve)
#        shape.graphics.rect(shape.boundary...)
        shape.cache(shape.boundary...)
        pieces.push(shape)
    pieces

  create_edges: ->
    edges = []
    for y in [0...@ny]
      edges.push []
      for x in [0...@nx]
        he = HalfEdge.createLoop(4)
        he.setFacet(new Shape())
        edges[y].push he

    for y in [0...@ny]
      for x in [0...@nx]
        if x < @nx - 1
          edges[y][x].next.next.setMate(edges[y][x + 1])
        if y > 0
          edges[y][x].next.next.next.setMate(edges[y - 1][x].next)
        if x > 0
          edges[y][x].setMate(edges[y][x - 1].next.next)
        if y < @ny - 1
          edges[y][x].next.setMate(edges[y + 1][x].next.next.next)
    edges

  create_points: (edges) ->
    w = Math.round(@width / @nx)
    h = Math.round(@height / @ny)
    for y in [0..@ny]
      for x in [0..@nx]
        vec = new Point(w, h).scale(@fluctuation * 0.5)
        vec.x = if x == 0 or x == @nx
          0
        else
          vec.x * (Math.random() * 2 - 1)
        vec.y = if y == 0 or y == @ny
          0
        else
          vec.y * (Math.random() * 2 - 1)
        pos = new Point(x * w, y * h).add(vec)

        if x == 0 and y == 0
          edges[y][x].setPoint(pos)
        else if x == 0
          edges[y - 1][x].next.setPoint(pos)
        else if y == 0
          edges[y][x - 1].next.next.next.setPoint(pos)
        else
          edges[y - 1][x - 1].next.next.setPoint(pos)
    return

  draw_curve: (g, points) ->
    g.moveTo(points[0].x, points[0].y)
    #for pt in points[1..]
    #  g.lineTo(pt.x, pt.y)
    for pt, i in points[1..] by 3
      if points[i+2]?
        g.bezierCurveTo(points[i+1].x, points[i+1].y, points[i+2].x, points[i+2].y, points[i+3].x, points[i+3].y)
      else
        g.lineTo(points[i+1].x, points[i+1].y, points[i+3].x, points[i+3].y)

  connect_curves: (curves) ->
    points = []
    points.push curves[0][0]
    for pts in curves
      for pt in pts[1..]
        points.push pt
    points


@GridCutter = GridCutter
