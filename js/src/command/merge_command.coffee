class MergeCommand extends Command
  constructor: (@piece, @mergee) ->

  execute: ->
    @piece.addLoop(lp) for lp in @mergee.loops

    @mergee.merger = @piece
    @mergee.shape.parent.removeChild(@mergee.shape)
    @piece.draw()


@MergeCommand = MergeCommand
