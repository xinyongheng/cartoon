import 'package:sqflite/sqflite.dart';

import 'db_provider.dart';
import 'db_config.dart';

///漫画数据库
///阅读历史记录
///阅读进度记录
///阅读信息
class ReadInfoDb implements DbProvider {
  int? id;
  late String title;
  late String pathProgress;
  late String progress;
  int timeMilli = 0;

  ReadInfoDb(this.title, this.pathProgress, this.progress, this.timeMilli);

  ReadInfoDb.fromMap(Map<String, Object?> map) {
    id = map[ReadInfoDbProvider.Id.columnName] as int?;
    title = map[ReadInfoDbProvider.Title.columnName] as String;
    pathProgress = map[ReadInfoDbProvider.PathProgress.columnName] as String;
    progress = map[ReadInfoDbProvider.Progress.columnName] as String;
    timeMilli = map[ReadInfoDbProvider.TimeMilli.columnName] as int;
  }

  ReadInfoDb.make(this.title, this.pathProgress, this.progress) {
    this.timeMilli = DateTime.now().millisecondsSinceEpoch;
  }

  @override
  String toString() {
    return 'ReadInfoDb{title: $title, pathProgress: $pathProgress, progress: $progress, timeMilli: $timeMilli}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ReadInfoDb && title == other.title && pathProgress == other.pathProgress && progress == other.progress;

  @override
  int get hashCode => title.hashCode ^ pathProgress.hashCode ^ progress.hashCode;

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      ReadInfoDbProvider.Title.columnName: title,
      ReadInfoDbProvider.PathProgress.columnName: pathProgress,
      ReadInfoDbProvider.Progress.columnName: progress,
      ReadInfoDbProvider.TimeMilli.columnName: timeMilli
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  @override
  Future<int> insert(DbManage dbManage) async {
    this.id = await dbManage.insert(ReadInfoDbProvider.TABLENAME, toMap());
    return this.id!;
  }

  @override
  Future<int> insertOrReplace(DbManage dbManage) async {
    var id = await dbManage.insert(ReadInfoDbProvider.TABLENAME, toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    this.id = id;
    return id;
  }

  @override
  Future<int> update(DbManage dbManage) {
    return dbManage.update(ReadInfoDbProvider.TABLENAME, toMap());
  }
}