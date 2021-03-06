// Generated by CoffeeScript 1.12.7
(function() {
  var RotateCommand,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  RotateCommand = (function(superClass) {
    extend(RotateCommand, superClass);

    function RotateCommand(piece, center, degree) {
      var mtx;
      this.piece = piece;
      this.center = center;
      this.degree = degree;
      mtx = new Matrix2D();
      mtx.translate(-this.center.x, -this.center.y);
      mtx.rotate(Math.PI * this.degree / 180);
      mtx.translate(this.center.x, this.center.y);
      this.position = this.piece.position().apply(mtx);
      this.rotation = this.piece.rotation() + this.degree;
    }

    RotateCommand.prototype.squash = function(cmd) {
      if (cmd instanceof RotateCommand && cmd.piece === this.piece && cmd.center === this.center) {
        this.degree += cmd.degree;
        this.position = cmd.position, this.rotation = cmd.rotation;
        return true;
      } else {
        return false;
      }
    };

    RotateCommand.prototype.isValid = function() {
      var ref;
      return ((ref = this.piece) != null ? ref.isAlive() : void 0) && (this.center != null);
    };

    return RotateCommand;

  })(TransformCommand);

  this.RotateCommand = RotateCommand;

}).call(this);
