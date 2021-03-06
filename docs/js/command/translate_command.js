// Generated by CoffeeScript 1.12.7
(function() {
  var TranslateCommand,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  TranslateCommand = (function(superClass) {
    extend(TranslateCommand, superClass);

    function TranslateCommand(piece, vector) {
      this.piece = piece;
      this.vector = vector;
      this.position = this.piece.position().add(this.vector);
      this.rotation = this.piece.rotation();
    }

    TranslateCommand.prototype.squash = function(cmd) {
      if (cmd instanceof TranslateCommand && cmd.piece === this.piece) {
        this.vector = this.vector.add(cmd.vector);
        this.position = cmd.position, this.rotation = cmd.rotation;
        return true;
      } else {
        return false;
      }
    };

    TranslateCommand.prototype.isValid = function() {
      var ref;
      return (ref = this.piece) != null ? ref.isAlive() : void 0;
    };

    return TranslateCommand;

  })(TransformCommand);

  this.TranslateCommand = TranslateCommand;

}).call(this);
