// Generated by CoffeeScript 1.3.3
(function() {
  var Piece;

  Piece = (function() {

    function Piece() {
      this.puzzle = null;
      this.edge = null;
      this.shape = null;
      this.draws_stroke = true;
      this.draws_control_line = false;
      this.draws_boundary = true;
      this.draws_center = true;
    }

    Piece.prototype.setEdge = function(edge) {
      var he, _i, _len, _ref, _results;
      this.edge = edge;
      _ref = this.edge.getLoopEdges();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        he = _ref[_i];
        _results.push(he.piece = this);
      }
      return _results;
    };

    Piece.prototype.getLoopCurve = function() {
      var curves, e;
      curves = (function() {
        var _i, _len, _ref, _results;
        _ref = this.edge.getLoopEdges();
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          e = _ref[_i];
          _results.push(e.curve);
        }
        return _results;
      }).call(this);
      return this.connectCurves(curves);
    };

    Piece.prototype.getBoundary = function(points) {
      var pt, pt0, pt1, _i, _len, _ref;
      if (points == null) {
        points = null;
      }
      if (this.boundary == null) {
        if (points == null) {
          points = this.getLoopCurve();
        }
        pt0 = points[0].clone();
        pt1 = points[0].clone();
        _ref = points.slice(1);
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          pt = _ref[_i];
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
      }
      return this.boundary;
    };

    Piece.prototype.getCenter = function() {
      var boundary;
      boundary = this.getBoundary();
      return new Point(boundary[0] + boundary[2] / 2, boundary[1] + boundary[3] / 2);
    };

    Piece.prototype.draw = function() {
      var boundary, center, g, loop_curve, _ref;
      this.shape.uncache();
      this.boundary = null;
      g = this.shape.graphics;
      g.clear();
      g.beginBitmapFill(this.puzzle.image);
      if (this.draws_stroke) {
        g.beginStroke(2);
      }
      loop_curve = this.getLoopCurve();
      this.drawCurve(loop_curve);
      g.endFill().endStroke();
      boundary = this.getBoundary(loop_curve);
      if (this.draws_boundary) {
        (_ref = g.beginStroke(1)).rect.apply(_ref, boundary);
      }
      if (this.draws_control_line) {
        g.beginStroke(1);
        this.drawPolyline(loop_curve);
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

    Piece.prototype.connectCurves = function(curves) {
      var points, pt, pts, _i, _j, _len, _len1, _ref;
      points = [];
      points.push(curves[0][0]);
      for (_i = 0, _len = curves.length; _i < _len; _i++) {
        pts = curves[_i];
        _ref = pts.slice(1);
        for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
          pt = _ref[_j];
          points.push(pt);
        }
      }
      return points;
    };

    return Piece;

  })();

  this.Piece = Piece;

}).call(this);
