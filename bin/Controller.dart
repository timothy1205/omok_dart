import 'Board.dart';
import 'ConsoleUI.dart';
import 'ResponseParser.dart';
import 'WebClient.dart';

enum Actor { player, server, none }
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

  void start() async {
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
    _gameLoop();
  }

  void _gameLoop() async {
    while (true) {
      _consoleUI.showBoard();
      var move = _consoleUI.promptMove();

      // Check if move is in our local board first
      if (!_board.isEmpty(move)) {
        _consoleUI.showMessage("Not empty!");
        continue;
      }

      try {
        var res = await _webClient!.getPlay(_pid, move);
      } on OmokPlayError catch(e) {
        _handlePlayError(e);
        continue;
      }

      _handleMove(res);
    }
  }

  void _handleMove(dynamic res) {
    bool endGame = false;
    // First check for player win/draw
    if (res["ack_move"]["isWin"]) {
      _board.setWinRow(res["ack_move"]["row"]);
      _winner = Actor.player;
      _endState = EndState.win;
    } else if (res["ack_move"]["isDraw"]) {
      _endState = EndState.draw;
    }
  }

  void _handlePlayError(OmokPlayError e) {
    if (!e.canHandle()) throw e; // If we can't handle it, throw it back up

    // Print out the message and proceed
    _consoleUI.showMessage(e.msg);
  }
}
