import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:flutter_config_maker/entrypoint/runner.dart';
import 'package:io/ansi.dart';
import 'package:io/io.dart';

Future<void> main(List<String> args) async {
  var commandRunner = BuildCommandRunner();

  ArgResults parsedArgs;
  try {
    parsedArgs = commandRunner.parse(args);
  } on UsageException catch (e) {
    log(red.wrap(e.message) ?? "");
    log('');
    log(e.usage);
    exitCode = ExitCode.usage.code;
    return;
  }

  await commandRunner.runCommand(parsedArgs);
}
