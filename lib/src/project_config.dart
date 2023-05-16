/// 项目配置类
class ProjectConfig {
  String name;
  ProjectConfigValueType type;
  dynamic value;

  ProjectConfig(this.name, String type, this.value)
      : type = (() {
          if (type.toLowerCase() == 'int') {
            return ProjectConfigValueType.typeInt;
          } else if (type.toLowerCase() == 'double') {
            return ProjectConfigValueType.typeDouble;
          } else if (type.toLowerCase() == 'bool') {
            return ProjectConfigValueType.typeBool;
          } else if (type.toLowerCase() == 'string') {
            return ProjectConfigValueType.typeString;
          } else {
            return ProjectConfigValueType.typeString;
          }
        }());

  @override
  String toString() {
    return 'ProjectConfig{name: $name, type: $type, value: $value}';
  }
}

enum ProjectConfigValueType {
  typeInt,
  typeDouble,
  typeBool,
  typeString,
}

/// 替换文件
class ReplaceFile {
  String source;
  String target;

  ReplaceFile(this.source, this.target);

  @override
  String toString() {
    return 'ReplaceFile{source: $source, target: $target}';
  }
}
