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
      window.scrollTo(0, 1);
      
    @puzzle.stage.canvas.width = w
    @puzzle.stage.canvas.height = h
    $(@puzzle.stage.canvas)
    .css('left', (window.innerWidth - w)/2)
    .css('top', (window.innerHeight - h)/2)
    .width(w)
    .height(h)
    @puzzle.background.width = w
    @puzzle.background.height = h
    @puzzle.background.graphics
    .clear()
    .beginFill(@puzzle.background.color)
    .rect(0, 0, @puzzle.background.width, @puzzle.background.height)
    @puzzle.invalidate()
    return


@BrowserController = BrowserController
