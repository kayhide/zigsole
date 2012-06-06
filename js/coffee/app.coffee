$( ->
  window.console.log($.browser)
  $.browser.android = true if /android/.test(navigator.userAgent.toLowerCase())
  $.browser.iphone = true if /iphone/.test(navigator.userAgent.toLowerCase())
  $.browser.ipad = true if /iphone/.test(navigator.userAgent.toLowerCase())
  $.browser.ipod = true if /iphone/.test(navigator.userAgent.toLowerCase())
  $.browser.ios = $.browser.iphone? or $.browser.ipad? or $.browser.ipod?
  $.browser.smart_phone = $.browser.android? or $.browser.iphone?
  
  field = document.getElementById("field")
  if $.browser.smart_phone?
    field.width = screen.width
    field.height = screen.height
  else
    field.width = window.innerWidth
    field.height = window.innerHeight
  
  puzzle = new Puzzle(field)
  
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

    if $.browser.smart_phone?
      puzzle.centerize()
      puzzle.zoom(window.innerWidth / 2, window.innerHeight / 2, 1 / 2)
      new BrowserController(puzzle).attach()
      new TouchController(puzzle).attach()
    else
      puzzle.fill()
      new BrowserController(puzzle).attach()
      new MouseController(puzzle).attach()

    $(field).addClass('checkered')
    
    p = document.createElement('p')
    p.id = 'piece-count'
    $(p).text("#{cutter.count} ( #{cutter.nx} x #{cutter.ny} )")
    $("#info")[0].appendChild(p)

    p = document.createElement('p')
    p.id = 'ticker'
    $("#info")[0].appendChild(p)
    #$("#info").text("sh: #{screen.height} wh: #{window.innerHeight}")

    Ticker.setInterval(10)
    Ticker.init()
    Ticker.addListener((cmd) =>
      if puzzle.invalidated?
        puzzle.stage.update()
        puzzle.invalidated = null
      $("#ticker").text("FPS: #{Math.floor(Ticker.getMeasuredFPS()).toString()}")
    )


  for a in $('a')
    switch a.hash
      when '#fit'
        a.onclick = => puzzle.fit()
      when '#zoom-in'
        a.onclick = =>
          puzzle.zoom(window.innerWidth / 2, window.innerHeight / 2, 1.2)
      when '#zoom-out'
        a.onclick = =>
          puzzle.zoom(window.innerWidth / 2, window.innerHeight / 2, 1 / 1.2)

  if $.browser.android? or $.browser.iphone?
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
