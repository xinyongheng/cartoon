import 'dart:math';

import 'package:cartoon/db/db_config.dart';
import 'db_cartoon.dart';

///数据库映射类
abstract class DbProvider {
  Map<String, Object?> toMap();

  Future<int> insert(DbManage dbManage);

  Future<int> insertOrReplace(DbManage dbManage);

  Future<int> update(DbManage dbManage);

//T fromMap<T extends DbProvider>(Map<String, Object?> map);
}

///类字段信息
class Property {
  final int ordinal;
  final Type type;
  final String name;
  final bool primaryKey;
  final String columnName;

  Property(this.ordinal, this.type, this.name, this.primaryKey, this.columnName);
}

class ReadInfoDbProvider {
  //表名
  static final TABLENAME = 'read_info';

  //字段
  static final Property Id = new Property(0, int, "id", true, "id");
  static final Property Title = new Property(1, String, "title", false, "title");
  static final Property PathProgress = new Property(2, String, "pathProgress", false, "path_progress");
  static final Property Progress = new Property(3, String, "progress", false, "progress");
  static final Property TimeMilli = new Property(4, int, "timeMilli", false, "time_milli");

  static List<String> columnNames() {
    var list = <String>[];
    list.add(Id.columnName);
    list.add(Title.columnName);
    list.add(PathProgress.columnName);
    list.add(Progress.columnName);
    list.add(TimeMilli.columnName);
    return list;
  }

  static Future<void> crateTable(DbManage dbManage, bool ifNotExists) async {
    String constraint = ifNotExists ? "IF NOT EXISTS " : "";
    await dbManage.execSQL("CREATE TABLE " +
        constraint +
        "\"$TABLENAME\" (" + //
        "\"id\" INTEGER PRIMARY KEY AUTOINCREMENT ," + // 0: id
        "\"title\" TEXT," + // 1: title
        "\"path_progress\" TEXT," + // 2: pathProgress
        "\"progress\" TEXT," + // 3: progress
        "\"time_milli\" INTEGER NOT NULL );"); // 4: timeMilli
    // Add Indexes
    await dbManage
        .execSQL("CREATE UNIQUE INDEX " + constraint + "IDX_read_info_title ON \"$TABLENAME\"" + " (\"title\" ASC);");
  }

  static Future<void> dropTable(DbManage db, bool ifExists) {
    return db.dropTable(TABLENAME, ifExists);
  }

  static Future<List<ReadInfoDb>> loadAll([String? whereFilter]) async {
    var db = await DbManage.instance.database;
    var where = null == whereFilter || whereFilter.isEmpty ? "" : ' where $whereFilter';
    var sql = 'select * from $TABLENAME$where';
    var list = await db.rawQuery(sql);
    var listBean = <ReadInfoDb>[];
    list.forEach((element) {
      listBean.add(ReadInfoDb.fromMap(element));
    });
    return listBean;
  }

  static Future<ReadInfoDb?> load(String title) async {
    var db = await DbManage.instance.database;
    var list = await db.rawQuery("select * from $TABLENAME where ${ReadInfoDbProvider.Title.columnName}='$title'");
    if (list.length > 1) {
      print('ReadInfoDb columnName: title=$title, value size is ${list.length}, more one');
    }
    if (list.isNotEmpty) {
      return ReadInfoDb.fromMap(list[0]);
    }
    return null;
  }

  static Future<ReadInfoDb?> loadId(int id) async {
    var db = await DbManage.instance.database;
    var list =
        await db.query(TABLENAME, columns: columnNames(), where: '${Id.columnName}=?', whereArgs: [id], limit: 1);
    return list.isNotEmpty ? ReadInfoDb.fromMap(list.first) : null;
  }
}
