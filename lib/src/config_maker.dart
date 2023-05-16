import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter_config_maker/src/project_config.dart';
import 'package:flutter_config_maker/src/resolve.dart';
import 'package:flutter_config_maker/src/yaml_parser.dart';
import 'package:flutter_config_maker/util/util.dart';
import 'package:tuple/tuple.dart';

/// 默认的app配置文件所在目录的路径
const defaultAppConfigDirectory = 'config';

/// 默认的flutter配置文件生成的路径
const defaultFlutterConfigDefaultPath = 'lib/config/app_config.dart';

/// 默认的flutter配置生成类的名称
const defaultFlutterConfigDefaultClassName = 'AppConfig';

/// 默认的生成对应的平台，可选flutter,android,ios，默认只生成flutter平台
const defaultFlutterPlatform = 'flutter';
const defaultAndroidPlatform = 'android';
const defaultIOSPlatform = 'ios';
const defaultBuildPlatforms = [defaultFlutterPlatform];

class FlutterProject {
  FlutterProject(
    this.projectDirectory, {
    String? appConfigDirectory,
    String? flutterConfigPath,
    String? flutterConfigClassName,
    List<String>? buildPlatforms,
  })  : appConfigDirectory = appConfigDirectory ?? defaultAppConfigDirectory,
        flutterConfigPath = flutterConfigPath ?? defaultFlutterConfigDefaultPath,
        flutterConfigClassName = flutterConfigClassName ?? defaultFlutterConfigDefaultClassName,
        buildPlatforms = (buildPlatforms != null && buildPlatforms.isNotEmpty) ? buildPlatforms : defaultBuildPlatforms;

  /// 项目目录
  final Directory projectDirectory;

  /// app配置文件所在目录路径
  final String appConfigDirectory;

  /// flutter配置文件生成路径
  final String flutterConfigPath;

  /// flutter配置生成类名称
  final String flutterConfigClassName;

  /// 生成对应的平台
  final List<String> buildPlatforms;

  /// app 配置文件目录
  Directory? _appConfigsDirectory;

  Directory get appConfigsDirectory => _appConfigsDirectory ??= projectDirectory.childDirectory(appConfigDirectory);

  /// app 配置文件路径
  File? _appDefaultConfigFile;

  File get appDefaultConfigFile => _appDefaultConfigFile ??= appConfigsDirectory.childFile('app.yaml');

  /// flutter 配置文件路径
  File? _flutterConfigsFile;

  File get flutterConfigsFile => _flutterConfigsFile ??= projectDirectory.childFile(flutterConfigPath);

  /// android 子系统
  AndroidSubModule? _android;

  AndroidSubModule get android => _android ??= AndroidSubModule._(this);

  /// iOS 子系统
  IosSubModule? _ios;

  IosSubModule get ios => _ios ??= IosSubModule._(this);

  // ------------------------------- 创建配置文件 -------------------------------

  /// 创建配置文件
  Future<void> create() async {
    print("app配置文件所在目录的路径：$appConfigDirectory");
    print("flutter配置文件生成的路径：$flutterConfigPath");
    print("flutter配置生成类的名称：$flutterConfigClassName");
    print("生成对应的平台：$buildPlatforms");
    // 创建app配置文件所在目录
    await _createConfigDirectory();
    if (buildPlatforms.contains(defaultFlutterPlatform)) {
      await _createFlutterConfigFile();
    }
    if (buildPlatforms.contains(defaultAndroidPlatform)) {
      await _createAndroidConfigFile();
    }
    if (buildPlatforms.contains(defaultIOSPlatform)) {
      await _createIOSConfigFile();
    }
  }

  /// 创建app配置文件所在目录
  Future<void> _createConfigDirectory() async {
    if (appDefaultConfigFile.existsSync()) {
      print('创建app配置文件所在目录已存在，路径：${appDefaultConfigFile.path}');
      return;
    }
    // 创建app配置文件模板
    appDefaultConfigFile.createSync(recursive: true);
    // 模板文件
    Uri uri = await resolveUri(Uri.parse('package:flutter_config_maker/templates/app.yaml.tmpl'));
    var uriPath = uri.path;
    if (Platform.isWindows && uriPath.startsWith('/')) {
      uriPath = uriPath.replaceFirst('/', '');
    }
    var tmplFile = File(uriPath);
    if (!tmplFile.existsSync()) {
      throw BuildException('app.yaml.tmpl模板文件丢失');
    }
    String description = tmplFile.readAsStringSync();
    appDefaultConfigFile.writeAsStringSync(description);
    print('已创建app配置文件所在目录，路径：${appDefaultConfigFile.path}');
  }

