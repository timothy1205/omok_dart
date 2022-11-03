import 'dart:io';
import 'package:http/http.dart';
import 'package:http/io_client.dart';

import 'ResponseParser.dart';

class WebClient {
  var _client;
  final String _url;

  WebClient(this._url) {
    // Create client that ignores SSL cert errors since UTEP website gives me issues
    HttpClient httpClient = HttpClient()..badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    this._client = IOClient(httpClient);
  }

  dynamic getInfo() async {
    var res = await _client.get(Uri.parse("$_url/info"));
    return ResponseParser.parseInfo(res);
  }

  dynamic getNew(String strategy) async {
    var res = await _client.get(Uri.parse("$_url/new?strategy=$strategy"));
    return ResponseParser.parseNew(res);
  }

  dynamic getPlay(String pid, List<int> move) async {
    while (true) {
      // For some reason I sometimes get seemingly random
      // client exception, so just keep retrying until
      // a response is received
      //
      // I suspect its something to do with HttpClient,
      // but I still need it for the SSL cert error
      try {
        var res = await _client.get(Uri.parse("$_url/play?pid=$pid&move=${move[0]},${move[1]}"));
        return ResponseParser.parsePlay(res);
      } on ClientException catch (e) {}
    }

  }
}
