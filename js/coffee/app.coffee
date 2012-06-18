$( ->
  $.browser.android = true if /android/.test(navigator.userAgent.toLowerCase())
  $.browser.iphone = true if /iphone/.test(navigator.userAgent.toLowerCase())
  $.browser.ipad = true if /iphone/.test(navigator.userAgent.toLowerCase())
  $.browser.ipod = true if /iphone/.test(navigator.userAgent.toLowerCase())
  $.browser.ios = true if $.browser.iphone? or $.browser.ipad? or $.browser.ipod?
  $.browser.smart_phone = true if $.browser.android? or $.browser.iphone?
#  $.browser.smart_phone = true
  window.console.log($.browser)

  field = document.getElementById('field')
  puzzle = new Puzzle(field)
  
  image = new Image()
  $(image).on('load', ->
    image.aspect_ratio = image.width / image.height
    cutter = new StandardGridCutter()
    
    cutter.nx = switch puzzle.difficulty
      when 'easy'
        4
      when 'normal'
        10
      when 'hard'
        20
      when 'lunatic'
        40
      else
        10
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

    p = document.createElement('p')
    p.id = 'piece-count'
    $(p).text("#{cutter.count} ( #{cutter.nx} x #{cutter.ny} )")
    $("#info").prepend(p)

    Command.onPost.push((cmd) =>
      if cmd instanceof MergeCommand
        $("#progressbar").width((puzzle.progress * 100).toFixed(0) + '%')
        sounds?.merge?.play()
      return
    )

    p = document.createElement('p')
    p.id = 'ticker'
    $("#info").append(p)

    Ticker.setFPS(60)
    Ticker.addListener(window)

    window.tick = =>
      if puzzle.stage.invalidated?
        puzzle.stage.update()
        puzzle.stage.invalidated = null
      $("#ticker").text("FPS: #{Math.round(Ticker.getMeasuredFPS())}")
  )


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

  sounds = {
    merge: $('#sound-list > .merge')[0]
  }

  window.start = (art_id, difficulty) ->
    puzzle.difficulty = difficulty
    $(image).on('load', ->
      $('body')
      .css('overflow', 'hidden')

      $('#playboard')
      .css('background-color', 'rgba(0,0,40,0.9)')
      
      $('.navbar, .container').hide()
      $('#playboard').fadeIn('slow', ->
        $('body').addClass('checkered')
      )
    )
    
    if $.browser.smart_phone?
      image.src = $("##{art_id} > .image-list > .small").attr('data-src')
    else
      image.src = $("##{art_id} > .image-list > .large").attr('data-src')

  window.puzzle = puzzle


  class Art
    constructor: (id, @basename, @caption) ->
      @id = "art-#{id}"
      @thumbnail = "asset/#{@basename}_260.jpg"
      @image_sources = [
        { size: 'small', ref: "asset/#{@basename}_480.jpg" }
        { size: 'medium', ref: "asset/#{@basename}_980.jpg" }
        { size: 'large', ref: "asset/#{@basename}.jpg" }
      ]
      @links = [
        { label: 'Easy', level: 'easy' }
        { label: 'Normal', level: 'normal' }
        { label: 'Hard', level: 'hard' }
      ]

    onClick: (data) =>
      start(@id, data.level)
      false

  class ViewModel
    arts: [
      new Art(1, 'IMG_0248', 'Firework')
      new Art(2, 'IMG_0681', 'Sunrise')
      new Art(3, 'IMG_1291', 'Lake')
      new Art(4, 'IMG_2062', 'Food')
      new Art(5, 'IMG_2887', 'Artillery')
      new Art(6, 'IMG_9233', 'Mountain')
    ]


  ko.applyBindings(new ViewModel());
)
