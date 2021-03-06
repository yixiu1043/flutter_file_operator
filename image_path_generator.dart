import 'dart:io';

String codeContent = '';
String pubspecContent = '';
Map imagePathMap = {};
List quotePaths = [];
List directories = [];
String packageName = 'flutter_file_operator'; // 包的名称
List excludePaths = [
  'lib/data',
  'lib/event_bus',
  'lib/login_game',
  'lib/mixin',
  'lib/netgen',
  'lib/other_library',
  'lib/routes',
  'lib/service',
  'lib/utils',
  'lib/utils',
  'lib/image_map.dart',
  'lib/generated_plugin_registrant.dart'
];

void main() {
  generateImagePath();
  replaceImagePath();
  replacePubspec();
  // print(['imagePathMap', imagePathMap]);
}

/// 1. 生成图片资源路径
void generateImagePath() {
  /// 生成新的Dart文件名称
  String className = 'ImageMap';

  /// 遍历处理图片资源路径
  handleAssetsFile('assets/');

  /// 删除并生成新的文件
  var file = File('lib/image_map.dart');
  if (file.existsSync()) {
    file.deleteSync();
  }
  file.createSync();
  var contents = 'class $className {\n$codeContent\n}';
  file.writeAsString(contents);
}

/// 遍历assets文件夹
int assetCount = 0;
int totalAssetCount = 0;

void handleAssetsFile(String path) {
  var directory = Directory(path);
  if (directory == null) {
    throw '$path is not a directory.';
  }
  totalAssetCount += directory.listSync().length;
  for (var file in directory.listSync()) {
    assetCount++;
    var type = file.statSync().type;
    if (type == FileSystemEntityType.directory) {
      directories.add('${file.path}/');
      handleAssetsFile('${file.path}/');
    } else if (type == FileSystemEntityType.file) {
      var filePath = file.path;
      var keyName = filePath.trim().toUpperCase();

      if (!keyName.endsWith('.PNG') &&
          !keyName.endsWith('.JPEG') &&
          !keyName.endsWith('.SVG') &&
          !keyName.endsWith('.JPG') &&
          !keyName.endsWith('.GIF') &&
          !keyName.endsWith('.TFF')) continue;
      var key = keyName
          .replaceAll(RegExp(path.toUpperCase()), '')
          .replaceAll(RegExp('.PNG'), '')
          .replaceAll(RegExp('.JPEG'), '')
          .replaceAll(RegExp('.SVG'), '')
          .replaceAll(RegExp('.JPG'), '')
          .replaceAll(RegExp('.GIF'), '')
          .replaceAll(RegExp('.TFF'), '')
          .replaceAll(RegExp('@'), '_')
          .replaceAll(RegExp('-'), '_');

      if (key.startsWith(RegExp(r'^[0-9]'))) {
        var paths = path.split('/');
        var prefix = paths[paths.length - 2].toUpperCase();
        key = prefix + key;
      }
      imagePathMap[key] = filePath;
      codeContent = '$codeContent\tstatic const String $key = \'$filePath\';\n';
    }
  }
  printProgress('图片路径生成', assetCount, totalAssetCount);
}

void printProgress(String label, int count, int totalCount) {
  double num = (count * 100) / totalCount;
  print('*******$label*******${num.toStringAsFixed(2)}%');
}

/// 2. 替换图片资源路径
void replaceImagePath() {
  handleLibFile('lib/');
  imagePathMap.forEach((key, value) {
    if (!quotePaths.contains(value)) {
      print('\x1B[33m====== $value 该图片资源可能没有引用，请确认后手动删除 ======\x1B[0m\n');
    }
  });
}

/// 遍历lib文件夹
int libCount = 0;
int totalLibCount = 0;

void handleLibFile(String path) {
  var directory = Directory(path);
  if (directory == null) {
    throw '$path is not a directory.';
  }
  totalLibCount += directory.listSync().length;
  for (var file in directory.listSync()) {
    if (excludePaths.contains(file.path)) continue;
    // print(['file.path>>>>>>>>>', file.path]);
    libCount++;
    var type = file.statSync().type;
    if (type == FileSystemEntityType.directory) {
      handleLibFile('${file.path}/');
    } else if (type == FileSystemEntityType.file) {
      if (file.path.trim() == 'lib/image_map.dart') continue;
      String contents = File(file.path).readAsStringSync();
      String import = 'import \'package:$packageName/image_map.dart\';\n';

      imagePathMap.forEach((key, value) {
        if (contents.contains(value)) {
          if (!contents.contains(import)) {
            contents = import + contents;
          }
          contents = contents.replaceAll('\'$value\'', 'ImageMap.$key');
          contents = contents.replaceAll('\"$value\"', 'ImageMap.$key');
          if (!quotePaths.contains(value)) {
            quotePaths.add(value);
          }
        } else {
          if (contents.contains(key)) {
            if (!quotePaths.contains(value)) {
              quotePaths.add(value);
            }
          }
        }
      });
      File(file.path).writeAsStringSync(contents);
    }
  }
  printProgress('图片路径替换', libCount, totalLibCount);
}

/// 在pubspec.yaml生成图片路径配置
replacePubspec() {
  var pubspecFile = File('pubspec.yaml');

  for (String lineContent in pubspecFile.readAsLinesSync()) {
    if (lineContent.trim() == 'assets:') continue;
    String imagePath = lineContent.replaceAll('- ', '').trim();
    if (directories.contains(imagePath)) continue;
    pubspecContent = "$pubspecContent\n$lineContent";
  }
  pubspecContent = '${pubspecContent.trim()}\n\n  assets:';

  directories.forEach((path) {
    pubspecContent = '$pubspecContent\n    - $path';
  });

  /// 添加图片路径到pubspec.yaml文件中
  pubspecFile.writeAsString(pubspecContent);
}
