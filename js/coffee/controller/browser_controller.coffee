class BrowserController
  constructor: (@puzzle) ->
  
  attach: ->
    $('body')
    .css('background-color', '#000')
    .css('overflow', 'hidden')
    $(window).on('resize', @onWindowResize)
    @onWindowResize()

    return

  onWindowResize: =>
    [w, h] = [window.innerWidth, window.innerHeight]
    if $.browser.android?
      h += 60
      window.scrollTo(0, 1);
      
    @puzzle.stage.canvas.width = w
    @puzzle.stage.canvas.height = h
    if (!@puzzle.background.width? or
        w > @puzzle.background.width * 0.8 or
        h > @puzzle.background.height * 0.8)
      @puzzle.background.width = w * 2
      @puzzle.background.height = h * 2
      @puzzle.background.graphics
      .clear()
      .beginFill(@puzzle.background.color)
      .rect(0, 0, @puzzle.background.width, @puzzle.background.height)
    @puzzle.invalidate()
    return


@BrowserController = BrowserController
