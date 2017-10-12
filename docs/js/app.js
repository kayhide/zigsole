// Generated by CoffeeScript 1.12.7
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  $(function() {
    var Art, ViewModel, a, field, i, image, len, puzzle, ref, sounds;
    if (/android/.test(navigator.userAgent.toLowerCase())) {
      $.browser.android = true;
    }
    if (/iphone/.test(navigator.userAgent.toLowerCase())) {
      $.browser.iphone = true;
    }
    if (/iphone/.test(navigator.userAgent.toLowerCase())) {
      $.browser.ipad = true;
    }
    if (/iphone/.test(navigator.userAgent.toLowerCase())) {
      $.browser.ipod = true;
    }
    if (($.browser.iphone != null) || ($.browser.ipad != null) || ($.browser.ipod != null)) {
      $.browser.ios = true;
    }
    if (($.browser.android != null) || ($.browser.iphone != null)) {
      $.browser.smart_phone = true;
    }
    window.console.log($.browser);
    field = document.getElementById('field');
    puzzle = new Puzzle(field);
    image = new Image();
    $(image).on('load', function() {
      var cutter, p;
      image.aspect_ratio = image.width / image.height;
      cutter = new StandardGridCutter();
      cutter.nx = (function() {
        switch (puzzle.difficulty) {
          case 'easy':
            return 4;
          case 'normal':
            return 10;
          case 'hard':
            return 20;
          case 'lunatic':
            return 40;
          default:
            return 10;
        }
      })();
      cutter.ny = Math.round(cutter.nx / image.aspect_ratio);
      cutter.width = image.width;
      cutter.height = image.height;
      cutter.fluctuation = 0.3;
      cutter.irregularity = 0.2;
      puzzle.initizlize(image, cutter);
      if (Touch.isSupported()) {
        Touch.enable(puzzle.stage);
        new BrowserController(puzzle).attach();
        new TouchController(puzzle).attach();
      } else {
        new BrowserController(puzzle).attach();
        new MouseController(puzzle).attach();
      }
      puzzle.shuffle();
      if ($.browser.smart_phone != null) {
        puzzle.centerize();
        puzzle.zoom(window.innerWidth / 2, window.innerHeight / 2, 1 / 2);
      } else {
        puzzle.fill();
      }
      p = document.createElement('p');
      p.id = 'piece-count';
      $(p).text(cutter.count + " ( " + cutter.nx + " x " + cutter.ny + " )");
      $("#info").prepend(p);
      Command.onPost.push((function(_this) {
        return function(cmd) {
          var ref;
          if (cmd instanceof MergeCommand) {
            $("#progressbar").width((puzzle.progress * 100).toFixed(0) + '%');
            if (typeof sounds !== "undefined" && sounds !== null) {
              if ((ref = sounds.merge) != null) {
                ref.play();
              }
            }
            if (puzzle.progress === 1) {
              $('#finished').fadeIn('slow', function() {
                return $('#finished').css('opacity', 0.99);
              });
            }
          }
        };
      })(this));
      p = document.createElement('p');
      p.id = 'ticker';
      $("#info").append(p);
      Ticker.setFPS(60);
      Ticker.addListener(window);
      return window.tick = (function(_this) {
        return function() {
          if (puzzle.stage.invalidated != null) {
            puzzle.stage.update();
            puzzle.stage.invalidated = null;
          }
          return $("#ticker").text("FPS: " + (Math.round(Ticker.getMeasuredFPS())));
        };
      })(this);
    });
    ref = $('a');
    for (i = 0, len = ref.length; i < len; i++) {
      a = ref[i];
      switch (a.hash) {
        case '#fit':
          a.onclick = (function(_this) {
            return function() {
              puzzle.fit();
              return false;
            };
          })(this);
          break;
        case '#zoom-in':
          a.onclick = (function(_this) {
            return function() {
              puzzle.zoom(window.innerWidth / 2, window.innerHeight / 2, 1.2);
              return false;
            };
          })(this);
          break;
        case '#zoom-out':
          a.onclick = (function(_this) {
            return function() {
              puzzle.zoom(window.innerWidth / 2, window.innerHeight / 2, 1 / 1.2);
              return false;
            };
          })(this);
      }
    }
    sounds = {
      merge: $('#sound-list > .merge')[0]
    };
    window.start = function(art_id, difficulty) {
      puzzle.difficulty = difficulty;
      $(image).on('load', function() {
        $('body').css('overflow', 'hidden');
        $('#playboard').css('background-color', 'rgba(0,0,40,0.9)');
        $('.navbar, #art-list').hide();
        return $('#playboard').fadeIn('slow', function() {
          return $('body').addClass('checkered');
        });
      });
      if ($.browser.smart_phone != null) {
        return image.src = $("#" + art_id + " > .image-list > .small").attr('data-src');
      } else {
        return image.src = $("#" + art_id + " > .image-list > .large").attr('data-src');
      }
    };
    window.puzzle = puzzle;
    Art = (function() {
      function Art(id, basename, caption) {
        this.basename = basename;
        this.caption = caption;
        this.onClick = bind(this.onClick, this);
        this.id = "art-" + id;
        this.thumbnail = "asset/" + this.basename + "_260.jpg";
        this.image_sources = [
          {
            size: 'small',
            ref: "asset/" + this.basename + "_480.jpg"
          }, {
            size: 'medium',
            ref: "asset/" + this.basename + "_980.jpg"
          }, {
            size: 'large',
            ref: "asset/" + this.basename + ".jpg"
          }
        ];
        this.links = [
          {
            label: 'Easy',
            level: 'easy'
          }, {
            label: 'Normal',
            level: 'normal'
          }, {
            label: 'Hard',
            level: 'hard'
          }
        ];
      }

      Art.prototype.onClick = function(data) {
        start(this.id, data.level);
        return false;
      };

      return Art;

    })();
    ViewModel = (function() {
      function ViewModel() {}

      ViewModel.prototype.arts = [new Art(1, 'IMG_0248', 'Firework'), new Art(2, 'IMG_0681', 'Sunrise'), new Art(3, 'IMG_1291', 'Lake'), new Art(4, 'IMG_2062', 'Food'), new Art(5, 'IMG_2887', 'Artillery'), new Art(6, 'IMG_9233', 'Mountain')];

      return ViewModel;

    })();
    return ko.applyBindings(new ViewModel());
  });

}).call(this);