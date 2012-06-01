class TranslateCommand extends Command
  constructor: (@piece, @vector) ->

  execute: ->
    @piece.shape.x += @vector.x
    @piece.shape.y += @vector.y



@TranslateCommand = TranslateCommand
