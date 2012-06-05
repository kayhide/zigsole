class BrowserController
  constructor: (@puzzle) ->
  
  attach: ->
    $('body')
    .css('background-color', '#000')
    .css('overflow', 'hidden')
    $(window).on('resize', ->
      @puzzle.stage.canvas.width = window.innerWidth
      @puzzle.stage.canvas.height = window.innerHeight
      if (window.innerWidth > @puzzle.background.width * 0.8 or
          window.innerHeight > @puzzle.background.height * 0.8)
        @puzzle.background.width = window.innerWidth * 2
        @puzzle.background.height = window.innerHeight * 2
      @puzzle.background.graphics
      .clear()
      .beginFill(@puzzle.background.color)
      .rect(0, 0, @puzzle.background.width, @puzzle.background.height)
      @puzzle.stage.update()
      return
    )

    return


@BrowserController = BrowserController
