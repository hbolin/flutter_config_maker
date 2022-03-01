import 'dart:async' show Future;
import 'dart:isolate' show Isolate;

/// 获取package所在路径
///
/// ```dart
/// 示例：
///   Uri uri = await resolveUri(Uri.parse('package:flutter_config_maker/'));
///   print(uri.path);
/// 输出：
///   /Users/hbl/workspace/flutter/flutter_config_maker/lib/
/// 注意：
///   如果是在windows环境下会生成前面多一个/
///   /D:/development/workspace/flutter/flutter_config_maker/lib/templates/app.yaml.tmpl
///```
Future<Uri> resolveUri(Uri uri) {
  if (uri.scheme == 'package') {
    return Isolate.resolvePackageUri(uri).then((resolvedUri) {
      if (resolvedUri == null) {
        throw ArgumentError.value(uri, 'uri', 'Unknown package');
      }
      return resolvedUri;
    });
  }
  return Future<Uri>.value(Uri.base.resolveUri(uri));
}
