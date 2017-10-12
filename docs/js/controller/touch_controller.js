// Generated by CoffeeScript 1.12.7
(function() {
  var TouchController,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  TouchController = (function() {
    function TouchController(puzzle) {
      this.puzzle = puzzle;
      this.onManipulatorPressed = bind(this.onManipulatorPressed, this);
      this.onPiecePressed = bind(this.onPiecePressed, this);
      this.onStagePressed = bind(this.onStagePressed, this);
      this.manipulator = new Shape();
      this.colors = {
        shadow: "#AFF"
      };
      this.shadow = null;
    }

    TouchController.prototype.attach = function() {
      var i, len, p, ref;
      Touch.enable(this.puzzle.stage);
      this.puzzle.background.onPress = this.onStagePressed;
      ref = this.puzzle.pieces;
      for (i = 0, len = ref.length; i < len; i++) {
        p = ref[i];
        p.shape.onPress = this.onPiecePressed;
      }
      this.updateManipulator();
      this.manipulator.onPress = this.onManipulatorPressed;
      Command.onPost.push((function(_this) {
        return function(cmd) {
          var ref1, ref2;
          if (cmd instanceof MergeCommand) {
            _this.puzzle.container.removeChild(cmd.mergee.shape);
            if (((ref1 = _this.captured) != null ? ref1.piece : void 0) === cmd.piece || ((ref2 = _this.captured) != null ? ref2.piece : void 0) === cmd.mergee) {
              _this.release();
            }
          }
          _this.puzzle.invalidate();
        };
      })(this));
      return Command.onCommit.push((function(_this) {
        return function(cmds) {
          if (_this.captured == null) {
            _this.hideManipulator();
            _this.puzzle.invalidate();
          }
        };
      })(this));
    };

    TouchController.prototype.capture = function(p, point) {
      if (this.captured != null) {
        this.release();
      }
      if (this.captured == null) {
        window.console.log("captured[" + p.id + "] ( " + point.x + ", " + point.y + " )");
        this.captured = {
          piece: p,
          point: point
        };
        this.showManipulator();
        p.shape.shadow = this.shadow;
        return this.puzzle.container.addChild(p.shape);
      }
    };

    TouchController.prototype.release = function() {
      if (this.captured != null) {
        window.console.log("released[" + this.captured.piece.id + "]");
        this.hideManipulator();
        if (!this.captured.piece.isAlive()) {
          this.puzzle.container.removeChild(this.captured.piece.shape);
        }
        this.captured.piece.shape.shadow = null;
        this.captured = null;
        $(this.puzzle.stage.canvas).off('mousemove mouseup');
        return Command.commit();
      }
    };

    TouchController.prototype.updateManipulator = function() {
      var g, r;
      g = this.manipulator.graphics;
      g.clear();
      r = this.puzzle.cutter.linear_measure;
      g.setStrokeStyle(this.puzzle.cutter.linear_measure / 2);
      g.beginStroke(this.colors.shadow);
      g.drawCircle(0, 0, r);
      this.manipulator.alpha = 0.4;
      return this.manipulator.shadow = this.shadow;
    };

    TouchController.prototype.showManipulator = function() {
      var piece, point, ref;
      ref = this.captured, piece = ref.piece, point = ref.point;
      if (piece.isAlive()) {
        point = this.puzzle.container.localToGlobal(point.x, point.y);
        this.manipulator.x = point.x;
        this.manipulator.y = point.y;
        this.puzzle.foreground.addChild(this.manipulator);
        return this.puzzle.invalidate();
      }
    };

    TouchController.prototype.hideManipulator = function() {
      return this.puzzle.foreground.removeChild(this.manipulator);
    };

    TouchController.prototype.onStagePressed = function(e) {
      var first_move, last_point;
      if (this.captured != null) {
        this.release();
        this.puzzle.invalidate();
      }
      window.console.log("stage pressed: ( " + e.stageX + ", " + e.stageY + " )");
      last_point = new Point(e.stageX, e.stageY);
      first_move = true;
      return e.onMouseMove = (function(_this) {
        return function(ev) {
          var pt;
          if (first_move != null) {
            first_move = null;
            return;
          }
          pt = new Point(ev.stageX, ev.stageY);
          _this.puzzle.container.x += pt.x - last_point.x;
          _this.puzzle.container.y += pt.y - last_point.y;
          last_point = pt;
          return _this.puzzle.invalidate();
        };
      })(this);
    };

    TouchController.prototype.onPiecePressed = function(e) {
      var first_move, piece, point;
      piece = e.target.piece;
      window.console.log("piece[" + e.target.piece.id + "] pressed: ( " + e.stageX + ", " + e.stageY + " )");
      point = this.puzzle.container.globalToLocal(e.stageX, e.stageY);
      this.capture(piece, point);
      this.puzzle.invalidate();
      first_move = true;
      e.onMouseMove = (function(_this) {
        return function(ev) {
          var pt, vec;
          if (first_move != null) {
            first_move = null;
            return;
          }
          pt = _this.puzzle.container.globalToLocal(ev.stageX, ev.stageY);
          _this.manipulator.x = ev.stageX;
          _this.manipulator.y = ev.stageY;
          vec = pt.subtract(_this.captured.point);
          _this.captured.point = pt;
          return new TranslateCommand(_this.captured.piece, vec).post();
        };
      })(this);
      return e.onMouseUp = (function(_this) {
        return function(ev) {
          Command.commit();
          return _this.puzzle.tryMerge(_this.captured.piece);
        };
      })(this);
    };

    TouchController.prototype.onManipulatorPressed = function(e) {
      var first_move, last_point, piece;
      piece = this.captured.piece;
      last_point = this.manipulator.globalToLocal(e.stageX, e.stageY);
      first_move = true;
      e.onMouseMove = (function(_this) {
        return function(ev) {
          var center, degree, pt;
          if (first_move != null) {
            first_move = null;
            return;
          }
          pt = _this.manipulator.globalToLocal(ev.stageX, ev.stageY);
          degree = _this.getAngle(last_point, pt) * 180 / Math.PI;
          center = _this.manipulator.localToLocal(0, 0, _this.puzzle.container);
          _this.manipulator.rotation += degree;
          return new RotateCommand(piece, center, degree).post();
        };
      })(this);
      return e.onMouseUp = (function(_this) {
        return function(ev) {
          return Command.commit();
        };
      })(this);
    };

    TouchController.prototype.getAngle = function(vec0, vec1) {
      return Math.atan2(vec1.y, vec1.x) - Math.atan2(vec0.y, vec0.x);
    };

    return TouchController;

  })();

  this.TouchController = TouchController;

}).call(this);
