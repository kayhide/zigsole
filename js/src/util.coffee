Point::add = (p) ->
  new Point(@x + p.x, @y + p.y)

Point::subtract = (p) ->
  new Point(@x - p.x, @y - p.y)

Point::scale = (d) ->
  new Point(@x * d, @y * d)

Point::apply = (mtx) ->
  mtx = mtx.clone()
  mtx.append(1, 0, 0, 1, @x, @y)
  new Point(mtx.tx, mtx.ty)

Point::distanceTo = (pt) ->
  Math.sqrt(Math.pow(pt.x - @x, 2) + Math.pow(pt.y - @y, 2))


DisplayObject::localToParent = (x, y) ->
  @localToLocal(x, y, @parent)
