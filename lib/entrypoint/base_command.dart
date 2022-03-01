import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:flutter_config_maker/flutter_config_maker.dart';

import 'options.dart';

final lineLength = stdout.hasTerminal ? stdout.terminalColumns : 80;

abstract class BuildRunnerCommand extends Command<int> {
  @override
  final argParser = ArgParser(usageLineLength: lineLength);

  BuildRunnerCommand() {
    // 这边追加的是基础的options，会针对所有的命令生效。
    _addBaseFlags();
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
        help: '''生成对应的平台，可选:[$defaultFlutterPlatform,$defaultAndroidPlatform,$defaultIOSPlatform]，默认值:$defaultFlutterPlatform''',
      );
  }
}
