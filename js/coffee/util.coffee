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


Point.boundary = (points) ->
  rect = Rectangle.createEmpty()
  for pt in points
    rect.addPoint(pt)
  rect

Point::toArray = -> [@x, @y]


DisplayObject::remove = ->
  @parent?.removeChild(this)

DisplayObject::localToParent = (x, y) ->
  @localToLocal(x, y, @parent)

DisplayObject::copyTransform = (src) ->
  @x = src.x
  @y = src.y
  @scaleX = src.scaleX
  @scaleY = src.scaleY
  @rotation = src.rotation

DisplayObject::clearTransform = ->
  @setTransform()

DisplayObject::projectTo = (dst) ->
  pt0 = @localToWindow(@x, @y)
  pt1 = dst.windowToLocal(pt0.x, pt0.y)
  @x = pt1.x
  @y = pt1.y
  dst.addChild(this)

DisplayObject::localToWindow = (x, y) ->
  pt = @localToGlobal(x, y)
  pt0 = $(@getStage().canvas).position()
  pt.x += pt0.left
  pt.y += pt0.top
  pt

DisplayObject::windowToLocal = (x, y) ->
  pt = @globalToLocal(x, y)
  pt0 = $(@getStage().canvas).position()
  pt.x -= pt0.left
  pt.y -= pt0.top
  pt


$.fn.extend({
  rotation: (val) ->
    if val?
      return this.each( ->
        $(this).css({
          '-webkit-transform': "rotate(#{val}deg)"
          '-moz-transform': "rotate(#{val}deg)"
          '-ms-transform': "rotate(#{val}deg)"
          '-o-transform': "rotate(#{val}deg)"
          'transform': "rotate(#{val}deg)"
        })
      )
    else
      null
})


