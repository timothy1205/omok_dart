import 'dart:io';
import 'Board.dart';

class ConsoleUI {
  Board _board;

  ConsoleUI(this._board);

  void showMessage(String msg) {
    stdout.writeln(msg);
  }

  String? promptServer(String defaultUrl) {
    stdout.write("Enter the server URL [default: $defaultUrl]");
    var line = stdin.readLineSync();

    // Use given url or default if nothing given
    String url;
    if (line == null || line.isEmpty) return null;

    return line;
  }

  int? promptStrategy(List strategies, int defaultStrategy) {
    defaultStrategy++; // Start at 1

    while (true) {
      // Keep requesting valid strategy from user till one is given

      stdout.write("Select server strategy: ");
      for (int i = 1; i <= strategies.length; i++) {
        var strategy = strategies[i-1];
        stdout.write("$i. $strategy ");

        if (i != strategies.length) {
          stdout.write(", ");
        }
      }
      stdout.write("[default: $defaultStrategy] ");

      var line = stdin.readLineSync();
      var selection;
      if (line != null && line.isNotEmpty) {
        try {
          selection = int.parse(line);
        } on FormatException {
          stdout.writeln("Invalid selection: $line");
          continue;
        }
      }

      if (selection == null) return null;

      var selection_real = selection - 1;
      if (selection_real < 0 || selection_real >= strategies.length) {
        stdout.writeln("Invalid selection: $selection");
        continue;
      }

      return selection_real;
    }
  }

  List<int> promptMove() {
    mainLoop:
    while (true) {
      stdout.write("Enter x and y (1-${_board.size}, eg.. 8 10): ");
      var line = stdin.readLineSync();
      if (line == null || line.isEmpty) continue;

      List<String> split;
      if (line.contains(",")) {
        split = line.split(",");
      } else {
        split = line.split(" ");
      }

      // We need at least two indices
      if (split.length < 2) {
        stdout.writeln("Invalid index!");
        continue;
      }

      List<int> coords = [];
      // Parse all values in list to int
      for (int i = 0; i < split.length; i++) {
        int coord;
        try {
          coord = int.parse(split[i]);
        } on FormatException {
          stdout.writeln("Invalid index!");
          continue mainLoop;
        }

        // Ensure indices are within size
        if (coord < 1 || coord > _board.size) {
          stdout.writeln("Invalid index!");
          continue mainLoop;
        }

        coords.add(coord - 1);
      }

      return coords;
    }
  }

  void showBoard() {
    if (_board.data == null) {
      throw Exception("Board must be created first!");
    }

    var xAxis = List<int>.generate(_board.size,
      (i) => (i + 1) % 10).join(' '); // 1 - 9, 0, 1 - 5 (assuming size 15)
    stdout.writeln("x: $xAxis");
    stdout.writeln("y:");

    var y = 1;
    for (var row in _board.data!) {
      var line = row.join(' ');
      stdout.writeln("${y++ % 10}| $line");
    }

    stdout.writeln("\nPlayer: ${Board.Player}, Server: ${Board.Server} (and ${Board.ServerLatest})");
  }
}
