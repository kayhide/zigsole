class Cutter
  constructor: ->
    @count = 1
    @width = 1
    @height = 1
    @fluctuation = 0
    @irregularity = 0

  cut: (image) ->
    @width = image.width
    @height = image.height
    return


@Cutter = Cutter
