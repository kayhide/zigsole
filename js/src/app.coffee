$( ->
  field = document.getElementById("field")
  field.width = window.innerWidth
  field.height = window.innerHeight
  
  puzzle = new Puzzle(field)
  
  image = new Image()
  image.onload = ->
    image.aspect_ratio = image.width / image.height
    cutter = new StandardGridCutter()
    cutter.nx = 10
    cutter.ny = Math.round(cutter.nx / image.aspect_ratio)
    cutter.fluctuation = 0.3
    cutter.irregularity = 0.2

    puzzle.initizlize(image, cutter)
    puzzle.update()
    $("#info").text("#{cutter.count} ( #{cutter.nx} x #{cutter.ny} )")
    
  image.src = "/easel/test/AA145_L.jpg"
  

  window.puzzle = puzzle
  
  window.onresize = ->
    field.width = window.innerWidth
    field.height = window.innerHeight
    puzzle.update();
)