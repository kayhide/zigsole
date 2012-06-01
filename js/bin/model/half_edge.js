// Generated by CoffeeScript 1.3.3
(function() {
  var HalfEdge;

  HalfEdge = (function() {

    HalfEdge.create = function() {
      var he;
      he = new HalfEdge();
      he.mate = new HalfEdge();
      he.mate.mate = he;
      he.next = he.mate;
      he.mate.next = he;
      return he;
    };

    HalfEdge.createLoop = function(count) {
      var he, head, i, next, _i;
      head = HalfEdge.create();
      he = head;
      for (i = _i = 1; 1 <= count ? _i < count : _i > count; i = 1 <= count ? ++_i : --_i) {
        next = HalfEdge.create();
        he.setNext(next);
        he = next;
      }
      he.setNext(head);
      return head;
    };

    HalfEdge.next_id = 1;

    function HalfEdge() {
      this.point = new Point();
      this.next = null;
      this.mate = null;
      this.curve = null;
      this.facet = null;
      this.eid = HalfEdge.next_id;
      ++HalfEdge.next_id;
    }

    HalfEdge.prototype.prev = function() {
      var he;
      he = this.mate;
      while (he.next !== this) {
        he = he.next.mate;
      }
      return he;
    };

    HalfEdge.prototype.setPoint = function(pt) {
      var he, _results;
      this.point = pt;
      he = this.mate.next;
      _results = [];
      while (he !== this) {
        he.point = pt;
        _results.push(he = he.mate.next);
      }
      return _results;
    };

    HalfEdge.prototype.setNext = function(he) {
      this.next = he;
      return he.mate.next = this.mate;
    };

    HalfEdge.prototype.setMate = function(he) {
      if (this.mate === he) {
        return;
      }
      if (this.mate.prev() !== he.prev()) {
        this.mate.prev().next = he.mate.next;
      }
      if (he.mate.prev() !== this.prev()) {
        he.mate.prev().next = this.mate.next;
      }
      this.mate = he;
      return he.mate = this;
    };

    HalfEdge.prototype.getLoopEdges = function() {
      var edges, he;
      edges = [this];
      he = this.next;
      while (he !== this) {
        edges.push(he);
        he = he.next;
      }
      return edges;
    };

    HalfEdge.prototype.setCurve = function(c) {
      var i;
      this.curve = c;
      return this.mate.curve = (function() {
        var _i, _ref, _results;
        _results = [];
        for (i = _i = _ref = c.length - 1; _ref <= 0 ? _i <= 0 : _i >= 0; i = _ref <= 0 ? ++_i : --_i) {
          _results.push(c[i]);
        }
        return _results;
      })();
    };

    HalfEdge.prototype.isSolitary = function() {
      return this.next === this.mate && this.next.mate === this;
    };

    HalfEdge.prototype.weld = function() {
      this.prev().next = this.mate.next;
      this.mate.prev().next = this.next;
      this.next = this.mate;
      return this.mate.next = this;
    };

    return HalfEdge;

  })();

  this.HalfEdge = HalfEdge;

}).call(this);
