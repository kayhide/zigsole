class StandardGridCutter extends GridCutter
  create_curve: (he, parity = 1) ->
    pt0 = he.point
    pt1 = he.next.point
    v1 = pt1.subtract(pt0).scale(0.5)

    mtx = new Matrix2D()
    mtx.rotate(parity * Math.PI * 2 / 3)
    v2 = v1.apply(mtx)

    points = []
    points.push pt0
    if he.mate.piece?
      points.push pt0.add(v1.scale(0.2))
      points.push pt0.add(v1)
      points.push pt0.add(v1).add(v2.scale(0.5))
      points.push pt0.add(v1).add(v2)
      points.push pt0.add(v1.scale(2)).add(v2)
      points.push pt0.add(v1.scale(1.5)).add(v2.scale(0.5))
      points.push pt0.add(v1)
      points.push pt0.add(v1.scale(1.8))
      points.push pt1
    else
      points.push null
      points.push null
      points.push pt1
    points


@StandardGridCutter = StandardGridCutter
