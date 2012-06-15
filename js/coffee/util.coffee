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

Point::isZero = ->
  @x == 0 and @y == 0

Rectangle.createEmpty = ->
  rect = new Rectangle()
  rect.empty = true
  rect

Rectangle::clear = ->
  @empty = true
  this

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

Rectangle::addRectangle = (rect) ->
  for pt in rect.getCornerPoints()
    @addPoint(pt)
  this

Rectangle::getTopLeft = -> new Point(@x, @y)

Rectangle::getTopRight = -> new Point(@x + @width, @y)

Rectangle::getBottomLeft = -> new Point(@x, @y + @height)

Rectangle::getBottomRight = -> new Point(@x + @width, @y + @height)

Rectangle::getCornerPoints = ->
  [@getTopLeft(), @getTopRight(), @getBottomLeft(), @getBottomRight()]

Rectangle::getCenter = ->
  new Point(@x + @width / 2, @y + @height / 2)

Rectangle::inflate = (offset) ->
  @x -= offset
  @y -= offset
  @width += offset * 2
  @height += offset * 2
  this

Point.boundary = (points) ->
  rect = Rectangle.createEmpty()
  for pt in points
    rect.addPoint(pt)
  rect

Point::toArray = -> [@x, @y]

Point::from = (obj) ->
  pt = @clone()
  pt.on = obj
  pt

Point::to = (obj) ->
  if @on?
    if @on.getStage() == obj.getStage()
      if @on_global?
        pt = obj.globalToLocal(@x, @y)
      else
        pt = @on.localToLocal(@x, @y, obj)
    else
      if @on_global?
        pt = @on.globalToWindow(@x, @y)
        pt = obj.windowToLocal(pt.x, pt.y)
      else
        pt = @on.localToWindow(@x, @y)
        pt = obj.windowToLocal(pt.x, pt.y)
  else if @on_window?
    pt = obj.windowToLocal(@x, @y)
  else
    pt = obj.globalToLocal(@x, @y)
  pt.on = obj
  pt.on_global = null
  pt.on_window = null
  pt

Point::toWindow = ->
  if @on?
    if @on_global?
      pt = @on.globalToWindow(@x, @y)
    else
      pt = @on.localToWindow(@x, @y)
  else
    pt = @clone()
  pt.on = null
  pt.on_global = null
  pt.on_window = true
  pt

Point::toGlobal = ->
  if @on? and !@on_window? and !@on_global?
    pt = @on.localToGlobal(@x, @y)
    pt.on_global = true
  else
    pt = @clone()
  pt.on_window = null
  pt

DisplayObject::remove = ->
  @parent?.removeChild(this)

DisplayObject::localToParent = (x, y) ->
  @localToLocal(x, y, @parent)

DisplayObject::copyTransform = (src) ->
  { @x, @y, @scaleX, @scaleY, @rotation } = src

DisplayObject::clearTransform = ->
  @setTransform()

DisplayObject::projectTo = (dst) ->
  pt0 = @localToWindow(0, 0)
  pt1 = dst.windowToLocal(pt0.x, pt0.y)
  { @x, @y } = pt1
  dst.addChild(this)

DisplayObject::localToWindow = (x, y) ->
  pt0 = $(@getStage().canvas).position()
  pt = @localToGlobal(x, y)
  pt.x += pt0.left
  pt.y += pt0.top
  pt

DisplayObject::windowToLocal = (x, y) ->
  pt0 = $(@getStage().canvas).position()
  pt = @globalToLocal(x - pt0.left, y - pt0.top)
  pt

DisplayObject::globalToWindow = (x, y) ->
  pt0 = $(@getStage().canvas).position()
  new Point(x + pt0.left, y + pt0.top)

DisplayObject::windowToGlobal = (x, y) ->
  pt0 = $(@getStage().canvas).position()
  new Point(x - pt0.left, y - pt0.top)

Stage::invalidate = ->
  @invalidated = true

