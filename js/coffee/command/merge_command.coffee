class MergeCommand extends Command
  constructor: (@piece, @mergee) ->
    @piece = @piece.getEntity()

  execute: ->
    @piece.addLoop(lp) for lp in @mergee.loops

    @mergee.merger = @piece
    @piece.draw()

  isValid: ->
    @mergee?.isAlive() and @piece != @mergee


@MergeCommand = MergeCommand
