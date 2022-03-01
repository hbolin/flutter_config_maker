import 'dart:io';

import 'package:flutter_config_maker/src/project_config.dart';
import 'package:yaml/yaml.dart';

/// yaml文件解析器
class YamlParser {
  YamlParser._();

  String? get envActive {
    if (_descriptor == null) return null;
    Map<dynamic, dynamic>? envMap = _descriptor!['env'] as Map<dynamic, dynamic>?;
    if (envMap != null) {
      return envMap['active'];
    }
    return null;
  }

  List<ProjectConfig>? _flutterConfigs;
  List<ProjectConfig> get flutterConfigs => _flutterConfigs ??= _parseSubDescriptor(_flutterDescriptor!);

  List<ProjectConfig>? _androidConfigs;
  List<ProjectConfig> get androidConfigs => _androidConfigs ??= _parseSubDescriptor(_androidDescriptor!);

  List<ProjectConfig>? _iosConfigs;
  List<ProjectConfig> get iosConfigs => _iosConfigs ??= _parseSubDescriptor(_iosDescriptor!);

  List<ReplaceFile>? _replaceFiles;
  List<ReplaceFile> get replaceFiles => _replaceFiles ??= _parseReplaceFilesDescriptor(_replaceFilesDescriptor!);

  Map<String, dynamic>? _descriptor;
  Map<String, dynamic>? _flutterDescriptor;
  Map<String, dynamic>? _androidDescriptor;
  Map<String, dynamic>? _iosDescriptor;
  Map<String, dynamic>? _replaceFilesDescriptor;

  static YamlParser createFromPath(String path) {
    String manifest = File(path).readAsStringSync();
    return YamlParser.createFromString(manifest);
  }

  static YamlParser createFromString(String manifest) {
    dynamic yamlDocument = loadYaml(manifest);
    return _parse(yamlDocument);
  }

  static YamlParser _parse(dynamic yamlDocument) {
    final YamlParser pubspec = YamlParser._();
    final Map<dynamic, dynamic>? yamlMap = yamlDocument as YamlMap;
    if (yamlMap != null) {
      pubspec._descriptor = yamlMap.cast<String, dynamic>();
    } else {
      pubspec._descriptor = <String, dynamic>{};
    }

    final Map<dynamic, dynamic>? flutterMap = pubspec._descriptor!['flutter'] as Map<dynamic, dynamic>?;
    if (flutterMap != null) {
      pubspec._flutterDescriptor = flutterMap.cast<String, dynamic>();
    } else {
      pubspec._flutterDescriptor = <String, dynamic>{};
    }

    final Map<dynamic, dynamic>? androidMap = pubspec._descriptor!['android'] as Map<dynamic, dynamic>?;
    if (androidMap != null) {
      pubspec._androidDescriptor = androidMap.cast<String, dynamic>();
    } else {
      pubspec._androidDescriptor = <String, dynamic>{};
    }

    final Map<dynamic, dynamic>? iosMap = pubspec._descriptor!['ios'] as Map<dynamic, dynamic>?;
    if (iosMap != null) {
      pubspec._iosDescriptor = iosMap.cast<String, dynamic>();
    } else {
      pubspec._iosDescriptor = <String, dynamic>{};
    }

    final Map<dynamic, dynamic>? replaceFilesMap = pubspec._descriptor!['replace_files'] as Map<dynamic, dynamic>?;
    if (replaceFilesMap != null) {
      pubspec._replaceFilesDescriptor = replaceFilesMap.cast<String, dynamic>();
    } else {
      pubspec._replaceFilesDescriptor = <String, dynamic>{};
    }
    return pubspec;
  }

  List<ProjectConfig> _parseSubDescriptor(Map<String, dynamic> _descriptor) {
    List<ProjectConfig> configs = [];
    _descriptor.forEach((key, value) {
      if (value is! Map) {
        // 自动解析值类型
        configs.add(ProjectConfig(key, value.runtimeType.toString(), value));
      } else {
        // 强制设置值类型
        final Map<dynamic, dynamic> valueMap = value;
        configs.add(ProjectConfig(key, valueMap['type'].toString(), valueMap['value'].toString()));
      }
    });
    return configs;
  }

  List<ReplaceFile> _parseReplaceFilesDescriptor(Map<String, dynamic> _descriptor) {
    List<ReplaceFile> configs = [];
    _descriptor.forEach((key, value) {
      if (value is Map) {
        if (value['source'] != null && value['target'] != null) {
          configs.add(ReplaceFile(value['source'].toString(), value['target'].toString()));
        }
      }
    });
    return configs;
  }

  @override
  String toString() {
    return 'YamlParser{_flutterConfigs: $flutterConfigs, _androidConfigs: $androidConfigs, _iosConfigs: $iosConfigs, _replaceFiles: $replaceFiles}';
  }
}