  /// 创建flutter配置文件
  Future<void> _createFlutterConfigFile() async {
    if (flutterConfigsFile.existsSync()) {
      print('创建flutter模板配置文件已存在，路径：${flutterConfigsFile.path}');
      return;
    }
    flutterConfigsFile.createSync(recursive: true);
    String description = '''
// 该文件为自动生成，手动更改该文件，修改的内容，会被替换。
class $flutterConfigClassName {
  
}
''';
    flutterConfigsFile.writeAsStringSync(description);
    print('已创建flutter配置文件，路径：${flutterConfigsFile.path}');
  }

  /// 创建android配置文件
  Future<void> _createAndroidConfigFile() async {
    if (android.androidPropertiesFile.existsSync()) {
      print('创建android模板配置文件已存在，路径：${android.androidPropertiesFile.path}');
      return;
    }
    if (!android.androidPropertiesFile.existsSync()) {
      android.androidPropertiesFile.createSync(recursive: true);
      String description = '''
// 该文件为自动生成，手动更改该文件，修改的内容，会被替换。
// 需要在android/app/build.gradle文件配置
//    apply from: "config.gradle"
// 使用示例：project.ext.applicationId
project.ext {

}
''';
      android.androidPropertiesFile.writeAsStringSync(description);
      print('已创建android模板配置文件，路径：${android.androidPropertiesFile.path}');
    }
  }

  /// 创建iOS配置文件
  Future<void> _createIOSConfigFile() async {
    // TODO:创建iOS配置文件
  }

  // ------------------------------- 生成配置文件 -------------------------------

  /// 生成文件
  Future<void> build(String? commandEnvType, bool? replaceFiles) async {
    print("app配置文件所在目录的路径：$appConfigDirectory");
    print("flutter配置文件生成的路径：$flutterConfigPath");
    print("flutter配置生成类的名称：$flutterConfigClassName");
    print("生成对应的平台：$buildPlatforms");
    print("生成对应的环境：$commandEnvType");
    print("是否需要替换文件：$replaceFiles");

    var defaultConfig = _loadDefaultConfig();
    var otherConfigs = _loadOthersConfigs();
    var parseConfig = _parseConfigs(commandEnvType, defaultConfig, otherConfigs);

    if (buildPlatforms.contains(defaultFlutterPlatform)) {
      _makeFlutterConfigs(commandEnvType, defaultConfig, otherConfigs);
      // _updateFlutterConfigs(commandEnvType, parseConfig, otherConfigs);
    }
    if (buildPlatforms.contains(defaultAndroidPlatform)) {
      _updateAndroidConfigs(parseConfig);
    }
    if (buildPlatforms.contains(defaultIOSPlatform)) {
      _updateIOSConfigs(parseConfig);
    }
    if (replaceFiles == true) {
      _replaceFiles(parseConfig);
    }
  }

  /// 加载默认配置
  Tuple2<File, YamlParser> _loadDefaultConfig() {
    if (!appDefaultConfigFile.existsSync()) {
      throw BuildException.NO_CREATE;
    }
    YamlParser defaultYamlParser = YamlParser.createFromPath(appDefaultConfigFile.path);
    return Tuple2(appDefaultConfigFile, defaultYamlParser);
  }

  /// 加载除了默认配置的其他配置
  List<Tuple2<File, YamlParser>> _loadOthersConfigs() {
    var yamlFiles = appConfigsDirectory.listSync();
    yamlFiles.removeWhere((element) => element.path.endsWith('app.yaml'));
    return yamlFiles.map((element) => Tuple2(File(element.path), YamlParser.createFromPath(element.path))).toList();
  }

