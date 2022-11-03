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
  static List<String> _unhandleable = ["Pid not specified", "Unknown pid", "Move not specified", "Move not well-formed"];
  OmokPlayError(String msg) : super(msg);

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
    _handleError(data);

    // We can just return the pid if no error occured
    return data["pid"];
  }

  static dynamic parsePlay(Response res) {
    var data = jsonDecode(res.body);
    _handleError(data);

    // Remove response field
    data.remove("response");

    return data;
  }

  static List<int> parseMove(Map object) {
    return [object["x"], object["y"]];
  }

  // Determine if response was an error
  static void _handleError<T>(data) {
    if (!data["response"]) {
      // Bad response, throw
      if (T is OmokNewError) {
        throw OmokNewError(data["msg"]);
      } else if (T is OmokPlayError) {
        throw OmokPlayError(data["msg"]);
      }
    }
  }
}
