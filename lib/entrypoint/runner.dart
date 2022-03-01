import 'dart:convert';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';

import 'base_command.dart' show lineLength;
import 'build.dart';
import 'create.dart';

class BuildCommandRunner extends CommandRunner<int> {
  @override
  final argParser = ArgParser(usageLineLength: lineLength);

  BuildCommandRunner() : super('flutter_config_maker', 'flutter配置文件生成器') {
    addCommand(CreateCommand());
    addCommand(BuildCommand());
  }

  /// Returns [usage] with [description] removed from the beginning.
  String get usageWithoutDescription => LineSplitter.split(usage).skipWhile((line) => line == description || line.isEmpty).join('\n');
}
