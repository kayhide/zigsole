// Generated by CoffeeScript 1.3.3
(function() {
  var Puzzle,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Puzzle = (function() {

    function Puzzle(canvas) {
      this.onPiecePressed = __bind(this.onPiecePressed, this);

      this.onStagePressed = __bind(this.onStagePressed, this);
      this.stage = new Stage(canvas);
      this.image = null;
      this.cutter = null;
      this.pieces = [];
    }

    Puzzle.prototype.initizlize = function(image, cutter) {
      var i, p, _i, _len, _ref,
        _this = this;
      this.image = image;
      this.cutter = cutter;
      this.stage.canvas.onmousewheel = function(e) {
        if (e.wheelDelta > 0) {
          return _this.zoom(e.x, e.y, 1.2);
        } else {
          return _this.zoom(e.x, e.y, 1 / 1.2);
        }
      };
      this.background = new Shape();
      this.background.onPress = this.onStagePressed;
      this.background.graphics.beginFill(Graphics.getRGB(0, 0, 0));
      this.background.graphics.rect(0, 0, screen.width, screen.height);
      this.stage.addChild(this.background);
      this.container = new Container();
      this.pieces = this.cutter.cut(this.image);
      _ref = this.pieces;
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        p = _ref[i];
        p.id = i;
        p.puzzle = this;
        p.shape = new Shape();
        p.shape.piece = p;
        p.draw();
        this.container.addChild(p.shape);
        p.shape.onPress = this.onPiecePressed;
      }
      this.stage.addChild(this.container);
      this.stage.update();
      return Command.onCommit = function(cmd) {
        return _this.stage.update();
      };
    };

    Puzzle.prototype.update = function() {
      return this.stage.update();
    };

    Puzzle.prototype.zoom = function(x, y, scale) {
      this.container.scaleX = this.container.scaleX * scale;
      this.container.scaleY = this.container.scaleX;
      this.container.x = x - (x - this.container.x) * scale;
      this.container.y = y - (y - this.container.y) * scale;
      return this.stage.update();
    };

    Puzzle.prototype.onStagePressed = function(e) {
      var last_point,
        _this = this;
      window.console.log('stage pressed: ' + e.stageX + ', ' + e.stageY);
      last_point = new Point(e.stageX, e.stageY);
      return e.onMouseMove = function(ev) {
        var pt;
        pt = new Point(ev.stageX, ev.stageY);
        _this.container.x += pt.x - last_point.x;
        _this.container.y += pt.y - last_point.y;
        last_point = pt;
        return _this.stage.update();
      };
    };

    Puzzle.prototype.onPiecePressed = function(e) {
      var center, last_point, local_point, piece,
        _this = this;
      window.console.log("shape[" + e.target.piece.id + "] pressed: " + e.stageX + ", " + e.stageY);
      this.container.addChild(e.target);
      this.stage.update();
      piece = e.target.piece;
      last_point = this.container.globalToLocal(e.stageX, e.stageY);
      local_point = e.target.globalToLocal(e.stageX, e.stageY);
      if (local_point.distanceTo(piece.getCenter()) > 0.4 * this.cutter.linear_measure) {
        center = piece.getCenter();
        center = e.target.localToLocal(center.x, center.y, this.container);
        return e.onMouseMove = function(ev) {
          var pt, vec;
          pt = _this.container.globalToLocal(ev.stageX, ev.stageY);
          vec = pt.subtract(last_point);
          new RotateCommand(e.target.piece, center, vec.x).commit();
          return last_point = pt;
        };
      } else {
        return e.onMouseMove = function(ev) {
          var pt, vec;
          pt = _this.container.globalToLocal(ev.stageX, ev.stageY);
          vec = pt.subtract(last_point);
          new TranslateCommand(e.target.piece, vec).commit();
          return last_point = pt;
        };
      }
    };

    return Puzzle;

  })();

  this.Puzzle = Puzzle;

}).call(this);
