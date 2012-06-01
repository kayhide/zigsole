class Loop
  @create: (count = 1) ->
    head = HalfEdge.create()
    he = head
    for i in [1...count]
      next = HalfEdge.create()
      he.setNext(next)
      he = next
    he.setNext(head)
    new Loop(head)

  constructor: (@edge) ->
    for he in @getEdges()
      he.loop = this

  getEdges: ->
    edges = [@edge]
    he = @edge.next
    while he != @edge
      edges.push(he)
      he = he.next
    edges

  getCurve: ->
    curves = (he.curve for he in @getEdges())
    @connectCurves(curves)

  connectCurves: (curves) ->
    points = []
    points.push curves[0][0]
    for pts in curves
      for pt in pts[1..]
        points.push pt
    points

@Loop = Loop
