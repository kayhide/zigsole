// Generated by CoffeeScript 1.3.3
(function() {
  var Piece;

  Piece = (function() {

    function Piece() {
      this.puzzle = null;
      this.loops = [];
      this.shape = null;
      this.draws_stroke = false;
      this.draws_control_line = false;
      this.draws_boundary = false;
      this.draws_center = false;
    }

    Piece.prototype.addLoop = function(lp) {
      return this.loops.push(lp);
    };

    Piece.prototype.removeLoop = function(lp) {
      var l;
      return this.loops = (function() {
        var _i, _len, _ref, _results;
        _ref = this.loops;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          l = _ref[_i];
          if (l !== lp) {
            _results.push(l);
          }
        }
        return _results;
      }).call(this);
    };

    Piece.prototype.getBoundary = function() {
      var lp, points, pt, pt0, pt1, _i, _j, _len, _len1, _ref, _ref1;
      if (this.boundary == null) {
        points = [];
        _ref = this.loops;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          lp = _ref[_i];
          points = points.concat(lp.getCurve());
        }
        if (points.length > 0) {
          pt0 = points[0].clone();
          pt1 = points[0].clone();
          _ref1 = points.slice(1);
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            pt = _ref1[_j];
            if (!(pt != null)) {
              continue;
            }
            if (pt.x < pt0.x) {
              pt0.x = pt.x;
            }
            if (pt.y < pt0.y) {
              pt0.y = pt.y;
            }
            if (pt.x > pt1.x) {
              pt1.x = pt.x;
            }
            if (pt.y > pt1.y) {
              pt1.y = pt.y;
            }
          }
          this.boundary = [pt0.x, pt0.y, pt1.x - pt0.x, pt1.y - pt0.y];
        } else {
          this.boundary = [0, 0, 0, 0];
        }
      }
      return this.boundary;
    };

    Piece.prototype.getCenter = function() {
      var boundary;
      boundary = this.getBoundary();
      return new Point(boundary[0] + boundary[2] / 2, boundary[1] + boundary[3] / 2);
    };

    Piece.prototype.draw = function() {
      var boundary, center, g, lp, _i, _j, _len, _len1, _ref, _ref1, _ref2;
      this.shape.uncache();
      this.boundary = null;
      g = this.shape.graphics;
      g.clear();
      g.beginBitmapFill(this.puzzle.image);
      if (this.draws_stroke) {
        g.beginStroke(2);
      }
      _ref = this.loops;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        lp = _ref[_i];
        this.drawCurve(lp.getCurve());
      }
      g.endFill().endStroke();
      boundary = this.getBoundary();
      if (this.draws_boundary) {
        (_ref1 = g.beginStroke(1)).rect.apply(_ref1, boundary);
      }
      if (this.draws_control_line) {
        g.beginStroke(1);
        _ref2 = this.loops;
        for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
          lp = _ref2[_j];
          this.drawPolyline(lp.getCurve());
        }
      }
      if (this.draws_center) {
        center = this.getCenter();
        g.beginStroke(2).drawCircle(center.x, center.y, 4);
      }
      return this.shape.cache(boundary[0] - 1, boundary[1] - 1, boundary[2] + 2, boundary[3] + 2);
    };

    Piece.prototype.drawCurve = function(points) {
      var g, i, pt, _i, _len, _ref, _results, _step;
      g = this.shape.graphics;
      g.moveTo(points[0].x, points[0].y);
      _ref = points.slice(1);
      _results = [];
      for (i = _i = 0, _len = _ref.length, _step = 3; _i < _len; i = _i += _step) {
        pt = _ref[i];
        if ((points[i + 1] != null) && (points[i + 2] != null)) {
          _results.push(g.bezierCurveTo(points[i + 1].x, points[i + 1].y, points[i + 2].x, points[i + 2].y, points[i + 3].x, points[i + 3].y));
        } else {
          _results.push(g.lineTo(points[i + 3].x, points[i + 3].y));
        }
      }
      return _results;
    };

    Piece.prototype.drawPolyline = function(points) {
      var g, pt, _i, _len, _ref, _results;
      g = this.shape.graphics;
      g.moveTo(points[0].x, points[0].y);
      _ref = points.slice(1);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        pt = _ref[_i];
        if (pt != null) {
          _results.push(g.lineTo(pt.x, pt.y));
        }
      }
      return _results;
    };

    return Piece;

  })();

  this.Piece = Piece;

}).call(this);
