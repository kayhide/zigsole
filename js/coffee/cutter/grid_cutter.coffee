class GridCutter extends Cutter
  constructor: ->
    super
    @nx = 1
    @ny = 1

  cut: ->
    @count = @nx * @ny
    w = Math.round(@width / @nx)
    h = Math.round(@height / @ny)
    @linear_measure = Math.sqrt(w * w + h * h)

    pcs = @create_pieces()
    @create_points pcs
    @create_curves pcs

    pieces = new Array()
    for y in [0...@ny]
      for x in [0...@nx]
        pieces.push(pcs[y][x])
    pieces

  create_pieces: ->
    pcs = []
    for y in [0...@ny]
      pcs.push []
      for x in [0...@nx]
        p = new Piece()
        lp = Loop.create(4)
        p.addLoop(lp)
        pcs[y].push p

    for y in [0...@ny]
      for x in [0...@nx]
        if x < @nx - 1
          pcs[y][x].loops[0].edge.next.next.setMate(pcs[y][x + 1].loops[0].edge)
        if y > 0
          pcs[y][x].loops[0].edge.next.next.next.setMate(pcs[y - 1][x].loops[0].edge.next)
        if x > 0
          pcs[y][x].loops[0].edge.setMate(pcs[y][x - 1].loops[0].edge.next.next)
        if y < @ny - 1
          pcs[y][x].loops[0].edge.next.setMate(pcs[y + 1][x].loops[0].edge.next.next.next)
    pcs

  create_points: (pcs) ->
    w = Math.round(@width / @nx)
    h = Math.round(@height / @ny)
    for y in [0..@ny]
      for x in [0..@nx]
        vec = new Point(w, h).scale(@fluctuation * 0.5 * (Math.random() * 2 - 1))
        vec.x = 0 if x == 0 or x == @nx
        vec.y = 0 if y == 0 or y == @ny
        pos = new Point(x * w, y * h).add(vec)

        if x == 0 and y == 0
          pcs[y][x].loops[0].edge.setPoint(pos)
        else if x == 0
          pcs[y - 1][x].loops[0].edge.next.setPoint(pos)
        else if y == 0
          pcs[y][x - 1].loops[0].edge.next.next.next.setPoint(pos)
        else
          pcs[y - 1][x - 1].loops[0].edge.next.next.setPoint(pos)
    return

  create_curves: (pcs) ->
    parity = 1
    for y in [0...@ny]
      parity *= -1
      for x in [0...@nx]
        parity *= -1
        for he in pcs[y][x].loops[0].getEdges()
          parity *= -1
          p = if Math.random() < @irregularity
            parity
          else
            -parity
          unless he.curve?
            he.setCurve @create_curve(he, p)
    return


@GridCutter = GridCutter
