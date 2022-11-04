// Timothy Gonzales
// Dart TUI Omok Client

import 'dart:convert';
import 'package:http/http.dart';

class OmokException implements Exception {
  String msg;

  OmokException(this.msg);

  @override
  String toString() {
    return msg;
  }
}

class OmokNewError extends OmokException {
  OmokNewError(String msg) : super(msg);
}

class OmokPlayError extends OmokException {
  /// List of possible error messages that cannot be ignored
  static final List<String> _unhandleable = ["Pid not specified", "Unknown pid", "Move not specified", "Move not well-formed"];
  OmokPlayError(String msg) : super(msg);

  /// Determine if current error can be ignored or not (should be caught)
  bool canHandle() {
    return !_unhandleable.contains(msg);
  }
}

class ResponseParser {
  static dynamic parseInfo(Response res) {
    // No special errors to handle
    return jsonDecode(res.body);
  }

  static dynamic parseNew(Response res) {
    var data = jsonDecode(res.body);
    _handleError<OmokNewError>(data);

    // We can just return the pid if no error occured
    return data["pid"];
  }

  static dynamic parsePlay(Response res) {
    var data = jsonDecode(res.body);
    _handleError<OmokPlayError>(data);

    // Response field no longer needed if not an error
    data.remove("response");

    return data;
  }

  static List<int> parseMove(Map object) {
    return [object["x"], object["y"]];
  }

  /// Determine if response was an error
  static void _handleError<T>(data) {
    if (!data["response"]) {
      // Bad response, throw correct error
      if (T is OmokNewError) {
        throw OmokNewError(data["msg"]);
      } else if (T is OmokPlayError) {
        throw OmokPlayError(data["msg"]);
      }
    }
  }
}
