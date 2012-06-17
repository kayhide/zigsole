class BrowserController
  constructor: (@puzzle) ->
  
  attach: ->
    $(window).on('resize', @onWindowResize)

    @onWindowResize()
    return

  onWindowResize: =>
    { innerWidth: w, innerHeight: h } = window
    if $.browser.android?
      window.scrollTo(0, 1);
      
    @puzzle.stage.canvas.width = w
    @puzzle.stage.canvas.height = h
    $(@puzzle.stage.canvas)
    .css('left', (window.innerWidth - w)/2)
    .css('top', (window.innerHeight - h)/2)
    .width(w)
    .height(h)
    @puzzle.invalidate()
    return


@BrowserController = BrowserController
