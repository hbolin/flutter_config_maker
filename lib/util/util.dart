import 'dart:io';

import 'package:path/path.dart' as path;

/// 目录扩展工具
extension DirectoryEx on Directory {
  /// 获取子文件
  File childFile(String fileName) => File(path.join(this.path, fileName));

  /// 获取子目录
  Directory childDirectory(String directoryName) => Directory(path.join(this.path, directoryName));
}

/// 文件扩展工具
extension FileEx on File {
  /// 文件名，不包括后缀
  String get fileNameWithoutExtension {
    return path.basenameWithoutExtension(this.path);
  }

  /// 文件名，包括后缀
  String get fileName {
    return path.basename(this.path);
  }
}

/// map扩展工具
extension MapEx<K, V> on Map<K, V> {
  /// 浅拷贝
  Map<K, V> shallowCopy() {
    Map<K, V> tempMap = {};
    tempMap.addAll(this);
    return tempMap;
  }
}

/// list扩展工具
extension ListEx<E> on List<E> {
  /// 浅拷贝
  List<E> shallowCopy() {
    List<E> tempList = [];
    tempList.addAll(this);
    return tempList;
  }
}