  /// 解析配置，返回解析后的配置
  /// [commandEnvType] 命令行输入的环境变量参数
  /// [defaultConfig] 默认的配置
  /// [otherConfigs] 其他的配置
  /// 返回[解析后的配置]
  YamlParser _parseConfigs(String? commandEnvType, Tuple2<File, YamlParser> defaultConfig, List<Tuple2<File, YamlParser>> otherConfigs) {
    var defaultYamlParser = YamlParser.createFromPath(defaultConfig.item1.path);
    var envActive = commandEnvType ?? defaultYamlParser.envActive;
    print("当前激活的环境：$envActive");
    if (envActive != null && (envActive.trim().isNotEmpty)) {
      var activeConfig = otherConfigs.firstWhereOrNull((element) => element.item1.fileName == 'app-${envActive.trim()}.yaml');
      if (activeConfig == null) {
        throw BuildException('激活的配置文件不存在，请检查文件是否存在:${'app-${envActive.trim()}.yaml'}');
      }
      YamlParser activeYamlParser = activeConfig.item2;
      // 解析flutter配置
      for (var element1 in activeYamlParser.flutterConfigs) {
        var findConfig = defaultYamlParser.flutterConfigs.firstWhereOrNull((element2) => element1.name == element2.name);
        if (findConfig != null) {
          defaultYamlParser.flutterConfigs.firstWhereOrNull((element2) => element1.name == element2.name)?.value = element1.value;
        } else {
          defaultYamlParser.flutterConfigs.add(element1);
        }
      }
      // 解析android配置
      for (var element1 in activeYamlParser.androidConfigs) {
        var findConfig = defaultYamlParser.androidConfigs.firstWhereOrNull((element2) => element1.name == element2.name);
        if (findConfig != null) {
          defaultYamlParser.androidConfigs.firstWhereOrNull((element2) => element1.name == element2.name)?.value = element1.value;
        } else {
          defaultYamlParser.androidConfigs.add(element1);
        }
      }
      // 解析ios配置
      for (var element1 in activeYamlParser.iosConfigs) {
        var findConfig = defaultYamlParser.iosConfigs.firstWhereOrNull((element2) => element1.name == element2.name);
        if (findConfig != null) {
          defaultYamlParser.iosConfigs.firstWhereOrNull((element2) => element1.name == element2.name)?.value = element1.value;
        } else {
          defaultYamlParser.iosConfigs.add(element1);
        }
      }
      // 解析替换文件配置
      for (var element1 in activeYamlParser.replaceFiles) {
        var findConfig = defaultYamlParser.replaceFiles.firstWhereOrNull((element2) => element1.source == element2.source);
        if (findConfig != null) {
          defaultYamlParser.replaceFiles.firstWhereOrNull((element2) => element1.source == element2.source)?.target = element1.target;
        } else {
          defaultYamlParser.replaceFiles.add(element1);
        }
      }
    }

    print("当前激活的环境配置：flutter:${defaultYamlParser.flutterConfigs.map((e) => '${e.name}:${e.value}').toList()}");
    print("当前激活的环境配置：android:${defaultYamlParser.androidConfigs.map((e) => '${e.name}:${e.value}').toList()}");
    print("当前激活的环境配置：ios:${defaultYamlParser.iosConfigs.map((e) => '${e.name}:${e.value}').toList()}");
    print("当前激活的环境配置：replace_files:${defaultYamlParser.replaceFiles.map((e) => '${e.source}:${e.target}').toList()}");
    return defaultYamlParser;
  }

  /// 更新android配置文件
  /// [parseAppYamlParser] 解析后的配置
  void _updateAndroidConfigs(YamlParser parseAppYamlParser) {
    String content = '''
// 该文件为自动生成，手动更改该文件，修改的内容，会被替换。
// 需要在android/app/build.gradle文件配置
//    apply from: "config.gradle"
// 使用示例：project.ext.applicationId
project.ext {
${() {
      String content = parseAppYamlParser.androidConfigs.map((e) {
        return '  ${e.name} = ${() {
          if (e.type == ProjectConfigValueType.TYPE_STRING) {
            return "\"${e.value}\"";
          }
          return e.value;
        }()}';
      }).join('\n');
      return content;
    }()}
}
''';
    android.androidPropertiesFile.writeAsStringSync(content);
  }

  /// 更新ios配置文件
  /// [parseAppYamlParser] 解析后的配置
  void _updateIOSConfigs(YamlParser parseAppYamlParser) {
    // TODO:更新iOS配置文件
  }

