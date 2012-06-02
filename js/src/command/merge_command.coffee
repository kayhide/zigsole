class MergeCommand extends Command
  constructor: (@piece, @mergee) ->

  execute: ->
    @piece = @piece.getEntity()
    @piece.addLoop(lp) for lp in @mergee.loops

    @mergee.merger = @piece
    @mergee.shape.parent.removeChild(@mergee.shape)
    @piece.draw()

  isValid: ->
    @mergee?.isAlive()


@MergeCommand = MergeCommand
