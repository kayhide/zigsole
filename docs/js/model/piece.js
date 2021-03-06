// Generated by CoffeeScript 1.12.7
(function() {
  var Piece;

  Piece = (function() {
    function Piece() {
      this.puzzle = null;
      this.loops = [];
      this.shape = null;
      this.merger = null;
      this._position = new Point();
      this._rotation = 0;
      this.draws_image = true;
      this.draws_stroke = false;
      this.draws_control_line = false;
      this.draws_boundary = false;
      this.draws_center = false;
    }

    Piece.prototype.position = function(pt) {
      if (pt != null) {
        this._position = pt;
        this.boundary = null;
        return this;
      } else {
        return this._position;
      }
    };

    Piece.prototype.rotation = function(deg) {
      if (deg != null) {
        this._rotation = deg;
        this.boundary = null;
        return this;
      } else {
        return this._rotation;
      }
    };

    Piece.prototype.matrix = function(pt) {
      var mtx;
      mtx = new Matrix2D();
      mtx.rotate(Math.PI * this._rotation / 180);
      mtx.translate(this._position.x, this._position.y);
      return mtx;
    };

    Piece.prototype.addLoop = function(lp) {
      this.loops.push(lp);
      if (lp.piece != null) {
        lp.piece.removeLoop(lp);
      }
      return lp.piece = this;
    };

    Piece.prototype.removeLoop = function(lp) {
      var l;
      return this.loops = (function() {
        var j, len, ref, results;
        ref = this.loops;
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
          l = ref[j];
          if (l !== lp) {
            results.push(l);
          }
        }
        return results;
      }).call(this);
    };

    Piece.prototype.getEntity = function() {
      if (this.merger != null) {
        return this.getMerger();
      } else {
        return this;
      }
    };

    Piece.prototype.getMerger = function() {
      var merger;
      merger = this.merger;
      while ((merger != null ? merger.merger : void 0) != null) {
        merger = merger.merger;
      }
      return merger;
    };

    Piece.prototype.isAlive = function() {
      return this.merger == null;
    };

    Piece.prototype.isWithinTolerance = function(target) {
      var he, j, len, mtx, pt, pt0, pt1, ref, ref1;
      if (Math.abs(this.getDegreeTo(target)) < this.puzzle.rotation_tolerance) {
        mtx = this.matrix();
        ref = this.getEdges();
        for (j = 0, len = ref.length; j < len; j++) {
          he = ref[j];
          if (!(((ref1 = he.mate.loop) != null ? ref1.piece : void 0) === target)) {
            continue;
          }
          pt = he.getCenter();
          pt0 = pt.apply(mtx);
          pt1 = pt.apply(target.matrix());
          if (pt0.distanceTo(pt1) < this.puzzle.translation_tolerance) {
            return true;
          }
        }
      }
      return false;
    };

    Piece.prototype.getDegreeTo = function(target) {
      var deg;
      deg = (target.shape.rotation - this.shape.rotation) % 360;
      if (deg > 180) {
        return deg - 360;
      } else if (deg <= -180) {
        return deg + 360;
      } else {
        return deg;
      }
    };

    Piece.prototype.getEdges = function() {
      var edges, he, j, k, len, len1, lp, ref, ref1;
      edges = [];
      ref = this.loops;
      for (j = 0, len = ref.length; j < len; j++) {
        lp = ref[j];
        ref1 = lp.getEdges();
        for (k = 0, len1 = ref1.length; k < len1; k++) {
          he = ref1[k];
          edges.push(he);
        }
      }
      return edges;
    };

    Piece.prototype.getAdjacentPieces = function() {
      var he, j, key, len, p, pieces, ref, results, value;
      pieces = {};
      ref = this.getEdges();
      for (j = 0, len = ref.length; j < len; j++) {
        he = ref[j];
        if (!(he.mate.loop != null)) {
          continue;
        }
        p = he.mate.loop.piece.getEntity();
        pieces[p.id] = p;
      }
      results = [];
      for (key in pieces) {
        value = pieces[key];
        if (value !== this) {
          results.push(value);
        }
      }
      return results;
    };

    Piece.prototype.getLocalPoints = function() {
      var j, k, len, len1, lp, points, pt, ref, ref1;
      points = [];
      ref = this.loops;
      for (j = 0, len = ref.length; j < len; j++) {
        lp = ref[j];
        ref1 = lp.getCurve();
        for (k = 0, len1 = ref1.length; k < len1; k++) {
          pt = ref1[k];
          if (pt != null) {
            points.push(pt);
          }
        }
      }
      return points;
    };

    Piece.prototype.getLocalBoundary = function() {
      return Point.boundary(this.getLocalPoints());
    };

    Piece.prototype.getPoints = function() {
      var j, len, mtx, points, pt, results;
      mtx = this.matrix();
      points = this.getLocalPoints();
      results = [];
      for (j = 0, len = points.length; j < len; j++) {
        pt = points[j];
        results.push(pt.apply(mtx));
      }
      return results;
    };

    Piece.prototype.getBoundary = function() {
      if (!((this.boundary != null) && false)) {
        this.boundary = Point.boundary(this.getPoints());
      }
      return this.boundary;
    };

    Piece.prototype.getCenter = function() {
      return this.getBoundary().getCenter();
    };

    Piece.prototype.draw = function() {
      var boundary, center, g, j, k, len, len1, lp, ref, ref1;
      this.shape.uncache();
      g = this.shape.graphics;
      g.clear();
      if (this.draws_image) {
        g.beginBitmapFill(this.puzzle.image);
      } else {
        g.beginFill("#9fa");
      }
      if (this.draws_stroke) {
        g.setStrokeStyle(2).beginStroke("#f0f");
      }
      ref = this.loops;
      for (j = 0, len = ref.length; j < len; j++) {
        lp = ref[j];
        this.drawCurve(lp.getCurve());
      }
      g.endFill().endStroke();
      boundary = this.getLocalBoundary();
      if (this.draws_boundary) {
        g.setStrokeStyle(2).beginStroke("#0f0").rect(boundary.x, boundary.y, boundary.width, boundary.height);
      }
      if (this.draws_control_line) {
        g.setStrokeStyle(2).beginStroke("#fff");
        ref1 = this.loops;
        for (k = 0, len1 = ref1.length; k < len1; k++) {
          lp = ref1[k];
          this.drawPolyline(lp.getCurve());
        }
      }
      if (this.draws_center) {
        center = boundary.getCenter();
        return g.setStrokeStyle(2).beginFill("#390").drawCircle(center.x, center.y, this.puzzle.cutter.linear_measure / 32);
      }
    };

    Piece.prototype.cache = function(padding) {
      var boundary;
      if (padding == null) {
        padding = 0;
      }
      boundary = this.getLocalBoundary();
      return this.shape.cache(boundary.x - padding, boundary.y - padding, boundary.width + padding * 2, boundary.height + padding * 2);
    };

    Piece.prototype.uncache = function() {
      return this.shape.uncache();
    };

    Piece.prototype.enbox = function() {
      var boundary;
      this.inner_shape = this.shape;
      this.shape = new Container();
      this.shape.copyTransform(this.inner_shape);
      this.inner_shape.clearTransform();
      this.inner_shape.parent.addChild(this.shape);
      this.shape.addChild(this.inner_shape);
      return boundary = this.getLocalBoundary();
    };

    Piece.prototype.unbox = function() {
      if (this.inner_shape != null) {
        this.inner_shape.copyTransform(this.shape);
        this.shape.parent.addChild(this.inner_shape);
        this.shape.remove();
        this.shape = this.inner_shape;
        return this.inner_shape = null;
      }
    };

    Piece.prototype.drawCurve = function(points) {
      var g, i, j, len, pt, ref, results;
      g = this.shape.graphics;
      g.moveTo(points[0].x, points[0].y);
      ref = points.slice(1);
      results = [];
      for (i = j = 0, len = ref.length; j < len; i = j += 3) {
        pt = ref[i];
        if ((points[i + 1] != null) && (points[i + 2] != null)) {
          results.push(g.bezierCurveTo(points[i + 1].x, points[i + 1].y, points[i + 2].x, points[i + 2].y, points[i + 3].x, points[i + 3].y));
        } else {
          results.push(g.lineTo(points[i + 3].x, points[i + 3].y));
        }
      }
      return results;
    };

    Piece.prototype.drawPolyline = function(points) {
      var g, j, len, pt, ref, results;
      g = this.shape.graphics;
      g.moveTo(points[0].x, points[0].y);
      ref = points.slice(1);
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        pt = ref[j];
        if (pt != null) {
          results.push(g.lineTo(pt.x, pt.y));
        }
      }
      return results;
    };

    return Piece;

  })();

  this.Piece = Piece;

}).call(this);
