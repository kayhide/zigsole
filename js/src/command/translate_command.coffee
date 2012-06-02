class TranslateCommand extends Command
  constructor: (@piece, @vector) ->

  execute: ->
    @piece.shape.x += @vector.x
    @piece.shape.y += @vector.y

  squash: (cmd) ->
    if (cmd instanceof TranslateCommand and
        cmd.piece == @piece)
      @vector = @vector.add(cmd.vector)
      true
    else
      false

  isTransformCommand: ->
    true


@TranslateCommand = TranslateCommand
