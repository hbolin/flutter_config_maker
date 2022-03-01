## 开始

    使用create命令生成app.yaml配置文件，目前支持flutter，android，替换文件，暂不支持ios配置。
    在根据app.yaml，app-dev.yaml，app-pro.yaml等配置文件生成对应的flutter配置类和android的config.gradle配置文件，以及进行文件替换的操作。

## 使用

`flutter_config_maker`包有2个命令可以使用create命令和build命令。

### create命令

    可以使用--help来查看帮助：`flutter pub run flutter_config_maker create --help`

创建默认的.yaml配置文件和.dart配置文件

Usage: flutter_config_maker create  
-h, --help                 Print this usage information.  
    --config-dir           app配置文件所在目录的路径，默认值:config  
    --target-path          flutter配置文件生成的路径，默认值:lib/config/app_config.dart  
    --target-class-name    flutter配置生成类的名称，默认值:AppConfig  
    --build-platform       生成对应的平台，可选:[flutter,android,ios]]，默认值:flutter

`flutter pub run flutter_config_maker create --config-dir=config --target-path=lib/config/app_config.dart --target-class-name=AppConfig --build-platform=flutter,android`

### build命令

    可以使用--help来查看帮助：`flutter pub run flutter_config_maker build --help`

根据.yaml文件集合生成.dart配置文件。

Usage: flutter_config_maker build  
-h, --help                 Print this usage information.  
    --config-dir           app配置文件所在目录的路径，默认值:config  
    --target-path          flutter配置文件生成的路径，默认值:lib/config/app_config.dart  
    --target-class-name    flutter配置生成类的名称，默认值:AppConfig  
    --build-platform       生成对应的平台，可选:[flutter,android,ios]，默认值:flutter  
    --env-type             生成对应的环境，如果没有指定，则使用app.yaml中env.active的值  
    --[no-]replace-file    是否需要替换文件，默认值：false

`flutter pub run flutter_config_maker build --config-dir=config --target-path=lib/config/app_config.dart --target-class-name=AppConfig --build-platform=flutter,android --env-type=pro --replace-file`

## 环境变量优先级

    flutter run --dart-define=env_type=dev_01 > flutter pub run flutter_config_maker build --env-type=dev_02 > app.yaml文件中的env.active=dev_03  
    优先级dev_01 > dev_02 > dev_03
