import 'dart:async';
import 'dart:io';

import 'package:flutter_config_maker/flutter_config_maker.dart';

import 'base_command.dart';
import 'options.dart';

class BuildCommand extends BuildRunnerCommand {
  BuildCommand() {
    // 这边追加的是基础的options，就是针对"build"的命令生效
    _addBaseFlags();
  }

  void _addBaseFlags() {
    argParser
      ..addOption(
        buildEnvType,
        help: '''生成对应的环境，如果没有指定，则使用app.yaml中env.active的值''',
      )
      ..addFlag(
        buildReplaceFile,
        defaultsTo: false,
        help: '''是否需要替换文件，默认值：false''',
      );
  }

  @override
  String get invocation => 'flutter_config_maker build';

  @override
  String get name => 'build';

  @override
  String get description => '''根据.yaml文件集合生成.dart配置文件。''';

  @override
  Future<int> run() async {
    var flutterProject = FlutterProject(
      Directory.current,
      appConfigDirectory: argResults?[configDirectoryOption],
      flutterConfigPath: argResults?[targetPathOption],
      flutterConfigClassName: argResults?[targetClassNameOption],
      buildPlatforms: argResults?[buildPlatformOption],
    );
    flutterProject.build(argResults?[buildEnvType], argResults?[buildReplaceFile]);
    return 0;
  }
}
