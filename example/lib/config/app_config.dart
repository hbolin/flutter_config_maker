/// 该文件为自动生成，手动更改该文件，修改的内容，会被替换。
class AppConfig {
  static const EnvType _defaultEnvActive = EnvType.pro;

  static EnvType? _runEnvType;

  static EnvType get runEnvType {
    if (_runEnvType != null) return _runEnvType!;
    const value = String.fromEnvironment('env_type', defaultValue: 'pro');
    if (value.isNotEmpty) {
      switch (value) {
        case 'dev':
          _runEnvType = EnvType.dev;
          break;
        case 'pro':
          _runEnvType = EnvType.pro;
          break;
      }
    }
    _runEnvType ??= _defaultEnvActive;
    return _runEnvType!;
  }

  static String get baseUrl {
    switch (runEnvType) {
      case EnvType.dev:
        return AppConfigDev.baseUrl;
      case EnvType.pro:
        return AppConfigPro.baseUrl;
      default:
        return 'https://www.xxxxx.com/';
    }
  }

  static String get code {
    switch (runEnvType) {
      case EnvType.dev:
        return AppConfigDev.code;
      case EnvType.pro:
        return AppConfigPro.code;
      default:
        return '6';
    }
  }

  static String get commonUrl {
    return 'https://www.common_url.com/';
  }

  static String get otherUrl {
    switch (runEnvType) {
      case EnvType.dev:
        return AppConfigDev.otherUrl;
      case EnvType.pro:
        return AppConfigPro.otherUrl;
      default:
        return AppConfigPro.otherUrl;
    }
  }
}

class AppConfigDev {
  static const String baseUrl = 'https://www.xxxxx_dev.com/';
  static const String code = '7';
  static const String otherUrl = 'https://www.other_url_dev.com/';
}

class AppConfigPro {
  static const String baseUrl = 'https://www.xxxxx_pro.com/';
  static const String code = '8';
  static const String otherUrl = 'https://www.other_url_pro.com/';
}

enum EnvType {
  none,
  dev,
  pro,
}
