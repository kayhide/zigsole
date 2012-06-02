// Generated by CoffeeScript 1.3.3
(function() {
  var TranslateCommand,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  TranslateCommand = (function(_super) {

    __extends(TranslateCommand, _super);

    function TranslateCommand(piece, vector) {
      this.piece = piece;
      this.vector = vector;
    }

    TranslateCommand.prototype.execute = function() {
      this.piece.shape.x += this.vector.x;
      return this.piece.shape.y += this.vector.y;
    };

    TranslateCommand.prototype.squash = function(cmd) {
      if (cmd instanceof TranslateCommand && cmd.piece === this.piece) {
        this.vector = this.vector.add(cmd.vector);
        return true;
      } else {
        return false;
      }
    };

    TranslateCommand.prototype.isTransformCommand = function() {
      return true;
    };

    TranslateCommand.prototype.isValid = function() {
      var _ref;
      return (_ref = this.piece) != null ? _ref.isAlive() : void 0;
    };

    return TranslateCommand;

  })(Command);

  this.TranslateCommand = TranslateCommand;

}).call(this);
