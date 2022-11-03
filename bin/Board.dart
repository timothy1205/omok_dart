class Board {
  static String Empty = ".";
  static String Player = "O";
  static String Server = "X";
  static String ServerLatest = "*";
  static String Win = "W";

  int size = -1;
  List<List<String>>? data;
  List<int>? _lastServerMove;

  createBoard() {
    // Generate a 2D array (list of lists) with every value defaulting to '.'
    // No list may be resized
    data = List.generate(size,
      (i) => List.filled(size, Empty, growable: false),
      growable: false);
  }

  bool isEmpty(List<int> move) {
    return data?[move[0]][move[1]] == Empty;
  }

  void setPlayer(List<int> move) {
    data?[move[0]][move[1]] = Player;
  }

  void setServer(List<int> move) {
    if (_lastServerMove != null) {
      // If we have a old latest server move,
      // change it to a normal Server character
      data?[_lastServerMove![0]][_lastServerMove![1]] = Server;
    }

    // Mark position as latest server move
    data?[move[0]][move[1]] = ServerLatest;
    _lastServerMove = move;
  }

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