  /// 更新flutter配置文件
  /// [commandEnvType] 命令行输入的环境变量参数
  /// [parseAppYamlParser] 解析后的配置
  /// [otherConfigs] 其他的配置
  void _updateFlutterConfigs(String? commandEnvType, YamlParser parseAppYamlParser, List<Tuple2<File, YamlParser>> otherConfigs) {
    var envActive = commandEnvType ?? parseAppYamlParser.envActive;
    var listEnvTypes = _envTypeList(otherConfigs);

    String content = '''
/// 该文件为自动生成，手动更改该文件，修改的内容，会被替换。
class $flutterConfigClassName {
${() {
      if (envActive == null || envActive.isEmpty) {
        return '  static const EnvType _defaultEnvActive = EnvType.none;';
      }
      return '  static const EnvType _defaultEnvActive = EnvType.$envActive;';
    }()}

  static EnvType? _runEnvType;

  static EnvType get runEnvType {
    if (_runEnvType != null) return _runEnvType!;
    const value = String.fromEnvironment('env_type', defaultValue: '${envActive ?? ''}');
    if (value.isNotEmpty) {
${() {
      if (listEnvTypes.isEmpty) return '';
      return '''
      switch (value) {
${() {
        return listEnvTypes.map((e) => '        case \'$e\':\n          _runEnvType = EnvType.$e;\n          break;').join('\n');
      }()}
      }''';
    }()}
    }
    _runEnvType ??= _defaultEnvActive;
    return _runEnvType!;
  }

${() {
      String content = parseAppYamlParser.flutterConfigs.map((e) {
        switch (e.type) {
          case ProjectConfigValueType.TYPE_INT:
            return '  static const int ${e.name} = ${e.value};';
          case ProjectConfigValueType.TYPE_DOUBLE:
            return '  static const double ${e.name} = ${e.value};';
          case ProjectConfigValueType.TYPE_BOOL:
            return '  static const bool ${e.name} = ${e.value};';
          case ProjectConfigValueType.TYPE_STRING:
          default:
            return '  static const String ${e.name} = \'${e.value}\';';
        }
      }).join('\n');
      return content;
    }()}
}

enum EnvType {
  none,${() {
      if (listEnvTypes.isEmpty) {
        return '';
      }
      return '\n' + listEnvTypes.map((e) => '  $e,').join('\n');
    }()}
}
''';
    flutterConfigsFile.writeAsStringSync(content);
  }

  /// 生成Flutter配置类
  /// [commandEnvType] 命令行输入的环境变量参数
  /// [defaultConfig] 默认的配置
  /// [otherConfigs] 其他的配置
  void _makeFlutterConfigs(String? commandEnvType, Tuple2<File, YamlParser> defaultConfig, List<Tuple2<File, YamlParser>> otherConfigs) {
    var envActive = commandEnvType ?? defaultConfig.item2.envActive;
    var listEnvTypes = _envTypeList(otherConfigs);

    // 环境 - 类名 - 属性
    var listYamlParsers = <Tuple3<String, String, YamlParser>>[];
    for (var element in listEnvTypes) {
      var className = flutterConfigClassName + element.substring(0, 1).toUpperCase() + element.substring(1);
      var findConfig = otherConfigs.firstWhereOrNull((element2) => element2.item1.fileName == 'app-$element.yaml');
      assert(findConfig != null, "代码逻辑错误，找不到${'app-$element.yaml'}文件");
      listYamlParsers.add(Tuple3<String, String, YamlParser>(element, className, findConfig!.item2));
    }

    var mixFlutterConfigs = defaultConfig.item2.flutterConfigs.shallowCopy();
    for (var element in otherConfigs) {
      var mixFlutterConfigsNames = mixFlutterConfigs.map((e) => e.name).toList();
      for (var element2 in element.item2.flutterConfigs) {
        if (!mixFlutterConfigsNames.contains(element2.name)) {
          mixFlutterConfigs.add(element2);
        }
      }
    }

    String content = '''
/// 该文件为自动生成，手动更改该文件，修改的内容，会被替换。
class $flutterConfigClassName {
${() {
      if (envActive == null || envActive.isEmpty) {
        return '  static const EnvType _defaultEnvActive = EnvType.none;';
      }
      return '  static const EnvType _defaultEnvActive = EnvType.$envActive;';
    }()}

  static EnvType? _runEnvType;

  static EnvType get runEnvType {
    if (_runEnvType != null) return _runEnvType!;
    const value = String.fromEnvironment('env_type', defaultValue: '${envActive ?? ''}');
    if (value.isNotEmpty) {
${() {
      if (listEnvTypes.isEmpty) return '';
      return '''
      switch (value) {
${() {
        return listEnvTypes.map((e) => '        case \'$e\':\n          _runEnvType = EnvType.$e;\n          break;').join('\n');
      }()}
      }''';
    }()}
    }
    _runEnvType ??= _defaultEnvActive;
    return _runEnvType!;
  }

${() {
      return mixFlutterConfigs.map((e) {
        var pickYamlParsers = listYamlParsers.takeWhile((element1) {
          return element1.item3.flutterConfigs.firstWhereOrNull((element2) => element2.name == e.name) != null;
        });

        String content = () {
          if (pickYamlParsers.isEmpty) {
            // 没有找到其他配置，使用的是默认的配置
            switch (e.type) {
              case ProjectConfigValueType.TYPE_INT:
                return '    return ${e.value};';
              case ProjectConfigValueType.TYPE_DOUBLE:
                return '    return ${e.value};';
              case ProjectConfigValueType.TYPE_BOOL:
                return '    return ${e.value};';
              case ProjectConfigValueType.TYPE_STRING:
              default:
                return '    return \'${e.value}\';';
            }
          } else {
            return '''
    switch (runEnvType) {
${() {
              return pickYamlParsers.map((e2) => '''
      case EnvType.${e2.item1}:
        return ${e2.item2}.${e.name};''').join('\n');
            }()}
      default:
        return ${() {
              bool isDefault = defaultConfig.item2.flutterConfigs.map((e2) => e2.name).toList().contains(e.name);
              if (isDefault) {
                switch (e.type) {
                  case ProjectConfigValueType.TYPE_INT:
                    return '${e.value};';
                  case ProjectConfigValueType.TYPE_DOUBLE:
                    return '${e.value};';
                  case ProjectConfigValueType.TYPE_BOOL:
                    return '${e.value};';
                  case ProjectConfigValueType.TYPE_STRING:
                  default:
                    return '\'${e.value}\';';
                }
              } else {
                var activeYamlParser = listYamlParsers.firstWhereOrNull((element) => element.item1 == envActive);
                return '${activeYamlParser?.item2}.${e.name};';
              }
            }()}
    }''';
          }
        }();

        switch (e.type) {
          case ProjectConfigValueType.TYPE_INT:
            return '''  static int get ${e.name} {
$content
  }''';
          case ProjectConfigValueType.TYPE_DOUBLE:
            return '''  static double get ${e.name} {
$content
  }''';
          case ProjectConfigValueType.TYPE_BOOL:
            return '''  static bool get ${e.name} {
$content
  }''';
          case ProjectConfigValueType.TYPE_STRING:
          default:
            return '''  static String get ${e.name} {
$content
  }''';
        }
      }).join('\n\n');
    }()}
}

${() {
      return listYamlParsers
          .map((e) => '''
class ${e.item2} {
${() {
                String content = e.item3.flutterConfigs.map((e) {
                  switch (e.type) {
                    case ProjectConfigValueType.TYPE_INT:
                      return '  static const int ${e.name} = ${e.value};';
                    case ProjectConfigValueType.TYPE_DOUBLE:
                      return '  static const double ${e.name} = ${e.value};';
                    case ProjectConfigValueType.TYPE_BOOL:
                      return '  static const bool ${e.name} = ${e.value};';
                    case ProjectConfigValueType.TYPE_STRING:
                    default:
                      return '  static const String ${e.name} = \'${e.value}\';';
                  }
                }).join('\n');
                return content;
              }()}
}''')
          .join('\n\n');
    }()}

enum EnvType {
  none,
${() {
      return listEnvTypes.map((e) => '  $e,').join('\n');
    }()}
}
''';
    flutterConfigsFile.writeAsStringSync(content);
  }

