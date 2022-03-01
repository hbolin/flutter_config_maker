import 'dart:async';
import 'dart:io';

import 'package:flutter_config_maker/flutter_config_maker.dart';

import 'base_command.dart';
import 'options.dart';

class CreateCommand extends BuildRunnerCommand {
  @override
  String get invocation => 'flutter_config_maker create';

  @override
  String get name => 'create';

  @override
  String get description => '''创建默认的.yaml配置文件和.dart配置文件''';

  @override
  Future<int> run() async {
    var flutterProject = FlutterProject(
      Directory.current,
      appConfigDirectory: argResults?[configDirectoryOption],
      flutterConfigPath: argResults?[targetPathOption],
      flutterConfigClassName: argResults?[targetClassNameOption],
      buildPlatforms: argResults?[buildPlatformOption],
    );
    flutterProject.create();
    return 0;
  }
}
