class TransformCommand extends Command
  execute: ->
    @piece
    .position(@position)
    .rotation(@rotation)

@TransformCommand = TransformCommand
