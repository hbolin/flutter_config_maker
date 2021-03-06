/// 项目配置类
class ProjectConfig {
  String name;
  ProjectConfigValueType type;
  dynamic value;

  ProjectConfig(this.name, String type, this.value)
      : type = (() {
          if (type.toLowerCase() == 'int') {
            return ProjectConfigValueType.TYPE_INT;
          } else if (type.toLowerCase() == 'double') {
            return ProjectConfigValueType.TYPE_DOUBLE;
          } else if (type.toLowerCase() == 'bool') {
            return ProjectConfigValueType.TYPE_BOOL;
          } else if (type.toLowerCase() == 'string') {
            return ProjectConfigValueType.TYPE_STRING;
          } else {
            return ProjectConfigValueType.TYPE_STRING;
          }
        }());

  @override
  String toString() {
    return 'ProjectConfig{name: $name, type: $type, value: $value}';
  }
}

enum ProjectConfigValueType {
  TYPE_INT,
  TYPE_DOUBLE,
  TYPE_BOOL,
  TYPE_STRING,
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
