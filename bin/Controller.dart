// Timothy Gonzales
// Dart TUI Omok Client

import 'Board.dart';
import 'ConsoleUI.dart';
import 'ResponseParser.dart';
import 'WebClient.dart';

/// The actor that may win the game.
enum Actor { player, server, none }
/// The end state of the game, if we reached the end.
enum EndState { win, draw, none }

class Controller {

  final String defaultUrl = "https://www.cs.utep.edu/cheon/cs3360/project/omok";
  final int defaultStrategy = 0;

  final Board _board = Board();
  late final ConsoleUI _consoleUI = ConsoleUI(_board);

  WebClient? _webClient;
  String _pid = "";
  Actor _winner = Actor.none;
  EndState _endState = EndState.none;

  /// Start the game client
  Future start() async {
    // First connect to the server
    var result = _consoleUI.promptServer(defaultUrl);
    var url = result ?? defaultUrl;

    _webClient = WebClient(url);

    _consoleUI.showMessage("Obtaining server information ......");
    var info = await _webClient!.getInfo();
    _board.size = info["size"];

    // Get strategy so we can begin game
    var strat = _consoleUI.promptStrategy(info["strategies"], defaultStrategy) ?? defaultStrategy;

    // Strategy not specified and unknown strategy errors can occur,
    // but not if our application is properly made. Therefore we can just
    // let the program crash with its error.
    _consoleUI.showMessage("Creating a new game ......");
    _pid = await _webClient!.getNew(info["strategies"][strat]);

    // If our game succeeded, create a new board
    _board.createBoard();

    // Begin game loop
    return _gameLoop();
  }

  /// Start while loop for game client
  Future _gameLoop() async {
    while (true) {

      _consoleUI.showBoard();

      // Check for end of game
      if (_handleEndGame()) return;

      // Keep asking for move until we get a valid one
      List<int> move;
      while (true) {
        move = _consoleUI.promptMove();

        // Check if move is in our local board first
        if (!_board.isEmpty(move)) {
          _consoleUI.showMessage("Not empty!");
        } else {
          break;
        }
      }

      // Send move to server
      dynamic res;
      try {
        res = await _webClient!.getPlay(_pid, move);
      } on OmokPlayError catch(e) {
        _handlePlayError(e);
        continue;
      }

      _handleMove(res);
    }
  }

  /// Handle the result of a getPlay call
  void _handleMove(dynamic res) {
    // First check for player win/draw
    if (res["ack_move"]["isWin"]) {
      // Player win
      _board.setWinRow(res["ack_move"]["row"]);
      _winner = Actor.player;
      _endState = EndState.win;
      return;
    } else if (res["ack_move"]["isDraw"]) {
      // Draw on player move
      _board.setPlayer(ResponseParser.parseMove(res["ack_move"]));
      _endState = EndState.draw;
      return;
    }

    // Non game ending move will just be registered
    _board.setPlayer(ResponseParser.parseMove(res["ack_move"]));

    // If we haven't returned then
    // there must be a response move

    // Check for server win/draw
    if (res["move"]["isWin"]) {
      // Server win
      _board.setServer(ResponseParser.parseMove(res["move"]));
      _board.setWinRow(res["move"]["row"]);
      _winner = Actor.server;
      _endState = EndState.win;
      return;
    } else if (res["move"]["isDraw"]) {
      // Draw on server move
      _board.setServer(ResponseParser.parseMove(res["move"]));
      _endState = EndState.draw;
      return;
    }

    _board.setServer(ResponseParser.parseMove(res["move"]));
  }

  /// Check for and handle the end of the game.
  ///
  /// Returns true to stop the gameLoop, false to keep going.
  bool _handleEndGame() {
    switch (_endState) {
      case EndState.draw: {
        _consoleUI.showMessage("It's a draw!");
        return true;
      }
      case EndState.win: {
        if (_winner == Actor.server) {
          _consoleUI.showMessage("You lose :(");
        } else {
          _consoleUI.showMessage("You win!");
        }
        return true;
      }
      default: {
        // Game isn't over
        return false;
      }
    }
  }

  /// Handle potential game errors
  void _handlePlayError(OmokPlayError e) {
    if (!e.canHandle()) throw e; // If we can't handle it, throw it back up

    // Print out the message and proceed
    _consoleUI.showMessage(e.msg);
  }
}
