var Piece = function() {
  this.draw = function(ctx) {
    ctx.save();
    ctx.beginPath();
    ctx.rect(this.x, this.y, this.w, this.h);
    ctx.fill();
    ctx.restore();
  }
};

var Puzzle = function() {
  this.image = null;
  this.pieces = new Array();
  
  this.cut = function(nx, ny, pattern) {
    var w = this.image.width/nx;
    var h = this.image.height/ny;
    for (var y = 0; y < ny; ++y) {
      for (var x = 0; x < nx; ++x) {
        p = new Piece();
        p.x = x*w;
        p.y = y*h;
        p.w = w;
        p.h = h;
        this.pieces.push(p);
      }
    }
  }

  
};

var puzzle = new Puzzle();

$(function() {
  var field = $("#field").get(0);
  field.width = window.innerWidth;
  field.height = window.innerHeight;

  var nx = 10;
  var image = new Image();
  image.onload = function() {
    puzzle.image = image;
    var aspect_ratio = image.width / image.height;
    var ny = Math.round(nx / aspect_ratio);
    puzzle.cut(nx, ny);

    $("#info").text(nx*ny + " ( " + nx + " x " + ny + " )");

    init(image);
  };
  image.src = "/easel/test/AA145_L.jpg";

  
  field.onmousewheel = function(e) {
    if (e.wheelDelta > 0) {
      zoomIn(e.x, e.y);
    } else {
      zoomOut(e.x, e.y);
    }
  }

  window.onresize = function() {
    field.width = window.innerWidth;
    field.height = window.innerHeight;
    stage.update();
  }

});





var stage;
var background;

function init(image) {
  stage = new Stage(document.getElementById("field"));
  stage.enableMouseOver();

  background = new Shape();
  background.onPress = onStagePressed;
  background.graphics.beginFill(Graphics.getRGB(0,0,0));
  background.graphics.rect(0, 0, screen.width, screen.height);
  stage.addChild(background);
  
  puzzle.pieces.forEach(function(p) {
    shape = new Shape();
    shape.graphics.beginBitmapFill(image);
    var r = p.w*0.2;
    shape.graphics.drawRoundRect(p.x, p.y, p.w, p.h, r);
    shape.cache(p.x, p.y, p.w, p.h);
    stage.addChild(shape);
    shape.onPress = onShapePressed;
  });

  stage.update();
}

function onStagePressed(e) {
  window.console.log('stage pressed: ' + e.stageX + ', ' + e.stageY);
  window.console.log(e);
  var last_point = new Point(e.stageX, e.stageY);
  e.onMouseMove = function(ev) {
    var pt = new Point(ev.stageX, ev.stageY);
    window.console.log(pt.y - last_point.y);
    stage.x += pt.x - last_point.x;
    stage.y += pt.y - last_point.y;
      
    last_point = pt;
    updateBackground();
    stage.update();
  }
}

function onShapePressed(e) {
  window.console.log('shape pressed: ' + e.stageX + ', ' + e.stageY);
  stage.addChild(e.target);
  stage.update();
  
  var last_point = stage.globalToLocal(e.stageX, e.stageY);
  e.onMouseMove = function(ev) {
    var pt = stage.globalToLocal(ev.stageX, ev.stageY);
    e.target.x += pt.x - last_point.x;
    e.target.y += pt.y - last_point.y;
      
    last_point = pt;
    stage.update();
  }
}

function updateBackground() {
  background.x = -stage.x / stage.scaleX;
  background.y = -stage.y / stage.scaleY;
  background.scaleX = 1 / stage.scaleX;
  background.scaleY = 1 / stage.scaleY;
}

function zoom(x, y, scale) {
  stage.scaleX = stage.scaleX * scale;
  stage.scaleY = stage.scaleX;
  stage.x = x - (x - stage.x) * scale;
  stage.y = y - (y - stage.y) * scale;
  updateBackground();
  stage.update();
}

function zoomIn(x, y) {
  zoom(x, y, 1.2);
}

function zoomOut(x,y) {
  zoom(x, y, 1/1.2);
}
