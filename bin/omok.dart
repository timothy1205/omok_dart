// Timothy Gonzales
// Dart TUI Omok Client

import 'dart:io';
import 'Controller.dart';

void main() async {
  await Controller().start();

  stdout.writeln("\nQuitting...");
}
