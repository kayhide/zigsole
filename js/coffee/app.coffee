$( ->
  window.console.log($.browser)
  $.browser.android = true if /android/.test(navigator.userAgent.toLowerCase())
  
  field = document.getElementById("field")
  field.width = window.innerWidth
  field.height = window.innerHeight
  
  puzzle = new Puzzle(field)
  
  image = new Image()
  image.onload = ->
    image.aspect_ratio = image.width / image.height
    cutter = new StandardGridCutter()
    cutter.nx = 50
    cutter.ny = Math.round(cutter.nx / image.aspect_ratio)
    cutter.width = image.width
    cutter.height = image.height
    cutter.fluctuation = 0.3
    cutter.irregularity = 0.2
    puzzle.initizlize(image, cutter)

    if $.browser.android?
      puzzle.centerize()
      new BrowserController(puzzle).attach()
      new TouchController(puzzle).attach()
    else
      puzzle.fit()
      new BrowserController(puzzle).attach()
      new MouseController(puzzle).attach()

    $("#info").text("#{cutter.count} ( #{cutter.nx} x #{cutter.ny} )")

  if $.browser.android?
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
