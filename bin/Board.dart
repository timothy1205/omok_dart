class Board {
  static String Empty = ".";
  static String Player = "O";
  static String Server = "X";
  static String ServerLatest = "*";
  static String Win = "W";

  int size = -1;
  List<List<String>>? data;
  List<int>? _lastServerMove;

  /// Generate 2D List with every value defaulting to Empty
  createBoard() {
    // No list may be resized
    data = List.generate(size,
      (i) => List.filled(size, Empty, growable: false),
      growable: false);
  }

  /// Check if a given pair of coordinates is an empty spot
  bool isEmpty(List<int> coords) {
    return data?[coords[0]][coords[1]] == Empty;
  }

  /// Set tile at coords to player stone
  void setPlayer(List<int> coords) {
    data?[coords[0]][coords[1]] = Player;
  }

  /// Set tile at coords to server stone
  void setServer(List<int> coords) {
    if (_lastServerMove != null) {
      // If we have a old latest server move,
      // change it to a normal Server character
      data?[_lastServerMove![0]][_lastServerMove![1]] = Server;
    }

    // Mark position as latest server move
    data?[coords[0]][coords[1]] = ServerLatest;
    _lastServerMove = coords;
  }

  /// Mark row tiles as Win stone
  void setWinRow(List<dynamic> row) {
    for (int i = 0; i < row.length; i += 2) {
      data?[row[i]][row[i + 1]] = Win;
    }

    if (_lastServerMove != null) {
      // Preserve last server move in case it was overriden
      data?[_lastServerMove![0]][_lastServerMove![1]] = ServerLatest;
    }
  }
}
