// Generated by CoffeeScript 1.3.3
(function() {

  $(function() {
    var field, image, puzzle;
    field = document.getElementById("field");
    field.width = window.innerWidth;
    field.height = window.innerHeight;
    puzzle = new Puzzle(field);
    image = new Image();
    image.onload = function() {
      var cutter;
      image.aspect_ratio = image.width / image.height;
      cutter = new StandardGridCutter();
      cutter.nx = 4;
      cutter.ny = Math.round(cutter.nx / image.aspect_ratio);
      cutter.width = image.width;
      cutter.height = image.height;
      cutter.fluctuation = 0.3;
      cutter.irregularity = 0.2;
      puzzle.initizlize(image, cutter);
      new MergeCommand(puzzle.pieces[0], puzzle.pieces[1]).commit();
      new MergeCommand(puzzle.pieces[0], puzzle.pieces[2]).commit();
      new MergeCommand(puzzle.pieces[0], puzzle.pieces[4]).commit();
      new MergeCommand(puzzle.pieces[0], puzzle.pieces[6]).commit();
      new MergeCommand(puzzle.pieces[0], puzzle.pieces[8]).commit();
      new MergeCommand(puzzle.pieces[0], puzzle.pieces[9]).commit();
      return $("#info").text("" + cutter.count + " ( " + cutter.nx + " x " + cutter.ny + " )");
    };
    image.src = "asset/AA145_L.jpg";
    window.puzzle = puzzle;
    return window.onresize = function() {
      field.width = window.innerWidth;
      field.height = window.innerHeight;
      return puzzle.update();
    };
  });

}).call(this);
