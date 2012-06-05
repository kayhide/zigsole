$( ->
  window.console.log($.browser)
  $.browser.android = true if /android/.test(navigator.userAgent.toLowerCase())
  $.browser.iphone = true if /iphone/.test(navigator.userAgent.toLowerCase())
  $.browser.small = $.browser.android? or $.browser.iphone?
  
  field = document.getElementById("field")
  if $.browser.small?
    field.width = screen.width
    field.height = screen.height
  else
    field.width = window.innerWidth
    field.height = window.outerHeight
  
  puzzle = new Puzzle(field)
  
  image = new Image()
  image.onload = ->
    image.aspect_ratio = image.width / image.height
    cutter = new StandardGridCutter()
    
    cutter.nx = if $.browser.small
      4
    else
      10
    cutter.ny = Math.round(cutter.nx / image.aspect_ratio)
    cutter.width = image.width
    cutter.height = image.height
    cutter.fluctuation = 0.3
    cutter.irregularity = 0.2
    puzzle.initizlize(image, cutter)

    if $.browser.android? or $.browser.iphone?
      puzzle.centerize()
      new BrowserController(puzzle).attach()
      new TouchController(puzzle).attach()
    else
      puzzle.fill()
      new BrowserController(puzzle).attach()
      new MouseController(puzzle).attach()

    $(field).addClass('checkered')
    $("#info").text("#{cutter.count} ( #{cutter.nx} x #{cutter.ny} )")


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
