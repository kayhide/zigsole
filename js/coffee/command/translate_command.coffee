class TranslateCommand extends TransformCommand
  constructor: (@piece, @vector) ->
    @position = @piece.position.add(@vector)
    @rotation = @piece.rotation

  squash: (cmd) ->
    if (cmd instanceof TranslateCommand and
        cmd.piece == @piece)
      @vector = @vector.add(cmd.vector)
      { @position, @rotation } = cmd
      true
    else
      false

  isValid: ->
    @piece?.isAlive()


@TranslateCommand = TranslateCommand
