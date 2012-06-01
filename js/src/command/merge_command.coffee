class MergeCommand extends Command
  constructor: (@piece, @mergee) ->

  execute: ->
    edges = @piece.edge.getLoopEdges()
    for he in edges when he.mate.piece == @mergee
      he.weld()
    if @piece.edge.isSolitary()
      @piece.edge = null
      for he in edges when !he.isSolitary()
        @piece.setEdge(he)
        break

    @mergee.shape.parent.removeChild(@mergee.shape)
    @piece.draw()


@MergeCommand = MergeCommand
