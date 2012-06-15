$( ->
  window.console.log($.browser)
  $.browser.android = true if /android/.test(navigator.userAgent.toLowerCase())
  $.browser.iphone = true if /iphone/.test(navigator.userAgent.toLowerCase())
  $.browser.ipad = true if /iphone/.test(navigator.userAgent.toLowerCase())
  $.browser.ipod = true if /iphone/.test(navigator.userAgent.toLowerCase())
  $.browser.ios = true if $.browser.iphone? or $.browser.ipad? or $.browser.ipod?
  $.browser.smart_phone = true if $.browser.android? or $.browser.iphone?
#  $.browser.smart_phone = true
  
  field = $("#field")
  field
  .width(window.innerWidth)
  .height(window.innerHeight)

  front = $("#active")
  front
#  .css('background-color', 'rgba(200, 255, 255, 0.5)')
  .hide()
  .draggable({ cursor: 'move', scroll: false })

  
  puzzle = new Puzzle(field[0], front[0])
  
  image = new Image()
  image.onload = ->
    image.aspect_ratio = image.width / image.height
    cutter = new StandardGridCutter()
    
    cutter.nx = if $.browser.smart_phone? then 4 else 30
    cutter.ny = Math.round(cutter.nx / image.aspect_ratio)
    cutter.width = image.width
    cutter.height = image.height
    cutter.fluctuation = 0.3
    cutter.irregularity = 0.2
    puzzle.initizlize(image, cutter)

    if Touch.isSupported()
      Touch.enable(puzzle.stage)
      new BrowserController(puzzle).attach()
      new TouchController(puzzle).attach()
    else
      new BrowserController(puzzle).attach()
      new MouseController(puzzle).attach()

    puzzle.shuffle()

    if $.browser.smart_phone?
      puzzle.centerize()
      puzzle.zoom(window.innerWidth / 2, window.innerHeight / 2, 1 / 2)
    else
      puzzle.fill()

    
    field.addClass('checkered')
    
    p = document.createElement('p')
    p.id = 'piece-count'
    $(p).text("#{cutter.count} ( #{cutter.nx} x #{cutter.ny} )")
    $("#info")[0].appendChild(p)

    p = document.createElement('p')
    p.id = 'ticker'
    $("#info")[0].appendChild(p)
    #$("#info").text("sh: #{screen.height} wh: #{window.innerHeight}")

    Ticker.setFPS(60)
    Ticker.addListener(window)

    window.tick = =>
      if puzzle.stage.invalidated?
        puzzle.stage.update()
        puzzle.stage.invalidated = null
      if puzzle.activelayer.invalidated?
        if puzzle.activelayer.children.length > 0
          $(puzzle.activelayer.canvas).show()
        else
          $(puzzle.activelayer.canvas).hide()
        puzzle.activelayer.update()
        puzzle.activelayer.invalidated = null
      $("#ticker").text("FPS: #{Math.round(Ticker.getMeasuredFPS())}")



  for a in $('a')
    switch a.hash
      when '#fit'
        a.onclick = =>
          puzzle.fit()
          return false
      when '#zoom-in'
        a.onclick = =>
          puzzle.zoom(window.innerWidth / 2, window.innerHeight / 2, 1.2)
          return false
      when '#zoom-out'
        a.onclick = =>
          puzzle.zoom(window.innerWidth / 2, window.innerHeight / 2, 1 / 1.2)
          return false

  if $.browser.smart_phone?
    image.src = "asset/AA145_L_320.jpg"
  else
#    image.src = "asset/AA145_L.jpg"
    image.src = "asset/IMG_1605.JPG"

  puzzle.sounds = {
    merge: document.getElementById("se-merge")
  }

  window.puzzle = puzzle
  window.pieces = puzzle.pieces
)