  /// 获取环境变量类型集合
  List<String> _envTypeList(List<Tuple2<File, YamlParser>> otherConfigs) {
    var listEnvTypes = <String>[];
    for (var element in otherConfigs) {
      var tempFile = File(element.item1.path);
      var env = tempFile.fileNameWithoutExtension.substring(tempFile.fileNameWithoutExtension.indexOf('-') + 1);
      listEnvTypes.add(env);
    }
    print('当前已配置如下环境：$listEnvTypes');
    return listEnvTypes;
  }

  /// 替换文件
  void _replaceFiles(YamlParser appYamlParser) {
    for (var element in appYamlParser.replaceFiles) {
      var sourceFile = projectDirectory.childFile(element.source);
      var targetFile = projectDirectory.childFile(element.target);
      print('正在替换文件：sourceFile：${sourceFile.path} -> targetFile：${targetFile.path}');
      if (!sourceFile.existsSync()) {
        throw BuildException('替换的文件不存在，请检查，sourceFile：${sourceFile.path}');
      }
      if (!targetFile.existsSync()) {
        targetFile.createSync(recursive: true);
      }
      targetFile.writeAsBytesSync(sourceFile.readAsBytesSync());
    }
  }
}

class AndroidSubModule {
  final FlutterProject parent;

  AndroidSubModule._(this.parent);

  /// android工程的目录
  Directory? _androidDirectory;

  Directory get androidDirectory => _androidDirectory ??= parent.projectDirectory.childDirectory('android');

  /// android配置文件路径
  File? _androidPropertiesFile;

  File get androidPropertiesFile => _androidPropertiesFile ??= androidDirectory.childFile('app/config.gradle');
}

class IosSubModule {
  final FlutterProject parent;

  IosSubModule._(this.parent);
}

class BuildException implements Exception {
  static final NO_CREATE = BuildException("配置文件未被创建，请先使用create进行创建");

  final String msg;

  BuildException(this.msg);

  @override
  String toString() => msg;
}
