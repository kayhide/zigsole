Point.prototype.add = (p) ->
  new Point(@x + p.x, @y + p.y)

Point.prototype.subtract = (p) ->
  new Point(@x - p.x, @y - p.y)

Point.prototype.scale = (d) ->
  new Point(@x * d, @y * d)

Point.prototype.apply = (mtx) ->
  mtx = mtx.clone()
  mtx.append(1, 0, 0, 1, @x, @y)
  new Point(mtx.tx, mtx.ty)

Point.prototype.distanceTo = (pt) ->
  Math.sqrt(Math.pow(pt.x - @x, 2) + Math.pow(pt.y - @y, 2))
