// Generated by CoffeeScript 1.12.7
(function() {
  var BrowserController,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  BrowserController = (function() {
    function BrowserController(puzzle) {
      this.puzzle = puzzle;
      this.onWindowResize = bind(this.onWindowResize, this);
    }

    BrowserController.prototype.attach = function() {
      $(window).on('resize', this.onWindowResize);
      this.onWindowResize();
    };

    BrowserController.prototype.onWindowResize = function() {
      var h, w;
      w = window.innerWidth, h = window.innerHeight;
      if ($.browser.android != null) {
        window.scrollTo(0, 1);
      }
      this.puzzle.stage.canvas.width = w;
      this.puzzle.stage.canvas.height = h;
      $(this.puzzle.stage.canvas).css('left', (window.innerWidth - w) / 2).css('top', (window.innerHeight - h) / 2).width(w).height(h);
      this.puzzle.invalidate();
    };

    return BrowserController;

  })();

  this.BrowserController = BrowserController;

}).call(this);
