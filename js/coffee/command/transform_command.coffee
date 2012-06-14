class TransformCommand extends Command
  execute: ->
    @piece.position = @position
    @piece.rotation = @rotation

@TransformCommand = TransformCommand
