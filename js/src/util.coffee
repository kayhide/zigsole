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

Rectangle.getEmpty = ->
  rect = new Rectangle()
  rect.empty = true
  rect

Rectangle::clear = ->
  @empty = true

Rectangle::isEmpty = ->
  @empty?

Rectangle::addPoint = (pt) ->
  if @empty?
    @x = pt.x
    @y = pt.y
    @width = 0
    @height = 0
    @empty = null
    @points = [pt]
  else
    @points.push(pt)
    if pt.x < @x
      @width += @x - pt.x
      @x = pt.x
    else if pt.x > @x + @width
      @width = pt.x - @x
    if pt.y < @y
      @height += @y - pt.y
      @y = pt.y
    else if pt.y > @y + @height
      @height = pt.y - @y
  this

Point.boundary = (points) ->
  if points.length > 0
    pt0 = points[0].clone()
    pt1 = points[0].clone()
    for pt in points[1..] when pt?
      pt0.x = pt.x if pt.x < pt0.x
      pt0.y = pt.y if pt.y < pt0.y
      pt1.x = pt.x if pt.x > pt1.x
      pt1.y = pt.y if pt.y > pt1.y
    [pt0.x, pt0.y, pt1.x - pt0.x, pt1.y - pt0.y]
  else
    [0, 0, 0, 0]

Array::getTopLeft = -> new Point(@[0], @[1])

Array::getTopRight = -> new Point(@[0] + @[2], @[1])

Array::getBottomLeft = -> new Point(@[0], @[1] + @[3])

Array::getBottomRight = -> new Point(@[0] + @[2], @[1] + @[3])

Array::getCornerPoints = ->
  [@getTopLeft(), @getTopRight(), @getBottomLeft(), @getBottomRight()]

DisplayObject::localToParent = (x, y) ->
  @localToLocal(x, y, @parent)

DisplayObject::copyTransform = (src) ->
  @x = src.x
  @y = src.y
  @scaleX = src.scaleX
  @scaleY = src.scaleY
