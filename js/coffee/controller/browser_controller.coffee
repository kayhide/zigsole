class BrowserController
  constructor: (@puzzle) ->
  
  attach: ->
    $('body')
    .css('background-color', '#000')
    .css('overflow', 'hidden')
    $(window).on('resize', ->
      @puzzle.stage.canvas.width = window.innerWidth
      @puzzle.stage.canvas.height = window.innerHeight
      @puzzle.background.graphics
      .clear()
      .beginFill(Graphics.getRGB(0,0,0))
      .rect(0, 0, window.innerWidth, window.innerHeight)
      
      @puzzle.centerize()
      return
    )
    return


@BrowserController = BrowserController
