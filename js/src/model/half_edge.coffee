class HalfEdge
  @create: ->
    he = new HalfEdge()
    he.mate = new HalfEdge()
    he.mate.mate = he
    he.next = he.mate
    he.mate.next = he
    he

  @createLoop: (count) ->
    head = HalfEdge.create()
    he = head
    for i in [1...count]
      next = HalfEdge.create()
      he.setNext(next)
      he = next
    he.setNext(head)
    head

  @next_id = 1
  
  constructor: ->
    @point = new Point()
    @next = null
    @mate = null
    @curve = null
    @facet = null
    @eid = HalfEdge.next_id
    ++HalfEdge.next_id

  prev: ->
    he = @mate
    while he.next != this
      he = he.next.mate
    he
    
  setPoint: (pt) ->
    @point = pt
    he = this.mate.next
    while he != this
      he.point = pt
      he = he.mate.next

  setNext: (he) ->
    @next = he
    he.mate.next = @mate

  setMate: (he) ->
    if @mate == he
      return
    if @mate.prev() != he.prev()
      @mate.prev().next = he.mate.next
    if he.mate.prev() != @prev()
      he.mate.prev().next = @mate.next
    @mate = he
    he.mate = this

  getLoopEdges: ->
    edges = [this]
    he = this.next
    while he != this
      edges.push(he)
      he = he.next
    edges

  setCurve: (c) ->
    @curve = c
    @mate.curve = (c[i] for i in [(c.length - 1)..0])

  isSolitary: ->
    @next == @mate and @next.mate == this

  weld: ->
    @prev().next = @mate.next
    @mate.prev().next = @next
    @next = @mate
    @mate.next = this


@HalfEdge = HalfEdge
