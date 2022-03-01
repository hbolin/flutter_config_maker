import 'dart:async';
import 'dart:io';

import 'package:flutter_config_maker/flutter_config_maker.dart';

import 'base_command.dart';
import 'options.dart';

class CreateCommand extends BuildRunnerCommand {
  CreateCommand() {
    // 这边追加的是基础的options，就是针对"create"的命令生效
    // _addBaseFlags();
  }

  void _addBaseFlags() {
    argParser
      ..addOption(
        configDirectoryOption,
        help: '''app配置文件所在目录的路径，默认值:$defaultAppConfigDirectory''',
      )
      ..addOption(
        targetPathOption,
        help: '''flutter配置文件生成的路径，默认值:$defaultFlutterConfigDefaultPath''',
      )
      ..addOption(
        targetClassNameOption,
        help: '''flutter配置生成类的名称，默认值:$defaultFlutterConfigDefaultClassName''',
      )
      ..addMultiOption(
        buildPlatformOption,
        help: '''生成对应的平台，可选:$defaultBuildPlatforms''',
      );
  }

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
