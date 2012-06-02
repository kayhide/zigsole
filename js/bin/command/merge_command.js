// Generated by CoffeeScript 1.3.3
(function() {
  var MergeCommand,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  MergeCommand = (function(_super) {

    __extends(MergeCommand, _super);

    function MergeCommand(piece, mergee) {
      this.piece = piece;
      this.mergee = mergee;
    }

    MergeCommand.prototype.execute = function() {
      var lp, _i, _len, _ref;
      this.piece = this.piece.getEntity();
      _ref = this.mergee.loops;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        lp = _ref[_i];
        this.piece.addLoop(lp);
      }
      this.mergee.merger = this.piece;
      this.mergee.shape.parent.removeChild(this.mergee.shape);
      return this.piece.draw();
    };

    MergeCommand.prototype.isValid = function() {
      var _ref;
      return (_ref = this.mergee) != null ? _ref.isAlive() : void 0;
    };

    return MergeCommand;

  })(Command);

  this.MergeCommand = MergeCommand;

}).call(this);
